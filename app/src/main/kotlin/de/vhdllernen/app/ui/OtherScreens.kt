package de.vhdllernen.app.ui

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.ui.draw.clip
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import de.vhdllernen.app.AppState
import de.vhdllernen.app.BuildConfig
import de.vhdllernen.app.UpdateStatus
import de.vhdllernen.app.data.ContentRepository
import de.vhdllernen.app.data.ContentSource
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.ThemeMode
import de.vhdllernen.app.logic.Export
import de.vhdllernen.app.logic.ExportOptions
import de.vhdllernen.app.logic.ExportScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun ExportScreen(state: AppState, courseId: String, progress: Map<String, Progress>) {
    val course = state.content.course(courseId) ?: return
    val p = LocalPalette.current
    val context = LocalContext.current
    val clipboard = LocalClipboardManager.current
    val scope = rememberCoroutineScope()
    var options by remember { mutableStateOf(ExportOptions()) }
    var copied by remember { mutableStateOf(false) }
    val date = remember { SimpleDateFormat("dd.MM.yyyy", Locale.GERMANY).format(Date()) }
    val text = remember(options, progress) { Export.build(course, progress, options, date) }
    val count = remember(options, progress) { Export.select(course, progress, options.scope).size }

    Column(Modifier.fillMaxSize()) {
        TopBar("Export: ${course.name}", onBack = { state.back() })
        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Text(
                "Sammelt deine Antworten, Bewertungen und Fragen als Text. Teile ihn mit der Claude-App oder kopiere " +
                    "ihn in einen Chat – die Einleitung sagt Claude, was zu tun ist.",
                style = Type.body, color = p.muted,
            )
            SectionLabel("Was soll rein?")
            Column(Modifier.clip(CardShape).background(p.container)) {
                ExportScope.entries.forEach { s ->
                    Row(
                        Modifier.fillMaxWidth().background(if (options.scope == s) p.accentSoft else p.container)
                            .clickable { options = options.copy(scope = s) }.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Box(
                            Modifier.size(18.dp).border(2.dp, if (options.scope == s) p.accent else p.line, CircleShape),
                            contentAlignment = Alignment.Center,
                        ) { if (options.scope == s) Box(Modifier.size(8.dp).background(p.accent, CircleShape)) }
                        Column(Modifier.padding(start = 12.dp)) {
                            Text(s.label, style = Type.body.copy(fontWeight = FontWeight.Medium), color = p.ink)
                            Text(s.hint, style = Type.small, color = p.muted)
                        }
                    }
                }
            }
            ToggleRow("Aufgabentext mitschicken", options.includeTask) { options = options.copy(includeTask = it) }
            ToggleRow("Musterlösung mitschicken", options.includeSolution) { options = options.copy(includeSolution = it) }

            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                PrimaryButton("Teilen …", modifier = Modifier.weight(1f), onClick = {
                    val send = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_SUBJECT, "${course.name}-Häppchen: meine Antworten")
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    context.startActivity(Intent.createChooser(send, "Antworten teilen"))
                })
                SecondaryButton(if (copied) "Kopiert" else "Kopieren", modifier = Modifier.weight(1f), onClick = {
                    clipboard.setText(AnnotatedString(text))
                    copied = true
                    scope.launch { delay(2000); copied = false }
                })
            }
            SectionLabel("Vorschau · $count Häppchen · ${text.length} Zeichen")
            SelectionContainer {
                Text(
                    text, style = Type.code, color = p.ink,
                    modifier = Modifier.fillMaxWidth().heightIn(max = 420.dp).background(p.sunken, Corner)
                        .verticalScroll(rememberScrollState()).padding(12.dp),
                )
            }
            Spacer(Modifier.navigationBarsPadding())
        }
    }
}

@Composable
private fun ToggleRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    val p = LocalPalette.current
    Row(Modifier.fillMaxWidth().clickable { onChange(!checked) }, verticalAlignment = Alignment.CenterVertically) {
        Text(label, style = Type.body, color = p.ink, modifier = Modifier.weight(1f))
        Switch(
            checked = checked, onCheckedChange = onChange,
            colors = SwitchDefaults.colors(checkedTrackColor = p.accent, checkedThumbColor = p.onAccent),
        )
    }
}

private data class ResetTarget(val courseId: String?, val label: String)

