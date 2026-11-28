# U01 · Warum Unterprogramme einen Stapel brauchen

5 min · zurück: [C04](C04_branchless.md) · weiter: [U02](U02_caller_callee.md)

## Ziel
Begründen, warum Parameter, Rücksprungadresse und lokale Variablen auf einen Stapel gehören, und ihn Schritt für Schritt zeichnen.

## Erklärung
Nach **Übung 0, Aufgabe 0.1** (sinngemäß): Eine Maschine hat nur einen Stapelzeiger `SP` und ein Datenregister. Ein Aufruf `sum(7, 5)` legt die Parameter auf den Stapel, springt mit `bsr` ins Unterprogramm (Rücksprungadresse kommt ebenfalls auf den Stapel) und räumt nach der Rückkehr auf.

Warum nicht einfach feste Speicherstellen?
- Ruft ein Unterprogramm sich selbst (Rekursion) oder ein anderes auf, das wieder dasselbe aufruft, würden die festen Stellen **überschrieben**, solange der erste Aufruf noch läuft.
- Die Daten müssen genau **so lange** leben wie der Aufruf: beim Aufruf anlegen, bei der Rückkehr freigeben – in umgekehrter Reihenfolge. Das ist **LIFO**, also ein Stapel.

Ablauf für `sum(7, 5)` (Stapel wächst nach unten, `SP` zeigt aufs oberste Element):
1. `move #7,-(sp)`: 7 liegt oben.
2. `move #5,-(sp)`, `bsr sum`: 5 und die Rücksprungadresse RA kommen dazu.
3. Im Unterprogramm: Parameter über `SP`-relative Adressen lesen, `(2,sp)` und `(4,sp)`.
4. `rts` holt RA vom Stapel.
5. `add #4,sp` gibt die beiden Parameter frei.

## Aufgabe
1. Zeichne den Stapel nach Schritt 2 und nach Schritt 5.
2. Warum steht in Schritt 3 `(2,sp)` für den **zweiten** Parameter (5) und `(4,sp)` für den ersten (7)?

<details><summary>Lösung</summary>

1. Nach Schritt 2, von oben (SP) nach unten: **RA**, **5**, **7**. Nach Schritt 5 ist der Stapel wieder wie vorher, SP zeigt auf den alten Wert.
2. Direkt an SP liegt die Rücksprungadresse, die `bsr` zuletzt abgelegt hat. Darunter liegt der **zuletzt** abgelegte Parameter 5, noch tiefer die 7. Je später ein Wert auf den Stapel kam, desto näher liegt er an SP und desto kleiner ist sein Offset.
</details>

## Klausur
Stapel und Unterprogrammaufrufe sind Grundlage für C01/C02. Im IKR RISC II landet die Rücksprungadresse in `r31`, auf den Stapel muss sie erst bei verschachtelten Aufrufen (U04).
