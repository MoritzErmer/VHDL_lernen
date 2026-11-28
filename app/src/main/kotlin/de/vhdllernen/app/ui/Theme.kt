package de.vhdllernen.app.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import android.os.Build
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.ui.platform.LocalContext
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
 * App colours, derived from a Material 3 colour scheme (Material You). On Android 12+ the scheme can come
 * from the wallpaper. Status colours follow the std_logic values of the self assessment (U/1/X/0) and
 * stay fixed so that 1/X/0 always look the same.
 */
@Immutable
data class Palette(
    val bg: Color,
    val surface: Color,
    val container: Color,
    val sunken: Color,
    val ink: Color,
    val muted: Color,
    val line: Color,
    val outline: Color,
    val accent: Color,
    val onAccent: Color,
    val accentSoft: Color,
    val onAccentSoft: Color,
    val secondarySoft: Color,
    val onSecondarySoft: Color,
    val tertiary: Color,
    val onTertiary: Color,
    val tertiarySoft: Color,
    val onTertiarySoft: Color,
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

private val lightSyntax = mapOf(

        TokenKind.KEYWORD to Color(0xFF2A3FB0),
        TokenKind.TYPE to Color(0xFF0B7468),
        TokenKind.FUNCTION to Color(0xFF7A3BB0),
        TokenKind.LITERAL to Color(0xFF8A5A00),
        TokenKind.STRING to Color(0xFFA2421A),
        TokenKind.NUMBER to Color(0xFFA2421A),
        TokenKind.COMMENT to Color(0xFF6E7887),
        TokenKind.ATTRIBUTE to Color(0xFF7A3BB0),
        TokenKind.OPERATOR to Color(0xFF4A5363),
)

private val darkSyntax = mapOf(

        TokenKind.KEYWORD to Color(0xFF93AAFF),
        TokenKind.TYPE to Color(0xFF5FD0BE),
        TokenKind.FUNCTION to Color(0xFFC79BF2),
        TokenKind.LITERAL to Color(0xFFE5C07B),
        TokenKind.STRING to Color(0xFFF0A27A),
        TokenKind.NUMBER to Color(0xFFF0A27A),
        TokenKind.COMMENT to Color(0xFF7D8796),
        TokenKind.ATTRIBUTE to Color(0xFFC79BF2),
        TokenKind.OPERATOR to Color(0xFFAAB3C0),
)

/** Fallback scheme (Android below 12 or wallpaper colours switched off): indigo, with teal as tertiary. */
val LightScheme = lightColorScheme(
    primary = Color(0xFF4355B9), onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFDEE0FF), onPrimaryContainer = Color(0xFF00105C),
    secondary = Color(0xFF5B5D72), onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFE0E1F9), onSecondaryContainer = Color(0xFF181A2C),
    tertiary = Color(0xFF006A60), onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFF9EF2E4), onTertiaryContainer = Color(0xFF00201C),
    background = Color(0xFFFBF8FF), onBackground = Color(0xFF1B1B21),
    surface = Color(0xFFFBF8FF), onSurface = Color(0xFF1B1B21),
    surfaceVariant = Color(0xFFE3E1EC), onSurfaceVariant = Color(0xFF46464F),
    surfaceContainerLowest = Color(0xFFFFFFFF), surfaceContainerLow = Color(0xFFF5F2FA),
    surfaceContainer = Color(0xFFEFEDF4), surfaceContainerHigh = Color(0xFFE9E7EF),
    surfaceContainerHighest = Color(0xFFE4E1E9),
    outline = Color(0xFF767680), outlineVariant = Color(0xFFC6C5D0),
    error = Color(0xFFBA1A1A),
)

