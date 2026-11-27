package de.vhdllernen.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.vhdllernen.app.data.DiagramRole
import de.vhdllernen.app.data.Node
import de.vhdllernen.app.data.Prim

private fun Palette.color(role: DiagramRole?): Color? = when (role) {
    DiagramRole.INK -> ink
    DiagramRole.LINE -> muted
    DiagramRole.ACCENT -> accent
    DiagramRole.SOFT -> accentSoft
    DiagramRole.SURFACE -> surface
    DiagramRole.GRID -> line
    null -> null
}

/** Smallest scale before the diagram scrolls sideways instead of shrinking further. */
private const val MIN_SCALE = 0.72f

/**
 * Draws a lesson diagram natively (state diagrams, block diagrams, timing diagrams) in the theme colours.
 * One diagram unit is one dp at scale 1; wide diagrams scale down to [MIN_SCALE] and then scroll.
 */
@Composable
fun DiagramView(d: Node.Diagram, modifier: Modifier = Modifier) {
    val p = LocalPalette.current
    val measurer = rememberTextMeasurer()
    val fontScale = LocalDensity.current.fontScale
    BoxWithConstraints(
        modifier.fillMaxWidth().background(p.surface, Corner).border(1.dp, p.line, Corner)
            .semantics { contentDescription = d.alt }
    ) {
        val inner = maxWidth - 16.dp
        val scale = (inner.value / d.width).coerceIn(MIN_SCALE, 1.4f)
        Box(Modifier.horizontalScroll(rememberScrollState()).padding(8.dp)) {
            Canvas(Modifier.size((d.width * scale).dp, (d.height * scale).dp)) {
                val f = scale * density
                d.prims.forEach { prim -> draw(prim, f, p, fontScale, measurer) }
            }
        }
    }
}

private fun DrawScope.draw(
    prim: Prim,
    f: Float,
    p: Palette,
    fontScale: Float,
    measurer: androidx.compose.ui.text.TextMeasurer,
) {
    val stroke = Stroke(width = 1.4f * f, join = StrokeJoin.Round)
    fun polyPath(pts: FloatArray, close: Boolean) = Path().apply {
        moveTo(pts[0] * f, pts[1] * f)
        var i = 2
        while (i < pts.size) { lineTo(pts[i] * f, pts[i + 1] * f); i += 2 }
        if (close) close()
    }
    when (prim) {
        is Prim.Ellipse -> {
            val topLeft = Offset((prim.x - prim.rx) * f, (prim.y - prim.ry) * f)
            val size = Size(2 * prim.rx * f, 2 * prim.ry * f)
            p.color(prim.fill)?.let { drawOval(it, topLeft, size, style = Fill) }
            p.color(prim.stroke)?.let {
                drawOval(it, topLeft, size, style = Stroke(width = if (prim.stroke == DiagramRole.ACCENT) 2.2f * f else 1.4f * f))
            }
        }
        is Prim.Polygon -> {
            if (prim.points.size < 4) return
            val path = polyPath(prim.points, close = true)
            p.color(prim.fill)?.let { drawPath(path, it, style = Fill) }
            p.color(prim.stroke)?.let { drawPath(path, it, style = stroke) }
        }
        is Prim.Polyline -> {
            if (prim.points.size < 4) return
            p.color(prim.stroke)?.let {
                drawPath(polyPath(prim.points, close = false), it, style = Stroke(width = prim.width * f, join = StrokeJoin.Round))
            }
        }
        is Prim.Bezier -> {
            val c = prim.points
            if (c.size < 8) return
            val path = Path().apply {
                moveTo(c[0] * f, c[1] * f)
                var i = 2
                while (i + 5 < c.size) {
                    cubicTo(c[i] * f, c[i + 1] * f, c[i + 2] * f, c[i + 3] * f, c[i + 4] * f, c[i + 5] * f)
                    i += 6
                }
            }
            val effect = if (prim.dashed) PathEffect.dashPathEffect(floatArrayOf(5f * f, 4f * f)) else null
            p.color(prim.stroke)?.let { drawPath(path, it, style = Stroke(width = 1.3f * f, pathEffect = effect)) }
        }
        is Prim.Label -> {
            val color = p.color(prim.color) ?: return
            val layout = measurer.measure(
                prim.text,
                TextStyle(
                    color = color,
                    fontSize = (prim.size * 0.92f * f / density / fontScale).sp,
                    fontFamily = if (prim.mono) FontFamily.Monospace else FontFamily.SansSerif,
                ),
            )
            val x = prim.x * f
            val left = when (prim.align) {
                'l' -> x
                'r' -> x - layout.size.width
                else -> x - layout.size.width / 2f
            }
            drawText(layout, topLeft = Offset(left, prim.y * f - layout.firstBaseline))
        }
    }
}
