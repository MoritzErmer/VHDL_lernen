package de.vhdllernen.app.data

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection

enum class ContentSource { BUNDLED, DOWNLOADED }

sealed interface UpdateResult {
    data class Updated(val content: Content, val newLessons: Int) : UpdateResult
    data class UpToDate(val content: Content) : UpdateResult
    data class Failed(val reason: String) : UpdateResult
}

/**
 * Loads the lessons. The APK contains a copy (offline from the first start); newer content is downloaded
 * from the latest GitHub release of this repository and cached in app storage.
 */
class ContentRepository(private val context: Context) {
    private val cache = File(context.filesDir, "haeppchen.json")

    fun loadBest(): Pair<Content, ContentSource> {
        val bundled = context.assets.open(ASSET).bufferedReader().use { ContentParser.parse(it.readText()) }
        val cached = runCatching { ContentParser.parse(cache.readText()) }.getOrNull()
        return if (cached != null && cached.revision > bundled.revision) cached to ContentSource.DOWNLOADED
        else bundled to ContentSource.BUNDLED
    }

    /** True when the active network is not metered (Wi-Fi, Ethernet) - used for automatic checks only. */
    fun onUnmeteredNetwork(): Boolean {
        val cm = context.getSystemService(ConnectivityManager::class.java) ?: return false
        val caps = cm.getNetworkCapabilities(cm.activeNetwork) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
            caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
    }

    suspend fun update(current: Content): UpdateResult = withContext(Dispatchers.IO) {
        try {
            val text = download(CONTENT_URL)
            val fresh = ContentParser.parse(text)
            if (fresh.revision <= current.revision) return@withContext UpdateResult.UpToDate(fresh.copy(app = fresh.app ?: current.app))
            val tmp = File(cache.parentFile, "haeppchen.json.tmp")
            tmp.writeText(text)
            if (!tmp.renameTo(cache)) throw IOException("Speichern fehlgeschlagen")
            val known = current.courses.flatMap { c -> c.lessons.map { c.key(it.id) } }.toSet()
            UpdateResult.Updated(fresh, fresh.courses.sumOf { c -> c.lessons.count { c.key(it.id) !in known } })
        } catch (e: ContentFormatException) {
            UpdateResult.Failed("Inhalt ungültig: ${e.message}")
        } catch (e: IOException) {
            UpdateResult.Failed("Keine Verbindung zu GitHub")
        }
    }

    private fun download(url: String, redirects: Int = 0): String {
        if (redirects > 5) throw IOException("Zu viele Weiterleitungen")
        val conn = URL(url).openConnection() as? HttpsURLConnection ?: throw IOException("Nur HTTPS erlaubt")
        conn.connectTimeout = 15_000
        conn.readTimeout = 20_000
        conn.instanceFollowRedirects = false
        conn.setRequestProperty("Accept", "application/octet-stream")
        try {
            val code = conn.responseCode
            if (code in 300..399) {
                val location = conn.getHeaderField("Location") ?: throw IOException("Weiterleitung ohne Ziel")
                if (!location.startsWith("https://")) throw IOException("Nur HTTPS erlaubt")
                return download(location, redirects + 1)
            }
            if (code != HttpURLConnection.HTTP_OK) throw IOException("HTTP $code")
            val bytes = conn.inputStream.use { input ->
                val out = java.io.ByteArrayOutputStream()
                val buf = ByteArray(16 * 1024)
                while (true) {
                    val n = input.read(buf)
                    if (n < 0) break
                    out.write(buf, 0, n)
                    if (out.size() > MAX_BYTES) throw IOException("Datei zu groß")
                }
                out.toByteArray()
            }
            return bytes.toString(Charsets.UTF_8)
        } finally {
            conn.disconnect()
        }
    }

    companion object {
        const val ASSET = "haeppchen.json"
        const val REPO_URL = "https://github.com/MoritzErmer/VHDL_lernen"
        const val CONTENT_URL = "$REPO_URL/releases/latest/download/haeppchen.json"
        const val RELEASES_URL = "$REPO_URL/releases/latest"
        private const val MAX_BYTES = 5 * 1024 * 1024
    }
}
