package de.vhdllernen.app.logic

/**
 * Tokenizer for IKR RISC II assembler as used in the Rechnerarchitektur lessons:
 * `loop: addi r1 := r1,#-1   ; comment`, directives `.reg`/`.mem`, hex constants `$100`.
 */
object IkrLexer {
    fun tokenize(src: String): List<Token> {
        val out = ArrayList<Token>()
        var lineStart = 0
        while (lineStart <= src.length) {
            val lineEnd = src.indexOf('\n', lineStart).let { if (it < 0) src.length else it }
            line(src, lineStart, lineEnd, out)
            lineStart = lineEnd + 1
        }
        return out
    }

    private fun line(src: String, from: Int, to: Int, out: MutableList<Token>) {
        var i = from
        var sawMnemonic = false
        while (i < to) {
            val c = src[i]
            when {
                c == ';' -> { out += Token(i, to, TokenKind.COMMENT); return }
                c.isWhitespace() -> i++
                c == '.' && i + 1 < to && src[i + 1].isLetter() -> {
                    val end = scan(src, i + 1, to)
                    out += Token(i, end, TokenKind.LITERAL); i = end; sawMnemonic = true
                }
                c == '#' || c == '$' || c.isDigit() || (c == '-' && i + 1 < to && src[i + 1].isDigit()) -> {
                    var end = i + 1
                    while (end < to && (src[end].isLetterOrDigit() || src[end] == '-' && end == i + 1)) end++
                    out += Token(i, end, TokenKind.NUMBER); i = end
                }
                c.isLetter() || c == '_' -> {
                    val end = scan(src, i, to)
                    val word = src.substring(i, end).lowercase()
                    when {
                        end < to && src[end] == ':' && (end + 1 >= to || src[end + 1] != '=') ->
                            out += Token(i, end, TokenKind.FUNCTION) // label definition
                        Regex("r\\d{1,2}").matches(word) -> out += Token(i, end, TokenKind.TYPE)
                        !sawMnemonic -> { out += Token(i, end, TokenKind.KEYWORD); sawMnemonic = true }
                        else -> Unit // label reference
                    }
                    i = end
                }
                c == ':' && i + 1 < to && src[i + 1] == '=' -> { out += Token(i, i + 2, TokenKind.OPERATOR); i += 2 }
                c in "(),:" -> { out += Token(i, i + 1, TokenKind.OPERATOR); i++ }
                else -> i++
            }
        }
    }

    private fun scan(src: String, from: Int, to: Int): Int {
        var end = from
        while (end < to && (src[end].isLetterOrDigit() || src[end] == '_')) end++
        return end
    }
}

/** Picks the tokenizer for a course language ("vhdl" or "ikr"). */
object Highlighter {
    fun tokenize(lang: String, src: String): List<Token> = when (lang) {
        "ikr" -> IkrLexer.tokenize(src)
        "vhdl", "" -> VhdlLexer.tokenize(src)
        else -> emptyList()
    }

    fun commentPrefix(lang: String) = if (lang == "ikr") ";" else "--"
}
