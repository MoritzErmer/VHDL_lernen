package de.vhdllernen.app.data

import org.json.JSONArray
import org.json.JSONObject

/** A block-level element of a lesson text (rendered natively, never as HTML). */
sealed interface Node {
    data class Paragraph(val text: String) : Node
    data class Code(val code: String, val lang: String) : Node
    data class ListBlock(val items: List<String>, val ordered: Boolean) : Node
    data class Table(val rows: List<List<String>>) : Node
    /** A diagram as drawing primitives in diagram units (see tools/build_diagrams.py). */
    data class Diagram(val id: String, val alt: String, val width: Float, val height: Float, val prims: List<Prim>) : Node
}

/** Colour roles of diagram primitives; the app maps them to the current theme palette. */
enum class DiagramRole { INK, LINE, ACCENT, SOFT, SURFACE, GRID }

sealed interface Prim {
    data class Ellipse(val x: Float, val y: Float, val rx: Float, val ry: Float, val stroke: DiagramRole?, val fill: DiagramRole?) : Prim
    data class Polygon(val points: FloatArray, val stroke: DiagramRole?, val fill: DiagramRole?) : Prim
    data class Polyline(val points: FloatArray, val stroke: DiagramRole?, val width: Float) : Prim
    /** Cubic Bezier chain: start point, then three points per segment. */
    data class Bezier(val points: FloatArray, val stroke: DiagramRole?, val dashed: Boolean) : Prim
    data class Label(val x: Float, val y: Float, val text: String, val align: Char, val size: Float, val color: DiagramRole?, val mono: Boolean) : Prim
}

enum class AnswerMode { CODE, TEXT }

data class Block(val id: String, val name: String)

data class Lesson(
    val id: String,
    val block: String,
    val title: String,
    val minutes: Int,
    val mode: AnswerMode,
    val starter: String,
    val solutionCode: String,
    val ziel: List<Node>,
    val erklaerung: List<Node>,
    val aufgabe: List<Node>,
    val aufgabeMd: String,
    val loesung: List<Node>,
    val loesungMd: String,
    val klausur: List<Node>,
)

/** Newest app release, added to the downloaded content by the release workflow. */
data class AppRelease(val versionCode: Long, val versionName: String, val url: String)

/** One subject (VHDL, Rechnerarchitektur) with its own blocks, lessons and progress. */
data class Course(
    val id: String,
    val name: String,
    val exam: String,
    /** Code language of the answers: "vhdl" or "ikr" (IKR RISC II assembler). */
    val lang: String,
    val blocks: List<Block>,
    val lessons: List<Lesson>,
) {
    private val index = lessons.withIndex().associate { it.value.id to it.index }
    fun lesson(id: String): Lesson? = index[id]?.let { lessons[it] }
    fun previous(id: String): Lesson? = index[id]?.let { lessons.getOrNull(it - 1) }
    fun next(id: String): Lesson? = index[id]?.let { lessons.getOrNull(it + 1) }
    fun blockName(id: String): String = blocks.firstOrNull { it.id == id }?.name ?: id
    /** Key for the progress store, e.g. "vhdl:C02". */
    fun key(lessonId: String) = "$id:$lessonId"
}

data class Content(
    val schema: Int,
    val version: String,
    /** Publication time (epoch seconds) set by the workflows; 0 for local builds. Higher wins. */
    val revision: Long,
    val courses: List<Course>,
    val app: AppRelease?,
) {
    fun course(id: String): Course? = courses.firstOrNull { it.id == id }
    val lessonCount get() = courses.sumOf { it.lessons.size }
}

class ContentFormatException(message: String) : Exception(message)

/** Parses and validates content/haeppchen.json. Rejects anything unexpected instead of guessing. */
object ContentParser {
    const val SUPPORTED_SCHEMA = 1
    private val ID = Regex("^[A-Z]\\d\\d$")
    private val COURSE_ID = Regex("^[a-z]{1,16}$")
    private const val MAX_TEXT = 20_000

    fun parse(json: String): Content {
        val root = try {
            JSONObject(json)
        } catch (e: Exception) {
            throw ContentFormatException("Kein gültiges JSON")
        }
        val schema = root.optInt("schema", -1)
        if (schema != SUPPORTED_SCHEMA) throw ContentFormatException("Inhaltsformat $schema wird nicht unterstützt")
        val courses = root.getJSONArray("courses").objects().map(::course)
        if (courses.isEmpty() || courses.any { it.lessons.isEmpty() }) throw ContentFormatException("Keine Häppchen enthalten")
        if (courses.map { it.id }.toSet().size != courses.size) throw ContentFormatException("Doppelte Fächer")
        val app = root.optJSONObject("app")?.let {
            val url = it.optString("url")
            if (!url.startsWith("https://github.com/")) null
            else AppRelease(it.optLong("versionCode"), it.optString("versionName").take(40), url)
        }
        return Content(
            schema = schema,
            version = root.str("version", 64),
            revision = root.optLong("revision", 0),
            courses = courses,
            app = app,
        )
    }