@Composable
fun InfoScreen(state: AppState) {
    val p = LocalPalette.current
    val uri = LocalUriHandler.current
    var confirmReset by remember { mutableStateOf<ResetTarget?>(null) }
    val fmt = remember { SimpleDateFormat("dd.MM.yyyy, HH:mm", Locale.GERMANY) }
    Column(Modifier.fillMaxSize()) {
        TopBar("Einstellungen", onBack = { state.back() })
        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            SectionLabel("Darstellung")
            Segmented(ThemeMode.entries, state.settings.theme, { it.label }, { m -> state.changeSettings { it.copy(theme = m) } },
                Modifier.fillMaxWidth())
            if (dynamicColorAvailable) {
                Column(Modifier.fillMaxWidth().background(p.container, CardShape).padding(16.dp)) {
                    ToggleRow("Farben vom Hintergrundbild (Material You)", state.settings.dynamicColor) { on ->
                        state.changeSettings { it.copy(dynamicColor = on) }
                    }
                }
            }

            SectionLabel("Inhalte", Modifier.padding(top = 10.dp))
            Column(
                Modifier.fillMaxWidth().background(p.container, CardShape).padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                val c = state.content
                Text(c.courses.joinToString(" · ") { "${it.name}: ${it.lessons.size}" } + " Häppchen",
                    style = Type.body.copy(fontWeight = FontWeight.Medium), color = p.ink)
                Text(
                    (if (state.source == ContentSource.DOWNLOADED) "Heruntergeladen" else "In der App enthalten") +
                        (if (c.revision > 0) ", Stand ${fmt.format(Date(c.revision * 1000))}" else "") +
                        " · Version ${c.version}",
                    style = Type.small, color = p.muted,
                )
                if (state.settings.lastCheck > 0) {
                    Text("Zuletzt geprüft: ${fmt.format(Date(state.settings.lastCheck))}", style = Type.small, color = p.muted)
                }
                PrimaryButton(
                    if (state.update == UpdateStatus.Checking) "Suche …" else "Jetzt nach neuen Inhalten suchen",
                    onClick = { state.checkForUpdates() }, enabled = state.update != UpdateStatus.Checking,
                    modifier = Modifier.fillMaxWidth(),
                )
                UpdateBanner(state)
                ToggleRow("Automatisch im WLAN prüfen", state.settings.autoUpdateOnWifi) { on ->
                    state.changeSettings { it.copy(autoUpdateOnWifi = on) }
                }
                Text(
                    "Prüft beim Start höchstens alle 3 Stunden, nur im WLAN (nicht über mobile Daten). " +
                        "Ohne Netz lernst du mit den zuletzt geladenen Inhalten weiter.",
                    style = Type.small, color = p.muted,
                )
            }

            SectionLabel("App", Modifier.padding(top = 10.dp))
            Column(
                Modifier.fillMaxWidth().background(p.container, CardShape).padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text("Version ${BuildConfig.VERSION_NAME}", style = Type.body, color = p.ink)
                Text(
                    "Neue Versionen und Quellcode auf GitHub", style = Type.small.copy(fontWeight = FontWeight.Medium),
                    color = p.accent, modifier = Modifier.clickable { uri.openUri(ContentRepository.RELEASES_URL) },
                )
                Text(
                    "Deine Antworten bleiben auf dem Handy. Die App verbindet sich nur mit github.com, um Inhalte zu laden.",
                    style = Type.small, color = p.muted,
                )
            }

            SectionLabel("Von vorn beginnen", Modifier.padding(top = 10.dp))
            Text(
                "Löscht Antworten, Fragen und Bewertungen. Die Inhalte bleiben. " +
                    "Einzelne Häppchen startest du unten im Häppchen neu.",
                style = Type.small, color = p.muted,
            )
            val targets = state.content.courses.map { it.id to "${it.name} neu starten" } + (null to "Alles neu starten")
            val pending = confirmReset
            if (pending == null) {
                targets.forEach { (id, label) ->
                    SecondaryButton(label, { confirmReset = ResetTarget(id, label) }, Modifier.fillMaxWidth())
                }
            } else {
                Text("${pending.label}? Das lässt sich nicht rückgängig machen.", style = Type.body, color = p.bad)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    SecondaryButton("Abbrechen", { confirmReset = null }, Modifier.weight(1f))
                    Box(
                        Modifier.weight(1f).background(p.bad, Corner).clickable {
                            if (pending.courseId == null) state.progress.reset() else state.progress.resetCourse(pending.courseId)
                            confirmReset = null
                        }.padding(vertical = 12.dp),
                        contentAlignment = Alignment.Center,
                    ) { Text("Löschen", style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.surface) }
                }
            }
            Spacer(Modifier.navigationBarsPadding())
        }
    }
}
