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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withLink
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.vhdllernen.app.data.Node
import de.vhdllernen.app.data.Rating
import de.vhdllernen.app.logic.Inline
import de.vhdllernen.app.logic.InlineParser
import de.vhdllernen.app.logic.Highlighter
import androidx.compose.ui.layout.Layout

val Corner = RoundedCornerShape(6.dp)

/** Source code (VHDL or IKR assembler) as coloured text. */
fun highlight(code: String, p: Palette, lang: String = "vhdl"): AnnotatedString = buildAnnotatedString {
    append(code)
    Highlighter.tokenize(lang, code).forEach { t ->
        p.syntax[t.kind]?.let { addStyle(SpanStyle(color = it), t.start, t.end) }
    }
}

/** Inline markdown -> AnnotatedString. Links to "#C02" open lessons, https links the browser. */
fun inlineText(text: String, p: Palette, onLesson: (String) -> Unit): AnnotatedString = buildAnnotatedString {
    val linkStyle = TextLinkStyles(SpanStyle(color = p.accent, textDecoration = TextDecoration.Underline))
    InlineParser.parse(text).forEach { part ->
        when (part) {
            is Inline.Text -> if (part.bold) withStyle(SpanStyle(fontWeight = FontWeight.SemiBold)) { append(part.text) }
            else append(part.text)
            is Inline.Code -> withStyle(SpanStyle(fontFamily = Type.mono, background = p.sunken, fontSize = 14.5.sp)) {
                append(" " + part.text + " ")
            }
            is Inline.Link -> when {
                part.target.startsWith("#") && part.target.length > 1 ->
                    withLink(LinkAnnotation.Clickable(part.target, linkStyle) { onLesson(part.target.drop(1)) }) { append(part.text) }
                part.target.startsWith("https://") -> withLink(LinkAnnotation.Url(part.target, linkStyle)) { append(part.text) }
                else -> append(part.text)
            }
        }
    }
}

@Composable
fun Nodes(nodes: List<Node>, onLesson: (String) -> Unit, modifier: Modifier = Modifier, lang: String = "vhdl") {
    val p = LocalPalette.current
    Column(modifier, verticalArrangement = Arrangement.spacedBy(12.dp)) {
        nodes.forEach { node ->
            when (node) {
                is Node.Paragraph -> Text(inlineText(node.text, p, onLesson), style = Type.body, color = p.ink)
                is Node.Code -> CodeBlock(node.code, lang = if (node.lang == "vhdl" || node.lang == "ikr") node.lang else if (node.lang.isEmpty()) lang else "")
                is Node.ListBlock -> Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    node.items.forEachIndexed { i, item ->
                        Row {
                            Text(
                                if (node.ordered) "${i + 1}." else "–",
                                style = Type.body, color = p.muted, modifier = Modifier.width(26.dp),
                            )
                            Text(inlineText(item, p, onLesson), style = Type.body, color = p.ink, modifier = Modifier.weight(1f))
                        }
                    }
                }
                is Node.Table -> TableBlock(node.rows, onLesson)
                is Node.Diagram -> DiagramView(node)
            }
        }
    }
}

@Composable
fun CodeBlock(code: String, lang: String = "vhdl", modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    CodeBlock(if (lang.isNotEmpty()) highlight(code, p, lang) else AnnotatedString(code), modifier)
}

/** Already styled code: no wrapping, scrolls sideways. */
@Composable
fun CodeBlock(code: AnnotatedString, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    val h = rememberScrollState()
    Box(
        modifier.fillMaxWidth().background(p.sunken, Corner).border(1.dp, p.line, Corner)
            .scrollbars(h, null, p.line.copy(alpha = 0.5f), p.muted)
            .horizontalScroll(h).padding(start = 12.dp, end = 12.dp, top = 10.dp, bottom = 14.dp)
    ) {
        Text(code, style = Type.code, color = p.ink, softWrap = false)
    }
}

/**
 * Table with aligned rows and columns. Wider than the screen it scrolls sideways; the scroll bar below shows
 * that more columns follow.
 */