val DarkScheme = darkColorScheme(
    primary = Color(0xFFBAC3FF), onPrimary = Color(0xFF08218A),
    primaryContainer = Color(0xFF293CA0), onPrimaryContainer = Color(0xFFDEE0FF),
    secondary = Color(0xFFC3C5DD), onSecondary = Color(0xFF2D2F42),
    secondaryContainer = Color(0xFF434659), onSecondaryContainer = Color(0xFFE0E1F9),
    tertiary = Color(0xFF82D5C8), onTertiary = Color(0xFF003731),
    tertiaryContainer = Color(0xFF005048), onTertiaryContainer = Color(0xFF9EF2E4),
    background = Color(0xFF121318), onBackground = Color(0xFFE4E1E9),
    surface = Color(0xFF121318), onSurface = Color(0xFFE4E1E9),
    surfaceVariant = Color(0xFF46464F), onSurfaceVariant = Color(0xFFC6C5D0),
    surfaceContainerLowest = Color(0xFF0D0E13), surfaceContainerLow = Color(0xFF1B1B21),
    surfaceContainer = Color(0xFF1F1F25), surfaceContainerHigh = Color(0xFF292A2F),
    surfaceContainerHighest = Color(0xFF34343A),
    outline = Color(0xFF90909A), outlineVariant = Color(0xFF46464F),
    error = Color(0xFFFFB4AB),
)

fun paletteFrom(c: ColorScheme, dark: Boolean) = Palette(
    bg = c.surface,
    surface = c.surfaceContainerLow,
    container = c.surfaceContainer,
    sunken = c.surfaceContainerHighest,
    ink = c.onSurface,
    muted = c.onSurfaceVariant,
    line = c.outlineVariant,
    outline = c.outline,
    accent = c.primary,
    onAccent = c.onPrimary,
    accentSoft = c.primaryContainer,
    onAccentSoft = c.onPrimaryContainer,
    secondarySoft = c.secondaryContainer,
    onSecondarySoft = c.onSecondaryContainer,
    tertiary = c.tertiary,
    onTertiary = c.onTertiary,
    tertiarySoft = c.tertiaryContainer,
    onTertiarySoft = c.onTertiaryContainer,
    ok = if (dark) Color(0xFF6DD58C) else Color(0xFF1E7D47),
    warn = if (dark) Color(0xFFF2B84B) else Color(0xFF9A5B00),
    bad = if (dark) Color(0xFFFFB4AB) else Color(0xFFBA1A1A),
    syntax = if (dark) darkSyntax else lightSyntax,
    dark = dark,
)

val LightPalette = paletteFrom(LightScheme, dark = false)
val DarkPalette = paletteFrom(DarkScheme, dark = true)

val LocalPalette = staticCompositionLocalOf { LightPalette }

/** Each subject gets its own colour role: VHDL uses primary, Rechnerarchitektur tertiary. */
@Composable
fun CourseTheme(course: String, content: @Composable () -> Unit) {
    val base = LocalPalette.current
    val p = if (course == "ra") base.copy(
        accent = base.tertiary, onAccent = base.onTertiary,
        accentSoft = base.tertiarySoft, onAccentSoft = base.onTertiarySoft,
    ) else base
    CompositionLocalProvider(LocalPalette provides p, content = content)
}

object Type {
    val mono = FontFamily.Monospace
    val title = TextStyle(fontSize = 26.sp, lineHeight = 32.sp, fontWeight = FontWeight.Normal)
    val topBar = TextStyle(fontSize = 22.sp, lineHeight = 28.sp, fontWeight = FontWeight.Normal)
    val section = TextStyle(fontSize = 14.sp, lineHeight = 20.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.1.sp)
    val body = TextStyle(fontSize = 16.sp, lineHeight = 24.sp)
    val small = TextStyle(fontSize = 13.sp, lineHeight = 18.sp)
    val code = TextStyle(fontFamily = mono, fontSize = 13.5.sp, lineHeight = 20.sp)
    val label = TextStyle(fontFamily = mono, fontSize = 12.sp, lineHeight = 16.sp, fontWeight = FontWeight.Medium)
}

@Composable
fun VhdlTheme(mode: ThemeMode, dynamicColor: Boolean, content: @Composable () -> Unit) {
    val dark = when (mode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    val context = LocalContext.current
    val scheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
            if (dark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        dark -> DarkScheme
        else -> LightScheme
    }
    CompositionLocalProvider(LocalPalette provides paletteFrom(scheme, dark)) {
        MaterialTheme(colorScheme = scheme, content = content)
    }
}

/** True when the wallpaper colours can be used (Android 12 and newer). */
val dynamicColorAvailable: Boolean get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
