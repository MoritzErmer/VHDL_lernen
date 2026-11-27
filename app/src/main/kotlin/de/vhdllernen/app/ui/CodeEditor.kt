package de.vhdllernen.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.OpenInFull
import androidx.compose.material3.Icon
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.layout
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
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

/** Lets a child use extra width beyond the page padding (the page has a 16 dp gutter). */
fun Modifier.bleed(each: Dp) = layout { measurable, constraints ->
    if (!constraints.hasBoundedWidth) {
        val pl = measurable.measure(constraints)
        return@layout layout(pl.width, pl.height) { pl.place(0, 0) }
    }
    val extra = each.roundToPx() * 2
    val pl = measurable.measure(
        constraints.copy(minWidth = constraints.minWidth + extra, maxWidth = constraints.maxWidth + extra)
    )
    layout(pl.width - extra, pl.height) { pl.place(-extra / 2, 0) }
}

@Composable
private fun KeyBar(value: TextFieldValue, onChange: (TextFieldValue) -> Unit, lang: String, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    Row(modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        (if (lang == "ikr") ikrKeys else vhdlKeys).forEach { (label, insert) ->
            Box(
                Modifier.background(p.surface, Corner).border(1.dp, p.line, Corner)
                    .clickable { onChange(insertAt(value, insert)) }
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) { Text(label, style = Type.code, color = p.ink) }
        }
    }
}

/**
 * The text field itself. Code does not wrap: it scrolls horizontally and, inside the given height, vertically.
 * Text wraps and scrolls vertically.
 */
@Composable
private fun EditorField(
    value: TextFieldValue,
    onChange: (TextFieldValue) -> Unit,
    code: Boolean,
    placeholder: String,
    lang: String,
    modifier: Modifier,
) {
    val p = LocalPalette.current
    BoxWithConstraints(
        modifier.clip(Corner).background(if (code) p.sunken else p.surface).border(1.dp, p.line, Corner)
    ) {
        val minW = maxWidth
        val minH = minHeight
        val vertical = rememberScrollState()
        val horizontal = rememberScrollState()
        Box(Modifier.verticalScroll(vertical).then(if (code) Modifier.horizontalScroll(horizontal) else Modifier)) {
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
                modifier = (if (code) Modifier.widthIn(min = minW) else Modifier.width(minW))
                    .heightIn(min = minH)
                    .padding(horizontal = 10.dp, vertical = 10.dp),
                decorationBox = { inner ->
                    Box {
                        if (value.text.isEmpty()) Text(placeholder, style = if (code) Type.code else Type.body, color = p.muted)
                        inner()
                    }
                },
            )
        }
    }
}

/**
 * Answer editor. In code mode with syntax highlighting (VHDL or IKR assembler), auto-indent and extra keys.
 * Uses a little more width than the page text and can be opened full screen (also in landscape).
 */
@Composable
fun AnswerEditor(
    value: TextFieldValue,
    onChange: (TextFieldValue) -> Unit,
    code: Boolean,
    placeholder: String,
    lang: String = "vhdl",
    modifier: Modifier = Modifier,
    title: String = if (code) "Deine Lösung" else "Deine Antwort",
) {
    val p = LocalPalette.current
    var fullscreen by remember { mutableStateOf(false) }
    Column(modifier.bleed(10.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (code) KeyBar(value, onChange, lang, Modifier.weight(1f)) else Spacer(Modifier.weight(1f))
            Box(
                Modifier.padding(start = 6.dp).size(38.dp).border(1.dp, p.line, Corner).clickable { fullscreen = true },
                contentAlignment = Alignment.Center,
            ) { Icon(Icons.Filled.OpenInFull, contentDescription = "Im Vollbild bearbeiten", tint = p.ink, modifier = Modifier.size(18.dp)) }
        }
        EditorField(
            value, onChange, code, placeholder, lang,
            Modifier.fillMaxWidth().heightIn(min = if (code) 200.dp else 110.dp, max = if (code) 420.dp else 300.dp),
        )
    }
    if (fullscreen) {
        Dialog(
            onDismissRequest = { fullscreen = false },
            properties = DialogProperties(usePlatformDefaultWidth = false, decorFitsSystemWindows = false),
        ) {
            Column(
                Modifier.fillMaxSize().background(p.bg).systemBarsPadding().imePadding().padding(horizontal = 8.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                Row(Modifier.fillMaxWidth().height(52.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(title, style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.ink, modifier = Modifier.weight(1f))
                    Text(
                        "Fertig", style = Type.body.copy(fontWeight = FontWeight.SemiBold), color = p.accent,
                        modifier = Modifier.clickable { fullscreen = false }.padding(12.dp),
                    )
                }
                if (code) KeyBar(value, onChange, lang)
                EditorField(value, onChange, code, placeholder, lang, Modifier.fillMaxWidth().weight(1f).padding(bottom = 8.dp))
            }
        }
    }
}
