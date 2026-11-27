package de.vhdllernen.app.ui

import androidx.compose.foundation.ExperimentalLayoutApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.outlined.IosShare
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import de.vhdllernen.app.AppState
import de.vhdllernen.app.Screen
import de.vhdllernen.app.UpdateStatus
import de.vhdllernen.app.data.ContentRepository
import de.vhdllernen.app.data.Course
import de.vhdllernen.app.data.Lesson
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.Rating

@Composable
fun TopBar(title: String, onBack: (() -> Unit)?, actions: @Composable RowScope.() -> Unit = {}) {
    val p = LocalPalette.current
    Column(Modifier.background(p.bg).statusBarsPadding()) {
        Row(
            Modifier.fillMaxWidth().height(56.dp).padding(horizontal = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (onBack != null) IconAction(Icons.AutoMirrored.Filled.ArrowBack, "Zurück", onBack)
            else Spacer(Modifier.width(12.dp))
            Text(
                title, style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.ink,
                maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f).padding(start = 4.dp),
            )
            actions()
        }
        Box(Modifier.fillMaxWidth().height(1.dp).background(p.line))
    }
}

@Composable
fun IconAction(icon: ImageVector, label: String, onClick: () -> Unit) {
    Box(Modifier.size(48.dp).clickable(onClick = onClick), contentAlignment = Alignment.Center) {
        Icon(icon, contentDescription = label, tint = LocalPalette.current.ink)
    }
}

/** Shows the result of a content check and a hint when a newer APK exists. */
@Composable
fun UpdateBanner(state: AppState) {
    val p = LocalPalette.current
    val uri = LocalUriHandler.current
    val status = state.update
    if (status is UpdateStatus.Done || status is UpdateStatus.Error) {
        val error = status is UpdateStatus.Error
        Row(
            Modifier.fillMaxWidth().background(if (error) p.bad.copy(alpha = 0.12f) else p.accentSoft, Corner)
                .clickable { state.dismissUpdateMessage() }.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                if (status is UpdateStatus.Done) status.message else (status as UpdateStatus.Error).message,
                style = Type.small, color = if (error) p.bad else p.ink, modifier = Modifier.weight(1f),
            )
            Text("OK", style = Type.small.copy(fontWeight = FontWeight.SemiBold), color = p.accent)
        }
    }
    if (state.appUpdateAvailable) {
        Row(
            Modifier.fillMaxWidth().border(1.dp, p.accent, Corner)
                .clickable { uri.openUri(state.content.app?.url ?: ContentRepository.RELEASES_URL) }.padding(14.dp),
        ) {
            Text(
                "Neue App-Version ${state.content.app?.versionName ?: ""} verfügbar · auf GitHub laden",
                style = Type.small.copy(fontWeight = FontWeight.Medium), color = p.accent,
            )
        }
    }
}

