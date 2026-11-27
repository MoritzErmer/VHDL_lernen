package de.vhdllernen.app.logic

data class CompareLine(val text: String, val found: Boolean)

data class CompareResult(
    /** Every non-empty line of the model solution and whether the learner's answer contains it. */
    val solution: List<CompareLine>,
    /** Lines of the learner's answer that do not appear in the model solution. */
    val extra: List<String>,
) {
    val foundCount get() = solution.count { it.found }
}

/**
 * Compares an answer with the model solution line by line. Lines are normalized (comments, case and
 * spacing ignored) and matched as a multiset, because in VHDL the order of concurrent statements does
 * not matter and labels/registers may be laid out differently.
 */
object Compare {
    fun normalize(line: String, lang: String = "vhdl"): String = line
        .substringBefore(Highlighter.commentPrefix(lang))
        .lowercase()
        .replace(Regex("\\s+"), " ")
        .replace(Regex("\\s*([(),;:<>=&+\\-*/|'])\\s*"), "$1")
        .trim()

    fun run(answer: String, solution: String, lang: String = "vhdl"): CompareResult {
        fun normalize(l: String) = normalize(l, lang)
        val mine = HashMap<String, Int>()
        val mineLines = answer.lines().filter { normalize(it).isNotEmpty() }
        mineLines.forEach { mine.merge(normalize(it), 1, Int::plus) }
        val sol = solution.lines().filter { normalize(it).isNotEmpty() }.map { line ->
            val key = normalize(line)
            val left = mine[key] ?: 0
            if (left > 0) mine[key] = left - 1
            CompareLine(line, left > 0)
        }
        val extra = mineLines.filter { line ->
            val key = normalize(line)
            val left = mine[key] ?: 0
            if (left > 0) { mine[key] = left - 1; true } else false
        }
        return CompareResult(sol, extra)
    }
}
