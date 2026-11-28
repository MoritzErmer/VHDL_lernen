# U07 · Datenabhängigkeiten im FIR-Filter

10 min · zurück: [U06](U06_gol_runde.md) · weiter: [U08](U08_superpipeline.md)

## Ziel
Direkte Datenabhängigkeiten finden und entscheiden, ob sie in der 5-stufigen Pipeline stören.

## Erklärung
Nach **Übung 1, Aufgabe 1.1** (sinngemäß): Der IKR RISC II bekommt einen Befehl `mulu rc := rb,ra` (vorzeichenlose Multiplikation, untere Hälfte des Produkts). Er passt ins Format der anderen Dreiregister-Befehle wie `add`: neuer Opcode bzw. Funktionscode, sonst Felder für `rc`, `rb`, `ra` an denselben Stellen.

Programmausschnitt (Teil eines FIR-Filters):
```ikr
1  ldd  r6 := (r1,0)
2  ldd  r7 := (r2,0)
3  mulu r6 := r6,r7
4  add  r4 := r4,r6
5  ldd  r6 := (r1,1)
6  ldd  r7 := (r2,1)
7  mulu r6 := r6,r7
8  add  r4 := r4,r6
9  ldd  r6 := (r1,2)
10 ldd  r7 := (r2,2)
11 mulu r6 := r6,r7
12 add  r4 := r4,r6
```
Pipeline-Modell wie im Spickzettel: Ergebnisse von ALU-Befehlen werden geforwardet (kein Verlust). Braucht ein Befehl ein Ladeergebnis direkt im nächsten Befehl (Read after Load), gibt es **1 Bubble**. `mulu` braucht wie alle ALU-Befehle einen Takt.

## Aufgabe
1. Gib alle direkten Datenabhängigkeiten an (Register, schreibende Zeile, lesende Zeile).
2. Welche führen zu einer Blockierung?
3. Wie viele Takte braucht der Ausschnitt (Caches ideal, 4 Takte Pipeline-Auslauf mitgezählt)?

<details><summary>Lösung</summary>

1. Pro Block gleich, also dreimal:

| Register | schreibt | liest |
|---|---|---|
| r6 | 1 | 3 |
| r7 | 2 | 3 |
| r6 | 3 | 4 |
| r6 | 5 | 7 |
| r7 | 6 | 7 |
| r6 | 7 | 8 |
| r6 | 9 | 11 |
| r7 | 10 | 11 |
| r6 | 11 | 12 |
| r4 | 4 | 8 |
| r4 | 8 | 12 |

2. Nur **r7 von 2 nach 3**, 6 nach 7 und 10 nach 11: Das Ladeergebnis wird direkt im nächsten Befehl gebraucht (Read after Load), je **1 Bubble**. r6 von 1 nach 3 hat einen Befehl Abstand und wird geforwardet. `mulu` → `add` ist ALU → ALU, also Forwarding ohne Verlust.
3. 12 Befehle + 3 Bubbles + 4 = **19 Takte**.
</details>

## Klausur
**Ü1 A1.1 F2/F3.** Abhängigkeiten tabellarisch angeben ist ein häufiger Klausurtyp. Prüfe es im Simulator mit `add` statt `mulu`.
