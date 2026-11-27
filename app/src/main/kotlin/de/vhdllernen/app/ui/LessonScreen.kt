package de.vhdllernen.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import de.vhdllernen.app.AppState
import de.vhdllernen.app.Screen
import de.vhdllernen.app.data.AnswerMode
import de.vhdllernen.app.data.Course
import de.vhdllernen.app.data.Lesson
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.Rating
import de.vhdllernen.app.logic.Compare

private enum class SolutionTab(val label: String) { COMPARE("Abgleich"), SOLUTION("Musterlösung") }

@Composable
fun LessonScreen(state: AppState, courseId: String, id: String, progress: Map<String, Progress>) {
    val course = state.content.course(courseId) ?: return
    val lesson = course.lesson(id) ?: return
    val key = course.key(id)
    val p = LocalPalette.current
    val prog = progress[key] ?: Progress()
    val openLesson: (String) -> Unit = { state.open(Screen.Lesson(courseId, it)) }
    val scroll = rememberScrollState()

    Column(Modifier.fillMaxSize().imePadding()) {
        TopBar("${lesson.id} · ${course.blockName(lesson.block)}", onBack = { state.back() })
        Column(
            Modifier.fillMaxSize().verticalScroll(scroll).padding(horizontal = 16.dp, vertical = 18.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text("${lesson.minutes} MIN · ${course.name.uppercase()}", style = Type.section, color = p.accent)
                Text(lesson.title, style = Type.title, color = p.ink)
            }
            if (lesson.ziel.isNotEmpty()) {
                Row(Modifier.fillMaxWidth().background(p.accentSoft, Corner).padding(14.dp)) {
                    Box(Modifier.width(3.dp).height(20.dp).background(p.accent))
                    Nodes(lesson.ziel, openLesson, Modifier.padding(start = 12.dp), course.lang)
                }
            }
            Nodes(lesson.erklaerung, openLesson, lang = course.lang)

            Divider()
            SectionLabel("Aufgabe")
            Nodes(lesson.aufgabe, openLesson, lang = course.lang)

            AnswerArea(state, course, lesson, key, prog)

            if (lesson.klausur.isNotEmpty()) {
                Column(
                    Modifier.fillMaxWidth().border(1.dp, p.line, Corner).padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    SectionLabel("Klausur")
                    Nodes(lesson.klausur, openLesson, lang = course.lang)
                }
            }
            PrevNext(course, lesson) { openLesson(it) }
            Spacer(Modifier.navigationBarsPadding())
        }
    }
}

@Composable
private fun Divider() = Box(Modifier.fillMaxWidth().height(1.dp).background(LocalPalette.current.line))

