package de.vhdllernen.app.data

import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.File

/** Self assessment, shown as std_logic values: U = open, 1 = sits, X = unsure, 0 = again. */
enum class Rating(val symbol: String, val label: String) {
    U("U", "offen"),
    ONE("1", "sitzt"),
    X("X", "unsicher"),
    ZERO("0", "nochmal");

    companion object {
        fun of(symbol: String?) = entries.firstOrNull { it.symbol == symbol } ?: U
    }
}

data class Progress(
    val answer: String = "",
    val rating: Rating = Rating.U,
    val question: String = "",
    val revealed: Boolean = false,
    val updated: Long = 0,
) {
    val touched: Boolean get() = answer.isNotBlank() || rating != Rating.U || question.isNotBlank()
}

/** The learner's answers, stored as one JSON file in app storage (included in Android backup). */
class ProgressStore(context: Context) {
    private val file = File(context.filesDir, "fortschritt.json")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var pendingSave: Job? = null
    private val _state = MutableStateFlow(load())
    val state: StateFlow<Map<String, Progress>> = _state

    fun get(id: String): Progress = _state.value[id] ?: Progress()

    fun update(id: String, change: (Progress) -> Progress) {
        _state.update { all -> all + (id to change(all[id] ?: Progress()).copy(updated = System.currentTimeMillis())) }
        scheduleSave()
    }

    /** Starts one lesson from scratch: answer, rating, question and the shown solution are dropped. */
    fun remove(id: String) {
        _state.update { it - id }
        scheduleSave(delayMs = 0)
    }

    /** Starts a whole course from scratch (keys look like "courseId:lessonId"). */
    fun resetCourse(courseId: String) {
        _state.update { all -> all.filterKeys { !it.startsWith("$courseId:") } }
        scheduleSave(delayMs = 0)
    }

    fun reset() {
        _state.value = emptyMap()
        scheduleSave(delayMs = 0)
    }

    private fun scheduleSave(delayMs: Long = 600) {
        pendingSave?.cancel()
        pendingSave = scope.launch {
            delay(delayMs)
            save(_state.value)
        }
    }

    private fun save(all: Map<String, Progress>) {
        val root = JSONObject()
        all.forEach { (id, p) ->
            if (p.touched || p.revealed) root.put(id, JSONObject().apply {
                put("answer", p.answer)
                put("rating", p.rating.symbol)
                put("question", p.question)
                put("revealed", p.revealed)
                put("updated", p.updated)
            })
        }
        val tmp = File(file.parentFile, "fortschritt.json.tmp")
        tmp.writeText(JSONObject().put("v", 1).put("items", root).toString())
        tmp.renameTo(file)
    }

    private fun load(): Map<String, Progress> = runCatching {
        val items = JSONObject(file.readText()).getJSONObject("items")
        items.keys().asSequence().associateWith { id ->
            val o = items.getJSONObject(id)
            Progress(
                answer = o.optString("answer"),
                rating = Rating.of(o.optString("rating")),
                question = o.optString("question"),
                revealed = o.optBoolean("revealed"),
                updated = o.optLong("updated"),
            )
        }
    }.getOrDefault(emptyMap())
}