/** Progress of a course as a bit vector of std_logic cells. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ProgressVector(course: Course, progress: Map<String, Progress>, cell: Int = 12) {
    FlowRow(horizontalArrangement = Arrangement.spacedBy(3.dp), verticalArrangement = Arrangement.spacedBy(3.dp)) {
        course.lessons.forEach { l -> RatingCell(progress[course.key(l.id)]?.rating ?: Rating.U, size = cell) }
    }
}

fun nextLesson(course: Course, progress: Map<String, Progress>): Lesson? {
    fun r(l: Lesson) = progress[course.key(l.id)]?.rating ?: Rating.U
    return course.lessons.firstOrNull { r(it) == Rating.U }
        ?: course.lessons.firstOrNull { r(it) == Rating.ZERO }
        ?: course.lessons.firstOrNull { r(it) == Rating.X }
}

@Composable
fun CoursesScreen(state: AppState, progress: Map<String, Progress>) {
    val p = LocalPalette.current
    Column(Modifier.fillMaxSize()) {
        TopBar("Lern-Häppchen", onBack = null) {
            IconAction(Icons.Outlined.Settings, "Einstellungen") { state.open(Screen.Info) }
        }
        LazyColumn(
            Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 20.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            item {
                Text(
                    "Lernen in 5-Minuten-Einheiten: Erklärung lesen, Aufgabe lösen, mit der Musterlösung abgleichen. " +
                        "Alles funktioniert offline, neue Inhalte kommen im WLAN automatisch.",
                    style = Type.body, color = p.muted,
                )
            }
            item { UpdateBanner(state) }
            items(state.content.courses, key = { it.id }) { course ->
                CourseTheme(course.id) { CourseCard(state, course, progress) }
            }
        }
    }
}

@Composable
private fun CourseCard(state: AppState, course: Course, progress: Map<String, Progress>) {
    val p = LocalPalette.current
    val done = course.lessons.count { (progress[course.key(it.id)]?.rating ?: Rating.U) == Rating.ONE }
    val next = nextLesson(course, progress)
    Column(
        Modifier.fillMaxWidth().background(p.surface, Corner).border(1.dp, p.line, Corner)
            .clickable { state.open(Screen.Home(course.id)) }.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(10.dp).background(p.accent, Corner))
            Text(
                course.name, style = Type.title.copy(fontSize = Type.title.fontSize * 0.85f), color = p.ink,
                modifier = Modifier.padding(start = 10.dp).weight(1f),
            )
            Text("$done/${course.lessons.size}", style = Type.label, color = p.muted)
        }
        Text(course.exam, style = Type.small, color = p.muted)
        ProgressVector(course, progress, cell = 11)
        if (next != null) {
            Text(
                "Weiter mit ${next.id} · ${next.title}", style = Type.small.copy(fontWeight = FontWeight.Medium),
                color = p.accent, maxLines = 1, overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

@Composable
fun HomeScreen(state: AppState, courseId: String, progress: Map<String, Progress>) {
    val course = state.content.course(courseId) ?: return
    val p = LocalPalette.current
    fun rating(l: Lesson) = progress[course.key(l.id)]?.rating ?: Rating.U
    val next = nextLesson(course, progress)
    val review = course.lessons.filter { rating(it) == Rating.ZERO || rating(it) == Rating.X }.take(5)
    Column(Modifier.fillMaxSize()) {
        TopBar(course.name, onBack = { state.back() }) {
            IconAction(Icons.Outlined.IosShare, "Export für den Chat") { state.open(Screen.Export(course.id)) }
            IconAction(Icons.Outlined.Settings, "Einstellungen") { state.open(Screen.Info) }
        }
        LazyColumn(
            Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item { UpdateBanner(state) }
            if (next != null) item {
                Column(
                    Modifier.fillMaxWidth().background(p.accent, Corner)
                        .clickable { state.open(Screen.Lesson(course.id, next.id)) }.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    Text(
                        if (rating(next) == Rating.U) "WEITER MIT" else "NOCHMAL ÜBEN",
                        style = Type.section, color = p.onAccent.copy(alpha = 0.8f),
                    )
                    Text("${next.id} · ${next.title}", style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.onAccent)
                    Text("${next.minutes} min · ${course.blockName(next.block)}", style = Type.small, color = p.onAccent.copy(alpha = 0.8f))
                }
            }
            item { Summary(course, progress) }
            if (review.isNotEmpty()) {
                item { SectionLabel("Wiederholen", Modifier.padding(top = 8.dp)) }
                items(review, key = { "r" + it.id }) { l -> LessonRow(l, rating(l)) { state.open(Screen.Lesson(course.id, l.id)) } }
            }
            item { SectionLabel("Alle Häppchen", Modifier.padding(top = 8.dp)) }
            course.blocks.forEach { block ->
                val key = "${course.id}:${block.id}"
                val open = key in state.settings.openBlocks
                val lessons = course.lessons.filter { it.block == block.id }
                item(key = "b$key") {
                    BlockHeader(block.id, block.name, lessons.count { rating(it) == Rating.ONE }, lessons.size, open) {
                        state.changeSettings { s -> s.copy(openBlocks = if (open) s.openBlocks - key else s.openBlocks + key) }
                    }
                }
                if (open) items(lessons, key = { "l" + it.id }) { l ->
                    LessonRow(l, rating(l)) { state.open(Screen.Lesson(course.id, l.id)) }
                }
            }
            item { Spacer(Modifier.navigationBarsPadding()) }
        }
    }
}

@Composable
private fun Summary(course: Course, progress: Map<String, Progress>) {
    val p = LocalPalette.current
    val counts = Rating.entries.associateWith { r -> course.lessons.count { (progress[course.key(it.id)]?.rating ?: Rating.U) == r } }
    Column(
        Modifier.fillMaxWidth().background(p.surface, Corner).border(1.dp, p.line, Corner).padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        ProgressVector(course, progress)
        Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            listOf(Rating.ONE, Rating.X, Rating.ZERO, Rating.U).forEach { r ->
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    RatingCell(r, size = 16)
                    Text("${counts[r]} ${r.label}", style = Type.small, color = p.ink)
                }
            }
        }
    }
}

@Composable
private fun BlockHeader(id: String, name: String, done: Int, total: Int, open: Boolean, onClick: () -> Unit) {
    val p = LocalPalette.current
    Row(
        Modifier.fillMaxWidth().background(p.surface, Corner).border(1.dp, p.line, Corner).clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(Modifier.size(30.dp).background(p.accentSoft, Corner), contentAlignment = Alignment.Center) {
            Text(id, style = Type.label.copy(fontWeight = FontWeight.Bold), color = p.accent)
        }
        Text(name, style = Type.body.copy(fontWeight = FontWeight.Medium), color = p.ink, modifier = Modifier.weight(1f).padding(start = 12.dp))
        Text("$done/$total", style = Type.label, color = p.muted, modifier = Modifier.padding(end = 6.dp))
        Icon(if (open) Icons.Filled.ExpandLess else Icons.Filled.ExpandMore, null, tint = p.muted)
    }
}

@Composable
fun LessonRow(l: Lesson, rating: Rating, onClick: () -> Unit) {
    val p = LocalPalette.current
    Row(
        Modifier.fillMaxWidth().clickable(onClick = onClick).padding(horizontal = 6.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        RatingCell(rating, size = 20)
        Text(l.id, style = Type.label, color = p.muted, modifier = Modifier.padding(start = 12.dp).width(34.dp))
        Text(l.title, style = Type.body, color = p.ink, maxLines = 2, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
        Text("${l.minutes}′", style = Type.label, color = p.muted, modifier = Modifier.padding(start = 8.dp))
    }
}
