package de.vhdllernen.app.ui

import androidx.compose.foundation.ScrollState
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/**
 * Always visible scroll bars (Compose has none by default). Put it before the scroll modifier so the bars
 * are drawn on the visible area. Nothing is drawn when the content fits.
 */
fun Modifier.scrollbars(horizontal: ScrollState?, vertical: ScrollState?, track: Color, thumb: Color) =
    drawWithContent {
        drawContent()
        val t = 4.dp.toPx()
        val inset = 2.dp.toPx()
        val r = CornerRadius(t / 2, t / 2)
        if (horizontal != null && horizontal.maxValue in 1 until Int.MAX_VALUE) {
            val len = size.width - 2 * inset - (if (vertical != null && vertical.maxValue > 0) t + inset else 0f)
            val thumbLen = (len * len / (len + horizontal.maxValue)).coerceAtLeast(24.dp.toPx())
            val x = inset + (len - thumbLen) * horizontal.value / horizontal.maxValue
            val y = size.height - t - inset
            drawRoundRect(track, Offset(inset, y), Size(len, t), r)
            drawRoundRect(thumb, Offset(x, y), Size(thumbLen, t), r)
        }
        if (vertical != null && vertical.maxValue in 1 until Int.MAX_VALUE) {
            val len = size.height - 2 * inset
            val thumbLen = (len * len / (len + vertical.maxValue)).coerceAtLeast(24.dp.toPx())
            val y = inset + (len - thumbLen) * vertical.value / vertical.maxValue
            val x = size.width - t - inset
            drawRoundRect(track, Offset(x, inset), Size(t, len), r)
            drawRoundRect(thumb, Offset(x, y), Size(t, thumbLen), r)
        }
    }
