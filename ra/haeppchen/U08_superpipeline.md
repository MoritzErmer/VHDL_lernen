# U08 · Superpipeline: schneller getaktet, mehr Wartezeit

12 min · zurück: [U07](U07_pipeline_abh.md) · weiter: [U09](U09_lru_hand.md)

## Ziel
Abschätzen, was das Aufteilen von Pipeline-Stufen an Wartetakten kostet.

## Erklärung
Nach **Übung 1, Aufgabe 1.1 F4–F8** (sinngemäß): Um höher takten zu können, wird die Pipeline auf 8 Stufen verlängert:
- Befehls-Cache auf 2 Stufen, Daten-Cache auf **3** Stufen aufgeteilt,
- ein Multiplizierwerk mit **3** Stufen parallel zur ALU (Stufe 4).

Folgen für die Latenzen (Abstand, ab dem ein abhängiger Befehl ohne Warten folgen kann):
- ALU-Ergebnis: nach Stufe 4 → direkt nachfolgender Befehl, kein Wartetakt.
- Multiplikation: Ergebnis nach Stufe 6 → ein direkt abhängiger Befehl wartet **2** Takte.
- Load: Ergebnis nach Stufe 7 → ein direkt abhängiger Befehl wartet **3** Takte.
- Zwei Stufen beim Holen: Sprünge werden später erkannt → mehr Straftakte bei falsch vorhergesagten Sprüngen.

## Aufgabe
1. Gib eine Folge von `mulu`-Befehlen mit 1 Takt pro Befehl an und eine mit 3 Takten pro Befehl.
2. Wie viele Takte braucht der FIR-Ausschnitt aus U07 in der 8-stufigen Pipeline (7 Takte Auslauf)?
3. Um wie viel Prozent muss die Superpipeline höher getaktet werden, damit sie genauso schnell ist wie die 5-stufige Pipeline (19 Takte)?

<details><summary>Lösung</summary>

1. Unabhängig: `mulu r1 := r2,r3`, `mulu r4 := r5,r6`, `mulu r7 := r8,r9` → 1 Takt pro Befehl. Abhängige Kette: `mulu r1 := r1,r2`, `mulu r1 := r1,r3`, … → jeder wartet 2 Takte auf den Vorgänger, also 3 Takte pro Befehl.
2. Pro Block: `ldd r7` → `mulu`: 3 Wartetakte, `mulu` → `add`: 2 Wartetakte, zusammen 5. Drei Blöcke: 15 Wartetakte. 12 + 15 + 7 = **34 Takte**.
3. 34 / 19 ≈ 1,79 → etwa **79 % höher** takten, nur um gleichzuziehen. Superpipelining lohnt sich nur, wenn der Code genug unabhängige Befehle zwischen Erzeuger und Verbraucher hat oder der Compiler entsprechend umsortiert.
</details>

## Klausur
**Ü1 A1.1 F4, F5, F8.** Pipeline-Latenzen und Takte ausrechnen. Das Modell (Latenzen je Einheit) steht in der Klausur immer im Aufgabentext. Erst lesen, dann rechnen.
