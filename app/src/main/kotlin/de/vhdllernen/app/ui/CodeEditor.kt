package de.vhdllernen.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp

private class CodeTransformation(private val p: Palette, private val lang: String) : VisualTransformation {
    override fun filter(text: AnnotatedString) = TransformedText(highlight(text.text, p, lang), OffsetMapping.Identity)
}

/** Keys that are awkward to reach on a phone keyboard. */
private val ikrKeys = listOf("⇥" to "  ", ":=" to " := ", "," to ",", "#" to "#", "$" to "$", "(" to "(", ")" to ")",
    ":" to ": ", ";" to "; ", "r31" to "r31", "jmp" to "jmp r31")

private val vhdlKeys = listOf("⇥" to "  ", "<=" to " <= ", ":=" to " := ", "=>" to " => ", "'" to "'", "\"" to "\"",
    "(" to "(", ")" to ")", ";" to ";", "_" to "_", "&" to " & ", "--" to "-- ")

private val indentAfter = Regex("(\\bthen|\\bis|\\bbegin|\\bloop|\\belse|\\bgenerate|=>|\\()\\s*$", RegexOption.IGNORE_CASE)

/** Keeps the indentation when a new line is started (and indents after then/is/begin/...). */
fun autoIndent(old: TextFieldValue, new: TextFieldValue): TextFieldValue {
    val pos = new.selection.start
    val inserted = new.text.length == old.text.length + 1 && pos > 0 && new.selection.collapsed &&
        new.text[pos - 1] == '\n' && old.text == new.text.removeRange(pos - 1, pos)
    if (!inserted) return new
    val lineStart = new.text.lastIndexOf('\n', pos - 2) + 1
    val prevLine = new.text.substring(lineStart, pos - 1)
    var indent = prevLine.takeWhile { it == ' ' }
    if (indentAfter.containsMatchIn(prevLine)) indent += "  "
    if (indent.isEmpty()) return new
    val text = new.text.substring(0, pos) + indent + new.text.substring(pos)
    return TextFieldValue(text, TextRange(pos + indent.length))
}

fun insertAt(v: TextFieldValue, s: String): TextFieldValue {
    val start = v.selection.min
    val end = v.selection.max
    val text = v.text.substring(0, start) + s + v.text.substring(end)
    return TextFieldValue(text, TextRange(start + s.length))
}

/**
 * Answer editor. In code mode with syntax highlighting (VHDL or IKR assembler), auto-indent and extra keys.
 * In text mode a plain multi-line field.
 */
@Composable
fun AnswerEditor(
    value: TextFieldValue,
    onChange: (TextFieldValue) -> Unit,
    code: Boolean,
    placeholder: String,
    lang: String = "vhdl",
    modifier: Modifier = Modifier,
) {
    val p = LocalPalette.current
    Column(modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        if (code) {
            Row(Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                (if (lang == "ikr") ikrKeys else vhdlKeys).forEach { (label, insert) ->
                    Box(
                        Modifier.background(p.surface, Corner).border(1.dp, p.line, Corner)
                            .clickable { onChange(insertAt(value, insert)) }
                            .padding(horizontal = 12.dp, vertical = 8.dp)
                    ) { Text(label, style = Type.code, color = p.ink) }
                }
            }
        }
        BasicTextField(
            value = value,
            onValueChange = { onChange(if (code && lang == "vhdl") autoIndent(value, it) else it) },
            textStyle = (if (code) Type.code else Type.body).copy(color = p.ink),
            cursorBrush = SolidColor(p.accent),
            visualTransformation = if (code) CodeTransformation(p, lang) else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(
                capitalization = if (code) KeyboardCapitalization.None else KeyboardCapitalization.Sentences,
                autoCorrectEnabled = !code,
            ),
            modifier = Modifier.fillMaxWidth().heightIn(min = if (code) 180.dp else 110.dp)
                .background(if (code) p.sunken else p.surface, Corner).border(1.dp, p.line, Corner)
                .padding(12.dp),
            decorationBox = { inner ->
                Box {
                    if (value.text.isEmpty()) Text(placeholder, style = if (code) Type.code else Type.body, color = p.muted)
                    inner()
                }
            },
        )
    }
}
