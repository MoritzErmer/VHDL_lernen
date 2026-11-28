package de.vhdllernen.app.ui

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
import de.vhdllernen.app.logic.Mark
import de.vhdllernen.app.logic.CompareResult
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.foundation.layout.size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextDecoration

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
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(course.name, style = Type.label, color = p.onAccentSoft,
                        modifier = Modifier.clip(Pill).background(p.accentSoft).padding(horizontal = 10.dp, vertical = 4.dp))
                    Text("${lesson.minutes} min", style = Type.label, color = p.onSecondarySoft,
                        modifier = Modifier.clip(Pill).background(p.secondarySoft).padding(horizontal = 10.dp, vertical = 4.dp))
                }
                Text(lesson.title, style = Type.title, color = p.ink)
            }
            if (lesson.ziel.isNotEmpty()) {
                Column(Modifier.fillMaxWidth().background(p.accentSoft, CardShape).padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Ziel", style = Type.section, color = p.onAccentSoft)
                    Nodes(lesson.ziel, openLesson, lang = course.lang)
                }
            }
            Nodes(lesson.erklaerung, openLesson, lang = course.lang)

            Divider()
            SectionLabel("Aufgabe")
            Nodes(lesson.aufgabe, openLesson, lang = course.lang)

            AnswerArea(state, course, lesson, key, prog)

            if (lesson.klausur.isNotEmpty()) {
                Column(
                    Modifier.fillMaxWidth().background(p.tertiarySoft, CardShape).padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text("Klausur", style = Type.section, color = p.onTertiarySoft)
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
            historyKey = key,
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
        val hide = { state.progress.update(key) { it.copy(revealed = false) } }
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                SectionLabel("Lösung", Modifier.weight(1f))
                Text(
                    "Ausblenden", style = Type.small.copy(fontWeight = FontWeight.SemiBold), color = p.onSecondarySoft,
                    modifier = Modifier.clip(Pill).background(p.secondarySoft).clickable { hide() }
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                )
            }
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
            SecondaryButton("Lösung ausblenden", { hide() }, Modifier.fillMaxWidth())
        }
    }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SectionLabel("Wie lief's?")
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(Rating.ONE, Rating.X, Rating.ZERO).forEach { r ->
                val on = prog.rating == r
                val c = p.rating(r)
                Row(
                    Modifier.weight(1f).clip(Pill)
                        .background(c.copy(alpha = if (on) (if (p.dark) 0.34f else 0.22f) else (if (p.dark) 0.12f else 0.08f)))
                        .then(if (on) Modifier.border(2.dp, c, Pill) else Modifier)
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
            historyKey = key + "#frage",
        )
        if (prog.touched || prog.revealed) {
            var confirm by remember(key) { mutableStateOf(false) }
            if (!confirm) {
                Text(
                    "Häppchen neu starten", style = Type.small, color = p.muted,
                    modifier = Modifier.clickable { confirm = true }.padding(vertical = 6.dp),
                )
            } else {
                Text("Antwort, Frage und Bewertung dieses Häppchens löschen?", style = Type.small, color = p.ink)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    SecondaryButton("Abbrechen", { confirm = false }, Modifier.weight(1f))
                    SecondaryButton("Neu starten", {
                        state.progress.remove(key)
                        answer = TextFieldValue(lesson.starter, TextRange(lesson.starter.length))
                        question = TextFieldValue("")
                        confirm = false
                    }, Modifier.weight(1f))
                }
            }
        }
    }
}

/** The corrected copy of the answer: wrong tokens struck through (red), missing ones inserted (green). */
private fun corrected(answer: String, r: CompareResult, p: Palette, lang: String): AnnotatedString {
    val c = Compare.corrected(answer, r)
    val alpha = if (p.dark) 0.30f else 0.18f
    return buildAnnotatedString {
        append(highlight(c.text, p, lang))
        c.wrong.forEach {
            addStyle(SpanStyle(color = p.bad, background = p.bad.copy(alpha = alpha), textDecoration = TextDecoration.LineThrough),
                it.first, it.last + 1)
        }
        c.inserted.forEach {
            addStyle(SpanStyle(color = p.ok, background = p.ok.copy(alpha = alpha), fontWeight = FontWeight.Bold), it.first, it.last + 1)
        }
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
    val trimmed = answer.trimEnd()
    val r = remember(trimmed, solution) { Compare.run(trimmed, solution, lang) }
    val missing = r.solution.count { !it.ok }
    val wrong = r.answerWrong
    val view = remember(trimmed, r, p) { corrected(trimmed, r, p, lang) }
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            if (missing == 0 && wrong == 0) "Alles getroffen – deine Lösung stimmt mit der Musterlösung überein."
            else "${r.percent} % der Musterlösung getroffen",
            style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = if (missing == 0 && wrong == 0) p.ok else p.ink,
        )
        if (missing > 0 || wrong > 0) {
            SectionLabel("Deine Lösung, korrigiert")
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                if (wrong > 0) Legend(p.bad, "durchgestrichen: bei dir falsch oder zu viel ($wrong)", strike = true)
                if (missing > 0) Legend(p.ok, "grün eingefügt: fehlt bei dir ($missing)")
            }
            CodeBlock(view)
        }
        Text(
            "Verglichen werden Wörter und Zeichen, nicht Zeilen: Umbrüche, Leerzeichen, Groß-/Kleinschreibung und " +
                "Kommentare spielen keine Rolle, ganze Anweisungen dürfen in anderer Reihenfolge stehen. " +
                "Andere Namen können trotzdem richtig sein – im Zweifel Frage notieren und exportieren. " +
                "Die vollständige Musterlösung steht im zweiten Tab.",
            style = Type.small, color = p.muted,
        )
    }
}

@Composable
private fun Legend(color: Color, text: String, strike: Boolean = false) {
    val p = LocalPalette.current
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            "abc", style = Type.code.copy(textDecoration = if (strike) TextDecoration.LineThrough else TextDecoration.None,
                fontWeight = if (strike) FontWeight.Normal else FontWeight.Bold),
            color = color,
            modifier = Modifier.background(color.copy(alpha = if (p.dark) 0.30f else 0.18f), Corner).padding(horizontal = 4.dp),
        )
        Text(text, style = Type.small, color = p.ink)
    }
}

@Composable
private fun PrevNext(course: Course, lesson: Lesson, open: (String) -> Unit) {
    val p = LocalPalette.current
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        listOf(course.previous(lesson.id) to "Zurück", course.next(lesson.id) to "Weiter").forEach { (l, label) ->
            Column(
                Modifier.weight(1f).clip(CardShape).background(if (label == "Weiter" && l != null) p.accentSoft else p.container)
                    .then(if (l != null) Modifier.clickable { open(l.id) } else Modifier).padding(14.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                Text(label, style = Type.section, color = p.accent)
                Text(l?.let { "${it.id} · ${it.title}" } ?: "–", style = Type.small, color = if (l != null) p.ink else p.muted,
                    maxLines = 2, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}
