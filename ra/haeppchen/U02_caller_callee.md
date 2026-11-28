# U02 · Wer sichert die Register?

5 min · zurück: [U01](U01_stapel_warum.md) · weiter: [U03](U03_streq.md)

## Ziel
Die Vor- und Nachteile von Caller-Save und Callee-Save erklären und die Calling Convention des IKR RISC II anwenden.

## Erklärung
Nach **Übung 0, Aufgabe 0.1 F3/F4** (sinngemäß): Aufrufer und Unterprogramm nutzen dieselben Register. Wer rettet die Werte?

- **Nur das Unterprogramm sichert** (Callee-Save) jedes Register, das es ändert: Es weiß nicht, ob der Wert für den Aufrufer noch wichtig ist, und sichert deshalb oft unnötig.
- **Nur der Aufrufer sichert** (Caller-Save) alle Werte, die er nach dem Aufruf noch braucht: Er muss alles in den Speicher retten und verliert den Vorteil, Werte in Registern zu halten.

Lösung „best of both worlds“: Die Register werden per **Konvention** aufgeteilt.
Calling Convention des IKR RISC II (wie in der praktischen Übung): `r1`–`r9` caller-save, `r10`–`r31` callee-save, Parameter in `r1`, `r2`, …, Rückgabe in `r1`, Stapelzeiger `r30` zeigt auf die zuletzt belegte Position (der Stapel wächst nach unten).

Faustregeln:
- Werte, die einen Aufruf **überleben** müssen (Schleifenzähler, Zeiger): in `r10` und höher. Dann musst du diese Register zu Beginn deines eigenen Unterprogramms sichern.
- Kurzlebige Zwischenwerte: in `r1`–`r9`, die darf jedes aufgerufene Unterprogramm zerstören.
- Ein Unterprogramm, das selbst `bsr`/`jsr` ausführt, muss `r31` sichern.

## Aufgabe
Ein Unterprogramm `f` nutzt die Register `r1`, `r4`, `r12` und ruft selbst `g` auf. Welche Register muss `f` auf dem Stapel sichern?

<details><summary>Lösung</summary>

**`r12`** (callee-save, `f` verändert es) und **`r31`** (wird durch `bsr g` überschrieben). `r1` und `r4` sind caller-save: Die darf `f` frei verändern. Wenn `f` deren Wert nach dem Aufruf von `g` noch braucht, gehört er besser gleich in ein callee-save Register.
</details>

## Klausur
Caller- vs. Callee-Save ist ein Dauerbrenner (C02).
