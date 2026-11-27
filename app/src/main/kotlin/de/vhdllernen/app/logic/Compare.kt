package de.vhdllernen.app.logic

/** A token of source code with its position in the original text. */
data class CodeToken(val start: Int, val end: Int, val text: String)

/** A token range and whether it matched the other side. */
data class Mark(val start: Int, val end: Int, val ok: Boolean)

data class CompareResult(
    /** Every token of the model solution; ok = also present in the answer. */
    val solution: List<Mark>,
    /** Every token of the answer; ok = also present in the model solution. */
    val answer: List<Mark>,
) {
    val solutionTotal get() = solution.size
    val solutionFound get() = solution.count { it.ok }
    val answerWrong get() = answer.count { !it.ok }
    val percent get() = if (solution.isEmpty()) 0 else (100 * solutionFound + solution.size / 2) / solution.size
}

/**
 * Compares an answer with the model solution token by token, independent of line breaks, spacing,
 * case and comments.
 *
 * 1. Statements (VHDL: up to ';', IKR assembler: one line) that appear on both sides count as correct
 *    in any order (concurrent statements may be reordered).
 * 2. The remaining tokens are aligned in order (longest common subsequence), so the exact wrong or
 *    missing token is marked instead of a whole line.
 */
object Compare {
    fun tokenize(src: String, lang: String = "vhdl"): List<CodeToken> {
        val out = ArrayList<CodeToken>()
        val comment = Highlighter.commentPrefix(lang)
        var i = 0
        while (i < src.length) {
            val c = src[i]
            when {
                src.startsWith(comment, i) -> { while (i < src.length && src[i] != '\n') i++ }
                c.isWhitespace() -> i++
                c.isLetterOrDigit() || c == '_' || c == '#' || c == '$' || c == '.' && lang == "ikr" -> {
                    var e = i + 1
                    while (e < src.length && (src[e].isLetterOrDigit() || src[e] == '_')) e++
                    if (e < src.length && src[e] == '"' && e == i + 1 && c in "xXbBoO") e = stringEnd(src, e) // x"F0"
                    out += CodeToken(i, e, src.substring(i, e).lowercase()); i = e
                }
                c == '"' -> { val e = stringEnd(src, i); out += CodeToken(i, e, src.substring(i, e).lowercase()); i = e }
                c == '\'' && i + 2 < src.length && src[i + 2] == '\'' && !prevIsName(src, i) -> {
                    out += CodeToken(i, i + 3, src.substring(i, i + 3)); i += 3
                }
                i + 1 < src.length && src.substring(i, i + 2) in twoChar -> {
                    out += CodeToken(i, i + 2, src.substring(i, i + 2)); i += 2
                }
                else -> { out += CodeToken(i, i + 1, c.toString()); i++ }
            }
        }
        return out
    }

    private val twoChar = setOf("<=", ":=", "=>", "/=", ">=", "**")

    private fun stringEnd(src: String, quote: Int): Int {
        var e = quote + 1
        while (e < src.length && src[e] != '"' && src[e] != '\n') e++
        return if (e < src.length && src[e] == '"') e + 1 else e
    }

    private fun prevIsName(src: String, i: Int): Boolean {
        var j = i - 1
        while (j >= 0 && src[j] == ' ') j--
        return j >= 0 && (src[j].isLetterOrDigit() || src[j] == '_' || src[j] == ')')
    }

    /** Groups tokens into statements: VHDL up to and including ';', assembler per source line. */
    private fun statements(src: String, tokens: List<CodeToken>, lang: String): List<List<Int>> {
        val groups = ArrayList<List<Int>>()
        var cur = ArrayList<Int>()
        var line = -1
        tokens.forEachIndexed { idx, t ->
            if (lang == "ikr") {
                val l = src.substring(0, t.start).count { it == '\n' }
                if (l != line && cur.isNotEmpty()) { groups += cur; cur = ArrayList() }
                line = l
                cur += idx
            } else {
                cur += idx
                if (t.text == ";") { groups += cur; cur = ArrayList() }
            }
        }
        if (cur.isNotEmpty()) groups += cur
        return groups
    }

    fun run(answer: String, solution: String, lang: String = "vhdl"): CompareResult {
        val sTok = tokenize(solution, lang)
        val aTok = tokenize(answer, lang)
        val sOk = BooleanArray(sTok.size)
        val aOk = BooleanArray(aTok.size)

        // 1. identical statements, in any order
        val aStatements = statements(answer, aTok, lang)
        val unused = HashMap<String, ArrayDeque<List<Int>>>()
        aStatements.forEach { st -> unused.getOrPut(st.joinToString(" ") { aTok[it].text }) { ArrayDeque() }.add(st) }
        statements(solution, sTok, lang).forEach { st ->
            val key = st.joinToString(" ") { sTok[it].text }
            val match = unused[key]?.removeFirstOrNull() ?: return@forEach
            st.forEach { sOk[it] = true }
            match.forEach { aOk[it] = true }
        }

        // 2. remaining tokens aligned in order (LCS)
        val sRest = sTok.indices.filter { !sOk[it] }
        val aRest = aTok.indices.filter { !aOk[it] }
        if (sRest.isNotEmpty() && aRest.isNotEmpty() && sRest.size.toLong() * aRest.size <= 4_000_000L) {
            val n = sRest.size
            val m = aRest.size
            val dp = Array(n + 1) { IntArray(m + 1) }
            for (i in n - 1 downTo 0) for (j in m - 1 downTo 0) {
                dp[i][j] = if (sTok[sRest[i]].text == aTok[aRest[j]].text) dp[i + 1][j + 1] + 1
                else maxOf(dp[i + 1][j], dp[i][j + 1])
            }
            var i = 0
            var j = 0
            while (i < n && j < m) {
                when {
                    sTok[sRest[i]].text == aTok[aRest[j]].text -> { sOk[sRest[i]] = true; aOk[aRest[j]] = true; i++; j++ }
                    dp[i + 1][j] >= dp[i][j + 1] -> i++
                    else -> j++
                }
            }
        }
        return CompareResult(
            solution = sTok.mapIndexed { k, t -> Mark(t.start, t.end, sOk[k]) },
            answer = aTok.mapIndexed { k, t -> Mark(t.start, t.end, aOk[k]) },
        )
    }
}
