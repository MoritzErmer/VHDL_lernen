package de.vhdllernen.app.logic

enum class TokenKind { KEYWORD, TYPE, FUNCTION, LITERAL, STRING, NUMBER, COMMENT, ATTRIBUTE, OPERATOR }

data class Token(val start: Int, val end: Int, val kind: TokenKind)

/** Small VHDL tokenizer for syntax highlighting. Unknown text (identifiers, spaces) yields no token. */
object VhdlLexer {
    private val keywords = (
        "abs access after alias all and architecture array assert attribute begin block body buffer bus case " +
            "component configuration constant disconnect downto else elsif end entity exit file for function " +
            "generate generic group guarded if impure in inertial inout is label library linkage literal loop map " +
            "mod nand new next nor not null of on open or others out package port postponed procedure process pure " +
            "range record register reject rem report return rol ror select severity signal shared sla sll sra srl " +
            "subtype then to transport type unaffected units until use variable wait when while with xnor xor"
        ).split(' ').toSet()
    private val types = (
        "std_logic std_logic_vector std_ulogic std_ulogic_vector unsigned signed integer natural positive boolean " +
            "bit bit_vector character string time real"
        ).split(' ').toSet()
    private val functions = (
        "rising_edge falling_edge to_integer to_unsigned to_signed resize shift_left shift_right now std_match"
        ).split(' ').toSet()
    private val literals = "true false note warning error failure ieee work std std_logic_1164 numeric_std".split(' ').toSet()
    private val twoCharOps = setOf("<=", ":=", "=>", "/=", ">=", "**", "?=")
    private const val singleOps = "();,.:&|+-*/=<>"

    fun tokenize(src: String): List<Token> {
        val out = ArrayList<Token>()
        var i = 0
        var prev = ' ' // 'i' identifier/number/')', 'o' other
        val n = src.length
        while (i < n) {
            val c = src[i]
            when {
                c == '-' && i + 1 < n && src[i + 1] == '-' -> {
                    val end = src.indexOf('\n', i).let { if (it < 0) n else it }
                    out += Token(i, end, TokenKind.COMMENT); i = end
                }
                c == '"' || (c in "xXbBoO" && i + 1 < n && src[i + 1] == '"' && !src.getOrElse(i - 1) { ' ' }.isIdent()) -> {
                    val q = if (c == '"') i else i + 1
                    var end = q + 1
                    while (end < n && src[end] != '"' && src[end] != '\n') end++
                    if (end < n && src[end] == '"') end++
                    out += Token(i, end, TokenKind.STRING); i = end; prev = 'i'
                }
                c == '\'' -> {
                    if (prev == 'i') {
                        // attribute tick: clk'event, v'range, unsigned'(...)
                        out += Token(i, i + 1, TokenKind.OPERATOR)
                        var end = i + 1
                        if (end < n && src[end].isLetter()) {
                            while (end < n && src[end].isIdent()) end++
                            out += Token(i + 1, end, TokenKind.ATTRIBUTE)
                            prev = 'i'
                        } else prev = 'o'
                        i = end
                    } else if (i + 2 < n && src[i + 2] == '\'') {
                        out += Token(i, i + 3, TokenKind.STRING); i += 3; prev = 'i'
                    } else {
                        i++; prev = 'o'
                    }
                }
                c.isLetter() -> {
                    var end = i + 1
                    while (end < n && src[end].isIdent()) end++
                    val word = src.substring(i, end).lowercase()
                    val kind = when (word) {
                        in keywords -> TokenKind.KEYWORD
                        in types -> TokenKind.TYPE
                        in functions -> TokenKind.FUNCTION
                        in literals -> TokenKind.LITERAL
                        else -> null
                    }
                    if (kind != null) out += Token(i, end, kind)
                    prev = if (kind == TokenKind.KEYWORD) 'o' else 'i'
                    i = end
                }
                c.isDigit() -> {
                    var end = i + 1
                    while (end < n && (src[end].isDigit() || src[end] == '_' || src[end] == '.')) end++
                    out += Token(i, end, TokenKind.NUMBER); i = end; prev = 'i'
                }
                c.isWhitespace() -> i++
                i + 1 < n && src.substring(i, i + 2) in twoCharOps -> {
                    out += Token(i, i + 2, TokenKind.OPERATOR); i += 2; prev = 'o'
                }
                c in singleOps -> {
                    out += Token(i, i + 1, TokenKind.OPERATOR); i++; prev = if (c == ')') 'i' else 'o'
                }
                else -> {
                    i++; prev = 'o'
                }
            }
        }
        return out
    }

    private fun Char.isIdent() = isLetterOrDigit() || this == '_'
}
