package de.vhdllernen.app.data

import android.content.Context

enum class ThemeMode(val label: String) { SYSTEM("System"), LIGHT("Hell"), DARK("Dunkel") }

data class AppSettings(
    val theme: ThemeMode = ThemeMode.SYSTEM,
    /** Check for new lessons automatically at start, but only on Wi-Fi (not on mobile data). */
    val autoUpdateOnWifi: Boolean = true,
    val lastCheck: Long = 0,
    val openBlocks: Set<String> = emptySet(),
    /** Material You: take the colours from the wallpaper (Android 12+). */
    val dynamicColor: Boolean = true,
)

class SettingsStore(context: Context) {
    private val prefs = context.getSharedPreferences("einstellungen", Context.MODE_PRIVATE)

    fun load() = AppSettings(
        theme = runCatching { ThemeMode.valueOf(prefs.getString("theme", null) ?: "") }.getOrDefault(ThemeMode.SYSTEM),
        autoUpdateOnWifi = prefs.getBoolean("autoUpdateOnWifi", true),
        lastCheck = prefs.getLong("lastCheck", 0),
        openBlocks = prefs.getStringSet("openBlocks", emptySet())?.toSet() ?: emptySet(),
        dynamicColor = prefs.getBoolean("dynamicColor", true),
    )

    fun save(s: AppSettings) {
        prefs.edit()
            .putString("theme", s.theme.name)
            .putBoolean("autoUpdateOnWifi", s.autoUpdateOnWifi)
            .putLong("lastCheck", s.lastCheck)
            .putStringSet("openBlocks", s.openBlocks)
            .putBoolean("dynamicColor", s.dynamicColor)
            .apply()
    }
}