@Composable
private fun AnswerArea(state: AppState, course: Course, lesson: Lesson, key: String, prog: Progress) {
    val p = LocalPalette.current
    val code = lesson.mode == AnswerMode.CODE
    var answer by remember(key) {
        val initial = prog.answer.ifEmpty { lesson.starter }
        mutableStateOf(TextFieldValue(initial, TextRange(initial.length)))
    }
    var question by remember(key) { mutableStateOf(TextFieldValue(prog.question)) }
    var tab by rememberSaveable(key) { mutableStateOf(SolutionTab.COMPARE) }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SectionLabel(if (code) "Deine Lösung" else "Deine Antwort")
        AnswerEditor(
            value = answer,
            onChange = { v ->
                answer = v
                if (v.text != prog.answer) state.progress.update(key) { it.copy(answer = v.text) }
            },
            code = code,
            lang = course.lang,
            placeholder = if (code) "Code hier eintippen …" else "Antwort in Stichworten …",
        )
        if (!prog.revealed) {
            PrimaryButton(
                if (answer.text.isBlank()) "Lösung zeigen" else "Mit Lösung abgleichen",
                onClick = { state.progress.update(key) { it.copy(revealed = true) } },
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }

    if (prog.revealed) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            if (code && lesson.solutionCode.isNotBlank()) {
                Segmented(SolutionTab.entries, tab, { it.label }, { tab = it }, Modifier.fillMaxWidth())
            }
            if (code && lesson.solutionCode.isNotBlank() && tab == SolutionTab.COMPARE) {
                CompareView(answer.text, lesson.solutionCode, course.lang)
            } else {
                if (!code && answer.text.isNotBlank()) {
                    SectionLabel("Deine Antwort")
                    Text(answer.text, style = Type.body, color = p.ink,
                        modifier = Modifier.fillMaxWidth().background(p.sunken, Corner).padding(12.dp))
                    SectionLabel("Musterlösung")
                }
                Nodes(lesson.loesung, { state.open(Screen.Lesson(course.id, it)) }, lang = course.lang)
            }
            Text(
                "Lösung ausblenden", style = Type.small, color = p.muted,
                modifier = Modifier.clickable { state.progress.update(key) { it.copy(revealed = false) } }.padding(vertical = 4.dp),
            )
        }
    }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SectionLabel("Wie lief's?")
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(Rating.ONE, Rating.X, Rating.ZERO).forEach { r ->
                val on = prog.rating == r
                val c = p.rating(r)
                Row(
                    Modifier.weight(1f)
                        .background(if (on) c.copy(alpha = if (p.dark) 0.22f else 0.12f) else p.surface, Corner)
                        .border(1.dp, if (on) c else p.line, Corner)
                        .clickable { state.progress.update(key) { it.copy(rating = if (on) Rating.U else r) } }
                        .padding(vertical = 10.dp, horizontal = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center,
                ) {
                    RatingCell(r, size = 18)
                    Text(r.label, style = Type.small.copy(fontWeight = if (on) FontWeight.SemiBold else FontWeight.Normal),
                        color = if (on) c else p.ink, modifier = Modifier.padding(start = 8.dp))
                }
            }
        }
        SectionLabel("Frage an Claude (kommt in den Export)", Modifier.padding(top = 6.dp))
        AnswerEditor(
            value = question,
            onChange = { v ->
                question = v
                state.progress.update(key) { it.copy(question = v.text) }
            },
            code = false,
            placeholder = "Was ist dir unklar?",
            title = "Frage an Claude",
        )
    }
}

@Composable
private fun CompareView(answer: String, solution: String, lang: String) {
    val p = LocalPalette.current
    if (answer.isBlank()) {
        Text("Du hast noch nichts eingetippt – hier ist die Musterlösung:", style = Type.small, color = p.muted)
        CodeBlock(solution, lang)
        return
    }
    val r = remember(answer, solution) { Compare.run(answer, solution, lang) }
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            "${r.foundCount} von ${r.solution.size} Zeilen der Musterlösung kommen bei dir vor",
            style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.ink,
        )
        Column(Modifier.fillMaxWidth().background(p.sunken, Corner).border(1.dp, p.line, Corner).padding(vertical = 6.dp)) {
            r.solution.forEach { line ->
                Row(Modifier.fillMaxWidth().padding(horizontal = 10.dp, vertical = 2.dp)) {
                    Text(if (line.found) "ok" else "fehlt", style = Type.label,
                        color = if (line.found) p.ok else p.bad, modifier = Modifier.width(40.dp))
                    Text(highlight(line.text.trimEnd(), p, lang), style = Type.code, color = p.ink,
                        maxLines = 2, overflow = TextOverflow.Ellipsis)
                }
            }
        }
        if (r.extra.isNotEmpty()) {
            SectionLabel("Nur bei dir")
            Column(Modifier.fillMaxWidth().border(1.dp, p.line, Corner).padding(vertical = 6.dp)) {
                r.extra.forEach { line ->
                    Text(highlight(line.trimEnd(), p, lang), style = Type.code, color = p.ink,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 2.dp))
                }
            }
        }
        Text(
            "Andere Namen, Reihenfolge oder Formatierung können trotzdem richtig sein. " +
                "Im Zweifel: Frage notieren und exportieren.",
            style = Type.small, color = p.muted,
        )
    }
}

@Composable
private fun PrevNext(course: Course, lesson: Lesson, open: (String) -> Unit) {
    val p = LocalPalette.current
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        listOf(course.previous(lesson.id) to "Zurück", course.next(lesson.id) to "Weiter").forEach { (l, label) ->
            Column(
                Modifier.weight(1f).border(1.dp, p.line, Corner)
                    .then(if (l != null) Modifier.clickable { open(l.id) } else Modifier).padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                Text(label.uppercase(), style = Type.section, color = p.muted)
                Text(l?.let { "${it.id} · ${it.title}" } ?: "–", style = Type.small, color = if (l != null) p.ink else p.muted,
                    maxLines = 2, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}
