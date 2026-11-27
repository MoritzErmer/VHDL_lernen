package de.vhdllernen.app.logic

import de.vhdllernen.app.data.AnswerMode
import de.vhdllernen.app.data.Course
import de.vhdllernen.app.data.Lesson
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.Rating

enum class ExportScope(val label: String, val hint: String) {
    TOUCHED("Alles Bearbeitete", "jede Antwort, Bewertung oder Frage"),
    REVIEW("Unsicher und Nochmal", "nur X und 0 sowie Häppchen mit Frage"),
    QUESTIONS("Nur mit Frage", "Häppchen, zu denen du eine Frage notiert hast"),
}

data class ExportOptions(
    val scope: ExportScope = ExportScope.TOUCHED,
    val includeTask: Boolean = true,
    val includeSolution: Boolean = false,
)

/** Builds a Markdown text the learner can paste into a chat with Claude to discuss the answers. */
object Export {
    fun select(course: Course, progress: Map<String, Progress>, scope: ExportScope): List<Lesson> =
        course.lessons.filter { l ->
            val p = progress[course.key(l.id)] ?: return@filter false
            when (scope) {
                ExportScope.TOUCHED -> p.touched
                ExportScope.REVIEW -> p.rating == Rating.X || p.rating == Rating.ZERO || p.question.isNotBlank()
                ExportScope.QUESTIONS -> p.question.isNotBlank()
            }
        }

    fun build(
        course: Course,
        progress: Map<String, Progress>,
        options: ExportOptions,
        date: String,
    ): String {
        val lessons = course.lessons
        val chosen = select(course, progress, options.scope)
        val counts = Rating.entries.associateWith { r -> lessons.count { (progress[course.key(it.id)]?.rating ?: Rating.U) == r } }
        return buildString {
            appendLine("# ${course.name}-Häppchen: meine Antworten ($date)")
            appendLine()
            appendLine(
                "Ich lerne ${course.name} für die Klausur „${course.exam}“ (Uni Stuttgart). " +
                    "Bitte geh meine Antworten durch: Sag mir pro Häppchen, ob meine Lösung stimmt, was falsch ist " +
                    "und warum, und beantworte meine Fragen. Halte dich an den Stil des Vorlesungsskripts."
            )
            appendLine()
            appendLine(
                "Stand: ${lessons.size - counts.getValue(Rating.U)} von ${lessons.size} bewertet · " +
                    "1 sitzt: ${counts[Rating.ONE]} · X unsicher: ${counts[Rating.X]} · 0 nochmal: ${counts[Rating.ZERO]}"
            )
            if (chosen.isEmpty()) {
                appendLine()
                appendLine("_(Für diese Auswahl gibt es noch keine Einträge.)_")
            }
            chosen.forEach { l ->
                val p = progress.getValue(course.key(l.id))
                appendLine()
                appendLine("---")
                appendLine()
                appendLine("## ${l.id} · ${l.title}")
                appendLine(
                    "Selbsteinschätzung: ${p.rating.symbol} (${p.rating.label})" +
                        if (p.revealed) " · Musterlösung angesehen" else ""
                )
                if (options.includeTask) {
                    appendLine()
                    appendLine("### Aufgabe")
                    appendLine(l.aufgabeMd.trim())
                }
                appendLine()
                appendLine("### Meine Antwort")
                if (p.answer.isBlank()) appendLine("_(keine Antwort eingegeben)_")
                else {
                    appendLine(if (l.mode == AnswerMode.CODE) "```${course.lang}" else "```text")
                    appendLine(p.answer.trimEnd())
                    appendLine("```")
                }
                if (p.question.isNotBlank()) {
                    appendLine()
                    appendLine("### Meine Frage")
                    appendLine(p.question.trim())
                }
                if (options.includeSolution) {
                    appendLine()
                    appendLine("### Musterlösung")
                    appendLine(l.loesungMd.trim())
                }
            }
        }
    }
}
