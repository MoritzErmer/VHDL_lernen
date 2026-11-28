package de.vhdllernen.app.logic

/** Text and cursor position of an editor. */
data class Snapshot(val text: String, val cursor: Int)

/**
 * Undo/redo for the answer editors. Typing inside a word is grouped into one step, everything else
 * (space, line break, deleting, pasting, extra keys) is a step of its own.
 */
class EditHistory(initial: Snapshot, private val limit: Int = 300) {
    private val undo = ArrayDeque(listOf(initial))
    private val redo = ArrayDeque<Snapshot>()
    private var typing = false

    val current: Snapshot get() = undo.last()
    val canUndo: Boolean get() = undo.size > 1
    val canRedo: Boolean get() = redo.isNotEmpty()

    fun record(text: String, cursor: Int) {
        val cur = undo.last()
        if (text == cur.text) {
            undo[undo.lastIndex] = cur.copy(cursor = cursor)
            return
        }
        val typed = text.length == cur.text.length + 1 && cursor in 1..text.length &&
            !text[cursor - 1].isWhitespace() && text.removeRange(cursor - 1, cursor) == cur.text
        if (typed && typing && undo.size > 1) undo[undo.lastIndex] = Snapshot(text, cursor)
        else undo.addLast(Snapshot(text, cursor))
        typing = typed
        redo.clear()
        while (undo.size > limit) undo.removeFirst()
    }

    fun undo(): Snapshot? {
        if (!canUndo) return null
        redo.addLast(undo.removeLast())
        typing = false
        return undo.last()
    }

    fun redo(): Snapshot? {
        val s = redo.removeLastOrNull() ?: return null
        undo.addLast(s)
        typing = false
        return s
    }
}
