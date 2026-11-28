package de.vhdllernen.app

import android.app.Application
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import de.vhdllernen.app.ui.CourseTheme
import de.vhdllernen.app.ui.CoursesScreen
import de.vhdllernen.app.ui.ExportScreen
import de.vhdllernen.app.ui.HomeScreen
import de.vhdllernen.app.ui.InfoScreen
import de.vhdllernen.app.ui.LessonScreen
import de.vhdllernen.app.ui.LocalPalette
import de.vhdllernen.app.ui.VhdlTheme

class VhdlApplication : Application() {
    val state: AppState by lazy { AppState(this) }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val state = (application as VhdlApplication).state
        setContent { VhdlApp(state) }
    }
}

@Composable
fun VhdlApp(state: AppState) {
    LaunchedEffect(Unit) { state.autoUpdate() }
    val progress by state.progress.state.collectAsState()
    VhdlTheme(state.settings.theme, state.settings.dynamicColor) {
        BackHandler(enabled = state.stack.size > 1) { state.back() }
        Box(Modifier.fillMaxSize().background(LocalPalette.current.bg)) {
            AnimatedContent(
                targetState = state.screen,
                transitionSpec = { fadeIn(tween(160)) togetherWith fadeOut(tween(120)) },
                label = "screen",
            ) { screen ->
                when (screen) {
                    Screen.Courses -> CoursesScreen(state, progress)
                    is Screen.Home -> CourseTheme(screen.course) { HomeScreen(state, screen.course, progress) }
                    is Screen.Lesson -> CourseTheme(screen.course) { LessonScreen(state, screen.course, screen.id, progress) }
                    is Screen.Export -> CourseTheme(screen.course) { ExportScreen(state, screen.course, progress) }
                    Screen.Info -> InfoScreen(state)
                }
            }
        }
    }
}