@Composable
private fun TableBlock(rows: List<List<String>>, onLesson: (String) -> Unit) {
    if (rows.isEmpty()) return
    val p = LocalPalette.current
    val cols = rows.maxOf { it.size }
    val h = rememberScrollState()
    Box(
        Modifier.fillMaxWidth().border(1.dp, p.line, Corner)
            .scrollbars(h, null, p.line.copy(alpha = 0.5f), p.muted)
            .horizontalScroll(h).padding(bottom = if (h.maxValue > 0) 8.dp else 0.dp)
    ) {
        Layout(content = {
            rows.forEachIndexed { r, row ->
                for (c in 0 until cols) {
                    Box(Modifier.background(if (r == 0) p.sunken else p.surface).padding(horizontal = 10.dp, vertical = 8.dp)) {
                        Text(
                            inlineText(row.getOrElse(c) { "" }, p, onLesson),
                            style = Type.small.copy(fontWeight = if (r == 0) FontWeight.SemiBold else FontWeight.Normal),
                            color = p.ink, softWrap = false,
                        )
                    }
                }
            }
        }) { measurables, constraints ->
            // Intrinsic sizes first (a child may only be measured once), then every cell with its final size.
            val w = measurables.map { it.maxIntrinsicWidth(Int.MAX_VALUE) }
            val widths = IntArray(cols) { c -> rows.indices.maxOf { r -> w[r * cols + c] } }
            val heights = IntArray(rows.size) { r -> (0 until cols).maxOf { c -> measurables[r * cols + c].maxIntrinsicHeight(widths[c]) } }
            // Fill the available width when the table is narrower than the screen.
            val total = widths.sum()
            if (constraints.hasBoundedWidth && total < constraints.maxWidth) widths[cols - 1] += constraints.maxWidth - total
            val placeables = measurables.mapIndexed { i, m ->
                m.measure(androidx.compose.ui.unit.Constraints.fixed(widths[i % cols], heights[i / cols]))
            }
            layout(widths.sum(), heights.sum()) {
                var y = 0
                for (r in rows.indices) {
                    var x = 0
                    for (c in 0 until cols) {
                        placeables[r * cols + c].place(x, y)
                        x += widths[c]
                    }
                    y += heights[r]
                }
            }
        }
    }
}

/** Uppercase section label, e.g. "AUFGABE". */
@Composable
fun SectionLabel(text: String, modifier: Modifier = Modifier) {
    Text(text.uppercase(), style = Type.section, color = LocalPalette.current.muted, modifier = modifier)
}

/** A std_logic cell showing the self assessment (U, 1, X, 0). */
@Composable
fun RatingCell(r: Rating, size: Int = 18, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    val c = p.rating(r)
    Box(
        modifier.size(size.dp)
            .background(if (r == Rating.U) p.surface else c.copy(alpha = if (p.dark) 0.22f else 0.13f), RoundedCornerShape(3.dp))
            .border(1.dp, if (r == Rating.U) p.line else c, RoundedCornerShape(3.dp)),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            r.symbol, color = c, textAlign = TextAlign.Center,
            style = Type.label.copy(fontSize = (size * 0.6f).sp, lineHeight = (size * 0.7f).sp),
        )
    }
}

@Composable
fun PrimaryButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier, enabled: Boolean = true) {
    val p = LocalPalette.current
    Box(
        modifier.background(if (enabled) p.accent else p.line, Corner)
            .clickable(enabled = enabled, onClick = onClick)
            .padding(horizontal = 18.dp, vertical = 12.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(text, color = if (enabled) p.onAccent else p.muted, style = Type.body.copy(fontWeight = FontWeight.SemiBold))
    }
}

@Composable
fun SecondaryButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    Box(
        modifier.border(1.dp, p.line, Corner).background(p.surface, Corner).clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 11.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(text, color = p.ink, style = Type.body.copy(fontWeight = FontWeight.Medium))
    }
}

/** A row of mutually exclusive options. */
@Composable
fun <T> Segmented(options: List<T>, selected: T, label: (T) -> String, onSelect: (T) -> Unit, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    Row(modifier.border(1.dp, p.line, Corner).background(p.surface, Corner).padding(3.dp)) {
        options.forEach { o ->
            val on = o == selected
            Box(
                Modifier.weight(1f).background(if (on) p.accentSoft else p.surface, RoundedCornerShape(4.dp))
                    .clickable { onSelect(o) }.padding(vertical = 9.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text(label(o), style = Type.small.copy(fontWeight = if (on) FontWeight.SemiBold else FontWeight.Normal),
                    color = if (on) p.accent else p.ink)
            }
        }
    }
}
