package de.vhdllernen.app.logic

/** Inline markdown pieces used in the lessons: **bold**, `code` and [text](target). */
sealed interface Inline {
    data class Text(val text: String, val bold: Boolean) : Inline
    data class Code(val text: String) : Inline
    data class Link(val text: String, val target: String) : Inline
}

object InlineParser {
    private val link = Regex("^\\[([^\\]]+)]\\(([^)\\s]+)\\)")

    fun parse(src: String): List<Inline> {
        val out = ArrayList<Inline>()
        val buf = StringBuilder()
        var bold = false
        var i = 0
        fun flush() {
            if (buf.isNotEmpty()) { out += Inline.Text(buf.toString(), bold); buf.clear() }
        }
        while (i < src.length) {
            val c = src[i]
            when {
                c == '`' -> {
                    val end = src.indexOf('`', i + 1)
                    if (end > i) { flush(); out += Inline.Code(src.substring(i + 1, end)); i = end + 1 }
                    else { buf.append(c); i++ }
                }
                src.startsWith("**", i) -> { flush(); bold = !bold; i += 2 }
                c == '[' -> {
                    val m = link.find(src.substring(i))
                    if (m != null) {
                        flush(); out += Inline.Link(m.groupValues[1], m.groupValues[2]); i += m.value.length
                    } else { buf.append(c); i++ }
                }
                else -> { buf.append(c); i++ }
            }
        }
        flush()
        return out
    }
}
