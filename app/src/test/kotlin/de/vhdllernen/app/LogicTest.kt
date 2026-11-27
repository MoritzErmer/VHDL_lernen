package de.vhdllernen.app

import de.vhdllernen.app.data.ContentFormatException
import de.vhdllernen.app.data.ContentParser
import de.vhdllernen.app.data.Progress
import de.vhdllernen.app.data.Rating
import de.vhdllernen.app.logic.Compare
import de.vhdllernen.app.logic.Export
import de.vhdllernen.app.logic.ExportOptions
import de.vhdllernen.app.logic.ExportScope
import de.vhdllernen.app.logic.IkrLexer
import de.vhdllernen.app.logic.Inline
import de.vhdllernen.app.logic.InlineParser
import de.vhdllernen.app.logic.TokenKind
import de.vhdllernen.app.logic.VhdlLexer
import de.vhdllernen.app.ui.autoIndent
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class LogicTest {
    private val content by lazy { ContentParser.parse(File(System.getProperty("contentFile")!!).readText()) }

    private fun kinds(src: String, lexer: (String) -> List<de.vhdllernen.app.logic.Token>) =
        lexer(src).map { src.substring(it.start, it.end) to it.kind }

    @Test
    fun vhdlLexerSeparatesCharLiteralsFromAttributes() {
        val t = kinds("if clk'event and clk = '1' then -- Flanke", VhdlLexer::tokenize)
        assertTrue("if" to TokenKind.KEYWORD in t)
        assertTrue("event" to TokenKind.ATTRIBUTE in t)
        assertTrue("'1'" to TokenKind.STRING in t)
        assertTrue("-- Flanke" to TokenKind.COMMENT in t)
        assertFalse(t.any { it.first == "clk" }) // plain identifiers stay uncoloured
    }

    @Test
    fun vhdlLexerHandlesQualifiedExpressionsAndBitStrings() {
        val t = kinds("y <= unsigned'('0' & a) + x\"F0\";", VhdlLexer::tokenize)
        assertTrue("unsigned" to TokenKind.TYPE in t)
        assertTrue("'0'" to TokenKind.STRING in t)
        assertTrue("x\"F0\"" to TokenKind.STRING in t)
        assertTrue("<=" to TokenKind.OPERATOR in t)
    }

    @Test
    fun ikrLexerRecognisesLabelsMnemonicsRegistersAndConstants() {
        val t = kinds("loop: addi r1 := r1,#-1   ; Zähler\n      beq  r2,ret\n.reg r1 = \$100", IkrLexer::tokenize)
        assertTrue("loop" to TokenKind.FUNCTION in t)
        assertTrue("addi" to TokenKind.KEYWORD in t)
        assertTrue("r1" to TokenKind.TYPE in t)
        assertTrue("#-1" to TokenKind.NUMBER in t)
        assertTrue("; Zähler" to TokenKind.COMMENT in t)
        assertTrue("beq" to TokenKind.KEYWORD in t)
        assertFalse(t.any { it.first == "ret" }) // label reference
        assertTrue(".reg" to TokenKind.LITERAL in t)
        assertTrue("\$100" to TokenKind.NUMBER in t)
    }

    @Test
    fun compareIgnoresLineBreaksCaseCommentsAndStatementOrder() {
        val solution = "s <= a xor b;\nc <= a and b;"
        val answer = "C <=\n  A AND B;   -- Uebertrag\ns <= a\n xor b ;"
        val r = Compare.run(answer, solution)
        assertEquals(r.solutionTotal, r.solutionFound)
        assertEquals(0, r.answerWrong)
    }

    @Test
    fun compareMarksExactlyTheWrongTokens() {
        // the learner's answer from the A02 screenshot: wrong package number, wrong bound, missing semicolons
        val solution = "library ieee; use ieee.std_logic_1164.all;\n\nentity priorityencoder_4_bit is\n  port(\n" +
            "    e : in  std_logic_vector(3 downto 0);\n    v : out std_logic;\n    a : out std_logic_vector(1 downto 0)\n" +
            "    );\nend entity priorityencoder_4_bit;"
        val answer = "library ieee; use\nieee.std_logic_1146.all;\n\nentity priorityencoder_4_bit is\n  port(\n" +
            "    e:in std_logic_vector(3 downto 1)\n    v: out std_logic\n    a: out std_logic_vector(1 downto 0)\n" +
            "    );\n    end entity priorityencoder_4_bit;"
        val r = Compare.run(answer, solution)
        val wrong = r.answer.filter { !it.ok }.map { answer.substring(it.start, it.end) }
        val missing = r.solution.filter { !it.ok }.map { solution.substring(it.start, it.end) }
        assertEquals(listOf("std_logic_1146", "1"), wrong)
        assertEquals(listOf("std_logic_1164", "0", ";", ";"), missing)
    }

    @Test
    fun compareUsesLinesAndSemicolonCommentsForAssembler() {
        val r = Compare.run("add r3 := r0,r0 ; null", "add  r3 := r0,r0      ; Summe = 0", "ikr")
        assertEquals(r.solutionTotal, r.solutionFound)
    }

    @Test
    fun autoIndentKeepsAndIncreasesIndentation() {
        val old = TextFieldValue("  if a = '1' then", TextRange(17))
        val new = TextFieldValue("  if a = '1' then\n", TextRange(18))
        val r = autoIndent(old, new)
        assertEquals("  if a = '1' then\n    ", r.text)
        assertEquals(TextRange(22), r.selection)
    }

    @Test
    fun inlineParserFindsBoldCodeAndLinks() {
        val parts = InlineParser.parse("**Wichtig:** `q <= d;` siehe [D01](#D01)")
        assertEquals(Inline.Text("Wichtig:", bold = true), parts[0])
        assertTrue(Inline.Code("q <= d;") in parts)
        assertTrue(Inline.Link("D01", "#D01") in parts)
    }

    @Test
    fun bundledContentHasBothCoursesWithSolutions() {
        val vhdl = content.course("vhdl")!!
        assertTrue(vhdl.lessons.size >= 70)
        assertTrue(content.course("ra")?.lessons?.isNotEmpty() == true)
        content.courses.forEach { c ->
            c.lessons.forEach { l ->
                assertTrue("${c.id}/${l.id} ohne Lösung", l.loesung.isNotEmpty())
                assertTrue("${c.id}/${l.id} ohne Aufgabe", l.aufgabe.isNotEmpty())
                assertTrue("${c.id}/${l.id} Block fehlt", c.blocks.any { it.id == l.block })
            }
        }
        assertEquals("C08", vhdl.next("C07")?.id)
    }

    @Test
    fun diagramsAreParsedWithPrimitives() {
        val f02 = content.course("vhdl")!!.lesson("F02")!!
        val d = f02.erklaerung.filterIsInstance<de.vhdllernen.app.data.Node.Diagram>().single()
        assertEquals("F02_moore", d.id)
        assertTrue(d.width > 100f && d.height > 50f)
        val labels = d.prims.filterIsInstance<de.vhdllernen.app.data.Prim.Label>().map { it.text }
        assertTrue("s101" in labels)
        assertTrue(d.prims.any { it is de.vhdllernen.app.data.Prim.Bezier })
        val all = content.courses.flatMap { c -> c.lessons }.flatMap { l -> l.erklaerung + l.aufgabe + l.loesung }
        assertTrue(all.count { it is de.vhdllernen.app.data.Node.Diagram } >= 25)
    }

    @Test(expected = ContentFormatException::class)
    fun parserRejectsUnknownSchema() {
        ContentParser.parse("""{"schema": 99, "courses": []}""")
    }

    @Test
    fun parserIgnoresNonGithubAppLinks() {
        val json = File(System.getProperty("contentFile")!!).readText()
            .replaceFirst("{", """{"app": {"versionCode": 9, "versionName": "x", "url": "https://evil.example/app.apk"},""")
        assertEquals(null, ContentParser.parse(json).app)
    }

    @Test
    fun exportContainsAnswerQuestionAndRating() {
        val course = content.course("vhdl")!!
        val progress = mapOf(
            course.key("A03") to Progress(answer = "d(1) <= q(0);", rating = Rating.X, question = "Warum Slices?"),
            course.key("A01") to Progress(rating = Rating.ONE),
        )
        val all = Export.build(course, progress, ExportOptions(), "27.11.2026")
        assertTrue(all.contains("## A03 · "))
        assertTrue(all.contains("```vhdl\nd(1) <= q(0);\n```"))
        assertTrue(all.contains("Warum Slices?"))
        assertTrue(all.contains("Selbsteinschätzung: X (unsicher)"))
        val review = Export.build(course, progress, ExportOptions(scope = ExportScope.REVIEW), "27.11.2026")
        assertFalse(review.contains("## A01 · "))
        assertTrue(review.contains("## A03 · "))
    }
}
