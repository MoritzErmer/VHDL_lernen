# B04 · Ein Signal – ein Treiber

4 min · zurück: [B03](B03_versteckter_prozess.md) · weiter: [C01](C01_prozess_aufbau.md)

## Ziel
Den Fehler „mehrere Treiber“ sicher vermeiden.

## Erklärung
Jede nebenläufige Anweisung und jeder Prozess, der
an ein Signal zuweist, ist ein **Treiber** dieses
Signals. Zwei Treiber = zwei Gatterausgänge, die
aneinandergelötet sind → Kurzschluss!

```vhdl
y <= a;          -- Treiber 1
y <= b;          -- Treiber 2  (falsch)
```
- Simulation (`std_logic`): wenn a=`'0'`, b=`'1'`
  → `y = 'X'`.
- Synthese: Fehler (außer bei `'Z'`-Tristate-Bussen).

Regel: **Jedes Signal wird an genau einer Stelle
getrieben** – in genau einer nebenläufigen Anweisung
**oder** in genau einem Prozess.
(Innerhalb *eines* Prozesses darf man mehrmals
zuweisen – siehe C02.)

## Aufgabe
Was ist hier falsch, und wie reparierst du es?
```vhdl
y <= a when s = "00" else '0';
y <= b when s = "01" else '0';
y <= c when s = "10" else '0';
```

<details><summary>Lösung</summary>

Drei Treiber für `y`. Bei `s="01"` treibt der erste
`'0'`, der zweite `b` → bei b=`'1'` gibt das `'X'`.

Richtig in **einer** Anweisung:
```vhdl
y <= a when s = "00" else
     b when s = "01" else
     c when s = "10" else
     '0';
```
</details>

## Klausur
Wird gern bei „Finden Sie die Fehler“ oder „Warum
ist … nicht synthetisierbar?“ abgefragt.
