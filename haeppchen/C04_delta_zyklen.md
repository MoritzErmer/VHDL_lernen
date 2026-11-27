# C04 · Delta-Zyklen

6 min · zurück: [C03](C03_variablen.md) · weiter: [C05](C05_if_case.md)

## Ziel
Verstehen, wie der Simulator „gleichzeitige“
Änderungen nacheinander abarbeitet.

## Erklärung
Ein **Delta-Zyklus** ist ein Simulationsschritt
**ohne** dass Zeit vergeht (0 ns). Ablauf:
1. Vorgemerkte Signalwerte werden übernommen.
2. Alle Prozesse, deren Signale sich geändert haben,
   laufen.
3. Haben die neue Werte vorgemerkt → nächster Delta.
4. Erst wenn nichts mehr passiert, geht die Zeit weiter.

Beispiel-Kette:
```vhdl
pp <= a and b;    -- Stufe 1
p  <= pp or c;    -- Stufe 2
```
Testbench setzt `a` zur Zeit 10 ns:
- Delta 1: `a` neu → `pp` wird berechnet
- Delta 2: `pp` neu → `p` wird berechnet
- Delta 3: `p` hat neuen Wert

`wait for 0 ns;` lässt **genau einen** Delta-Zyklus
vergehen.

## Aufgabe
Ein Tester-Prozess setzt `a` und `b`, wartet mit
`wait for 0 ns;` und prüft dann `p`. Im Multiplizierer
gilt: `pp0, pp1, pp2` hängen von `a, b` ab; `p` hängt
von `pp0..pp2` ab.
Wie viele `wait for 0 ns;` sind **mindestens** nötig,
bis `p` stimmt? Begründe.

<details><summary>Lösung</summary>

**Drei.**
1. Nach dem 1.: `a`, `b` haben ihre neuen Werte.
2. Nach dem 2.: `pp0..pp2` (abhängig von a, b) sind
   aktualisiert.
3. Nach dem 3.: `p` (abhängig von pp) ist aktualisiert.

Merke: **Anzahl Deltas = Anzahl Signal-„Stufen“**
in der Kette.
</details>

## Klausur
**Frühjahr 2020, A1 F4b** – genau diese Frage.
