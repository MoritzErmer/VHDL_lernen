package de.vhdllernen.app.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import de.vhdllernen.app.data.Rating
import de.vhdllernen.app.data.ThemeMode
import de.vhdllernen.app.logic.TokenKind

/**
 * Palette: cool, slightly blue-tinted neutrals like a data sheet, one cobalt accent.
 * Status colours follow the std_logic values used for the self assessment (U/1/X/0).
 */
@Immutable
data class Palette(
    val bg: Color,
    val surface: Color,
    val sunken: Color,
    val ink: Color,
    val muted: Color,
    val line: Color,
    val accent: Color,
    val onAccent: Color,
    val accentSoft: Color,
    val ok: Color,
    val warn: Color,
    val bad: Color,
    val syntax: Map<TokenKind, Color>,
    val dark: Boolean,
) {
    fun rating(r: Rating): Color = when (r) {
        Rating.U -> muted
        Rating.ONE -> ok
        Rating.X -> warn
        Rating.ZERO -> bad
    }
}

val LightPalette = Palette(
    bg = Color(0xFFF4F6FA),
    surface = Color(0xFFFFFFFF),
    sunken = Color(0xFFEBEFF5),
    ink = Color(0xFF151A22),
    muted = Color(0xFF5A6474),
    line = Color(0xFFD9DEE7),
    accent = Color(0xFF1F45C4),
    onAccent = Color(0xFFFFFFFF),
    accentSoft = Color(0xFFE3E9FB),
    ok = Color(0xFF1E7D47),
    warn = Color(0xFFA36508),
    bad = Color(0xFFB9372B),
    syntax = mapOf(
        TokenKind.KEYWORD to Color(0xFF2A3FB0),
        TokenKind.TYPE to Color(0xFF0B7468),
        TokenKind.FUNCTION to Color(0xFF7A3BB0),
        TokenKind.LITERAL to Color(0xFF8A5A00),
        TokenKind.STRING to Color(0xFFA2421A),
        TokenKind.NUMBER to Color(0xFFA2421A),
        TokenKind.COMMENT to Color(0xFF6E7887),
        TokenKind.ATTRIBUTE to Color(0xFF7A3BB0),
        TokenKind.OPERATOR to Color(0xFF4A5363),
    ),
    dark = false,
)

val DarkPalette = Palette(
    bg = Color(0xFF0E1116),
    surface = Color(0xFF161A21),
    sunken = Color(0xFF11151B),
    ink = Color(0xFFE5E9F0),
    muted = Color(0xFF97A1B0),
    line = Color(0xFF283040),
    accent = Color(0xFF8CA6FF),
    onAccent = Color(0xFF0B1230),
    accentSoft = Color(0xFF1E2848),
    ok = Color(0xFF58C88A),
    warn = Color(0xFFE3AA4F),
    bad = Color(0xFFF07467),
    syntax = mapOf(
        TokenKind.KEYWORD to Color(0xFF93AAFF),
        TokenKind.TYPE to Color(0xFF5FD0BE),
        TokenKind.FUNCTION to Color(0xFFC79BF2),
        TokenKind.LITERAL to Color(0xFFE5C07B),
        TokenKind.STRING to Color(0xFFF0A27A),
        TokenKind.NUMBER to Color(0xFFF0A27A),
        TokenKind.COMMENT to Color(0xFF7D8796),
        TokenKind.ATTRIBUTE to Color(0xFFC79BF2),
        TokenKind.OPERATOR to Color(0xFFAAB3C0),
    ),
    dark = true,
)

val LocalPalette = staticCompositionLocalOf { LightPalette }

/** Each subject gets its own accent (VHDL: cobalt, Rechnerarchitektur: teal) so the areas are easy to tell apart. */
fun courseAccent(course: String, dark: Boolean): Pair<Color, Color> = when (course) {
    "ra" -> if (dark) Color(0xFF4FD1B8) to Color(0xFF123A35) else Color(0xFF0B7A69) to Color(0xFFDDF2EE)
    else -> if (dark) DarkPalette.accent to DarkPalette.accentSoft else LightPalette.accent to LightPalette.accentSoft
}

@Composable
fun CourseTheme(course: String, content: @Composable () -> Unit) {
    val base = LocalPalette.current
    val (accent, soft) = courseAccent(course, base.dark)
    CompositionLocalProvider(LocalPalette provides base.copy(accent = accent, accentSoft = soft), content = content)
}

object Type {
    val mono = FontFamily.Monospace
    val title = TextStyle(fontSize = 24.sp, lineHeight = 30.sp, fontWeight = FontWeight.SemiBold, letterSpacing = (-0.2).sp)
    val section = TextStyle(fontSize = 13.sp, lineHeight = 16.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 1.1.sp)
    val body = TextStyle(fontSize = 16.sp, lineHeight = 24.sp)
    val small = TextStyle(fontSize = 13.sp, lineHeight = 18.sp)
    val code = TextStyle(fontFamily = mono, fontSize = 13.5.sp, lineHeight = 20.sp)
    val label = TextStyle(fontFamily = mono, fontSize = 12.sp, lineHeight = 16.sp, fontWeight = FontWeight.Medium)
}

@Composable
fun VhdlTheme(mode: ThemeMode, content: @Composable () -> Unit) {
    val dark = when (mode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    val p = if (dark) DarkPalette else LightPalette
    val scheme = if (dark) darkColorScheme(
        primary = p.accent, onPrimary = p.onAccent, background = p.bg, onBackground = p.ink,
        surface = p.surface, onSurface = p.ink, surfaceVariant = p.sunken, onSurfaceVariant = p.muted,
        outline = p.line, outlineVariant = p.line, error = p.bad,
    ) else lightColorScheme(
        primary = p.accent, onPrimary = p.onAccent, background = p.bg, onBackground = p.ink,
        surface = p.surface, onSurface = p.ink, surfaceVariant = p.sunken, onSurfaceVariant = p.muted,
        outline = p.line, outlineVariant = p.line, error = p.bad,
    )
    CompositionLocalProvider(LocalPalette provides p) {
        MaterialTheme(colorScheme = scheme, content = content)
    }
}
