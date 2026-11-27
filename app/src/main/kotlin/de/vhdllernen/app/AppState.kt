package de.vhdllernen.app

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import de.vhdllernen.app.data.AppSettings
import de.vhdllernen.app.data.Content
import de.vhdllernen.app.data.ContentRepository
import de.vhdllernen.app.data.ContentSource
import de.vhdllernen.app.data.ProgressStore
import de.vhdllernen.app.data.SettingsStore
import de.vhdllernen.app.data.UpdateResult
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

sealed interface Screen {
    /** Start: choose the subject. */
    data object Courses : Screen
    data class Home(val course: String) : Screen
    data class Lesson(val course: String, val id: String) : Screen
    data class Export(val course: String) : Screen
    data object Info : Screen
}

sealed interface UpdateStatus {
    data object Idle : UpdateStatus
    data object Checking : UpdateStatus
    data class Done(val message: String) : UpdateStatus
    data class Error(val message: String) : UpdateStatus
}

/** App-wide state. Lives as long as the process (see [VhdlApplication]). */
class AppState(context: Context) {
    private val repo = ContentRepository(context)
    private val settingsStore = SettingsStore(context)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private val initial = repo.loadBest()

    val progress = ProgressStore(context)
    var content: Content by mutableStateOf(initial.first)
        private set
    var source: ContentSource by mutableStateOf(initial.second)
        private set
    var settings: AppSettings by mutableStateOf(settingsStore.load())
        private set
    var update: UpdateStatus by mutableStateOf(UpdateStatus.Idle)
        private set
    /** Set once a check found a newer APK on GitHub. */
    var appUpdateAvailable: Boolean by mutableStateOf(false)
        private set

    val stack = mutableStateListOf<Screen>(Screen.Courses)
    val screen: Screen get() = stack.last()

    fun open(s: Screen) {
        if (s is Screen.Lesson && content.course(s.course)?.lesson(s.id) == null) return
        if (s is Screen.Home && content.course(s.course) == null) return
        if (stack.last() is Screen.Lesson && s is Screen.Lesson) stack[stack.lastIndex] = s else stack.add(s)
    }

    fun back(): Boolean {
        if (stack.size <= 1) return false
        stack.removeAt(stack.lastIndex)
        return true
    }

    fun changeSettings(change: (AppSettings) -> AppSettings) {
        settings = change(settings)
        settingsStore.save(settings)
    }

    /** Called at start: checks for new lessons if enabled and the phone is on Wi-Fi. */
    fun autoUpdate() {
        val due = System.currentTimeMillis() - settings.lastCheck > 3 * 60 * 60 * 1000L
        if (settings.autoUpdateOnWifi && due && repo.onUnmeteredNetwork()) checkForUpdates(quiet = true)
    }

    fun checkForUpdates(quiet: Boolean = false) {
        if (update == UpdateStatus.Checking) return
        update = UpdateStatus.Checking
        scope.launch {
            val result = repo.update(content)
            changeSettings { it.copy(lastCheck = System.currentTimeMillis()) }
            when (result) {
                is UpdateResult.Updated -> {
                    content = result.content
                    // Leave screens whose course or lesson no longer exists in the new content.
                    val valid = stack.filter { sc ->
                        when (sc) {
                            is Screen.Home -> content.course(sc.course) != null
                            is Screen.Export -> content.course(sc.course) != null
                            is Screen.Lesson -> content.course(sc.course)?.lesson(sc.id) != null
                            else -> true
                        }
                    }
                    stack.clear(); stack.addAll(valid.ifEmpty { listOf(Screen.Courses) })
                    source = ContentSource.DOWNLOADED
                    update = UpdateStatus.Done(
                        if (result.newLessons > 0) "Neue Inhalte geladen: ${result.newLessons} neue Häppchen"
                        else "Inhalte aktualisiert"
                    )
                    checkApp(result.content)
                }
                is UpdateResult.UpToDate -> {
                    update = if (quiet) UpdateStatus.Idle else UpdateStatus.Done("Alles aktuell")
                    checkApp(result.content)
                }
                is UpdateResult.Failed -> update = if (quiet) UpdateStatus.Idle else UpdateStatus.Error(result.reason)
            }
        }
    }

    fun dismissUpdateMessage() {
        if (update !is UpdateStatus.Checking) update = UpdateStatus.Idle
    }

    private fun checkApp(c: Content) {
        val newest = c.app ?: return
        appUpdateAvailable = newest.versionCode > BuildConfig.VERSION_CODE
    }
}