    private fun course(o: JSONObject): Course {
        val id = o.str("id", 16)
        if (!COURSE_ID.matches(id)) throw ContentFormatException("Ungültiges Fach '$id'")
        val lessons = o.getJSONArray("items").objects().map(::lesson)
        if (lessons.map { it.id }.toSet().size != lessons.size) throw ContentFormatException("Doppelte Häppchen-IDs")
        return Course(
            id = id,
            name = o.str("name", 60),
            exam = o.str("exam", 120),
            lang = o.str("lang", 10),
            blocks = o.getJSONArray("blocks").objects().map { Block(it.str("id", 2), it.str("name", 200)) },
            lessons = lessons,
        )
    }

    private fun lesson(o: JSONObject): Lesson {
        val id = o.str("id", 3)
        if (!ID.matches(id)) throw ContentFormatException("Ungültige ID '$id'")
        return Lesson(
            id = id,
            block = o.str("block", 1),
            title = o.str("title", 200),
            minutes = o.optInt("min", 5).coerceIn(1, 60),
            mode = if (o.optString("mode") == "code") AnswerMode.CODE else AnswerMode.TEXT,
            starter = o.str("starter"),
            solutionCode = o.str("solutionCode"),
            ziel = nodes(o.optJSONArray("ziel")),
            erklaerung = nodes(o.optJSONArray("erklaerung")),
            aufgabe = nodes(o.optJSONArray("aufgabe")),
            aufgabeMd = o.str("aufgabeMd"),
            loesung = nodes(o.optJSONArray("loesung")),
            loesungMd = o.str("loesungMd"),
            klausur = nodes(o.optJSONArray("klausur")),
        )
    }

    private fun nodes(arr: JSONArray?): List<Node> = arr?.objects()?.mapNotNull { n ->
        when (n.optString("t")) {
            "p" -> Node.Paragraph(n.str("s"))
            "code" -> Node.Code(n.str("s"), n.str("lang", 20))
            "ul", "ol" -> Node.ListBlock(n.getJSONArray("items").strings(), ordered = n.optString("t") == "ol")
            "table" -> Node.Table(n.getJSONArray("rows").let { rows -> (0 until rows.length()).map { rows.getJSONArray(it).strings() } })
            "diagram" -> diagram(n)
            else -> null // unknown node types from newer content are skipped, not fatal
        }
    } ?: emptyList()

    private fun diagram(n: JSONObject): Node.Diagram? {
        val w = n.optDouble("w", 0.0).toFloat()
        val h = n.optDouble("h", 0.0).toFloat()
        val raw = n.optJSONArray("prims") ?: return null
        if (w !in 1f..4000f || h !in 1f..4000f || raw.length() > MAX_PRIMS) return null
        val prims = raw.objects().mapNotNull { p ->
            fun role(key: String) = when (p.optString(key)) {
                "ink" -> DiagramRole.INK; "line" -> DiagramRole.LINE; "accent" -> DiagramRole.ACCENT
                "soft" -> DiagramRole.SOFT; "surface" -> DiagramRole.SURFACE; "grid" -> DiagramRole.GRID
                else -> null
            }
            fun f(key: String) = p.optDouble(key, 0.0).toFloat()
            fun pts(): FloatArray? = p.optJSONArray("pts")?.let { a ->
                if (a.length() % 2 != 0 || a.length() > 400) null else FloatArray(a.length()) { a.optDouble(it).toFloat() }
            }
            when (p.optString("k")) {
                "E" -> Prim.Ellipse(f("x"), f("y"), f("rx"), f("ry"), role("s"), role("f"))
                "P" -> pts()?.let { Prim.Polygon(it, role("s"), role("f")) }
                "L" -> pts()?.let { Prim.Polyline(it, role("s"), p.optDouble("w", 1.4).toFloat()) }
                "B" -> pts()?.takeIf { (it.size - 2) % 6 == 0 }?.let { Prim.Bezier(it, role("s"), p.optInt("d") == 1) }
                "T" -> Prim.Label(f("x"), f("y"), p.str("s", 200), p.optString("a", "c").firstOrNull() ?: 'c',
                    f("z").coerceIn(6f, 30f), role("c"), p.optBoolean("m"))
                else -> null
            }
        }
        return Node.Diagram(n.str("id", 64), n.str("alt", 300), w, h, prims)
    }

    private const val MAX_PRIMS = 2000

    private fun JSONObject.str(key: String, max: Int = MAX_TEXT): String = optString(key, "").take(max)
    private fun JSONArray.strings(): List<String> = (0 until length()).map { optString(it).take(MAX_TEXT) }
    private fun JSONArray.objects(): List<JSONObject> = (0 until length()).mapNotNull { optJSONObject(it) }
}
