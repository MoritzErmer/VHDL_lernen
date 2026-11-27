package de.vhdllernen.app

import android.graphics.Bitmap
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.Rating
import de.vhdllernen.app.data.ThemeMode
import org.junit.Assume.assumeTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File

/**
 * Renders the main screens to PNG files in docs/screenshots (Robolectric native graphics, no emulator).
 * Only runs with `-Pscreenshots`: ./gradlew :app:testDebugUnitTest -Pscreenshots
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w400dp-h1600dp-xhdpi")
class ScreenshotTest {

    @get:Rule
    val compose = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun screens() {
        assumeTrue(System.getProperty("screenshots") == "true")
        val dir = File(System.getProperty("screenshotDir") ?: "build/screenshots").apply { mkdirs() }
        val state = AppState(compose.activity.application)
        state.progress.reset()
        // Example progress so the screens show their working state.
        val ratings = listOf(Rating.ONE, Rating.ONE, Rating.ONE, Rating.X, Rating.ONE, Rating.ZERO, Rating.ONE, Rating.ONE, Rating.X)
        state.content.course("vhdl")!!.lessons.take(ratings.size).forEachIndexed { i, l ->
            state.progress.update("vhdl:${l.id}") { it.copy(rating = ratings[i]) }
        }
        state.progress.update("ra:A01") { it.copy(rating = Rating.ONE) }
        state.progress.update("vhdl:A03") {
            Progress(
                answer = "architecture behav of single_step is\nbegin\n  d(4 downto 3) <= q(3 downto 2);\n" +
                    "  d(2) <= q(4) xor s xor q(1);\n  d(0) <= q(4) and s;\nend architecture behav;",
                rating = Rating.X, question = "Darf ich d(1) auch in einen Prozess schreiben?", revealed = true,
            )
        }
        compose.setContent { VhdlApp(state) }

        fun shot(name: String, theme: ThemeMode, vararg screens: Screen) {
            compose.runOnUiThread {
                state.changeSettings { it.copy(theme = theme, openBlocks = setOf("vhdl:A")) }
                state.stack.clear()
                state.stack.addAll(screens)
            }
            compose.waitForIdle()
            val content = compose.activity.window.decorView.findViewById<android.view.ViewGroup>(android.R.id.content)
            val bitmap = Bitmap.createBitmap(content.width, content.height, Bitmap.Config.ARGB_8888)
            content.draw(android.graphics.Canvas(bitmap))
            File(dir, "$name.png").outputStream().use { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }
        }

        shot("1-faecher", ThemeMode.LIGHT, Screen.Courses)
        shot("2-vhdl-uebersicht", ThemeMode.LIGHT, Screen.Courses, Screen.Home("vhdl"))
        shot("3-haeppchen-abgleich", ThemeMode.LIGHT, Screen.Courses, Screen.Lesson("vhdl", "A03"))
        shot("4-haeppchen-dunkel", ThemeMode.DARK, Screen.Courses, Screen.Lesson("vhdl", "C02"))
        shot("5-ra-haeppchen", ThemeMode.LIGHT, Screen.Courses, Screen.Lesson("ra", "B06"))
        shot("6-export", ThemeMode.DARK, Screen.Courses, Screen.Export("vhdl"))
        shot("7-einstellungen", ThemeMode.LIGHT, Screen.Courses, Screen.Info)
        state.progress.reset()
    }
}
