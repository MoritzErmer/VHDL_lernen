# A01 · VHDL beschreibt Hardware

⏱️ 4 min · [Übersicht](../README.md) · weiter: [A02](A02_entity.md)

## 🎯 Ziel
Verstehen, warum VHDL **kein** Programm ist, das Zeile für Zeile abläuft.

## 📖 Erklärung
Eine VHDL-Komponente besteht immer aus zwei Teilen:

| Teil | Bild | Inhalt |
|---|---|---|
| `entity` | das **Gehäuse** mit Pins | Name + Ports (Ein-/Ausgänge) |
| `architecture` | das **Innenleben** | was die Schaltung tut |

```vhdl
entity and_2 is
  port(
    x0, x1 : in  std_logic;
    y      : out std_logic
    );
end entity and_2;

architecture behav of and_2 is
begin
  y <= x0 and x1;
end architecture behav;
```

Das Wichtigste: Alle Anweisungen zwischen `begin`
und `end architecture` sind **nebenläufig**
(parallel). Jede Zeile ist ein eigenes Stück
Hardware, das *ständig* arbeitet – wie Gatter auf
einer Platine. Die **Reihenfolge der Zeilen ist
egal**.

`<=` heißt „wird getrieben von“ (Signalzuweisung),
nicht „wird einmal gesetzt“.

## ✍️ Aufgabe
Beschreiben diese beiden Architectures dieselbe Schaltung?

```vhdl
-- Variante 1           -- Variante 2
h <= a and b;           y <= h or c;
y <= h or c;            h <= a and b;
```

<details><summary>✅ Lösung</summary>

**Ja, exakt dieselbe.** Beide Zeilen sind
nebenläufige Anweisungen = zwei Gatter (UND, ODER),
die über die Leitung `h` verbunden sind. Ändert sich
`a`, reagiert das UND-Gatter, danach das ODER-Gatter
– egal, in welcher Reihenfolge es im Text steht.

(Achtung: Innerhalb eines `process` ist das anders –
das kommt in Block C.)
</details>

## 🎓 Klausur
Fast jede Klausur beginnt mit „Geben Sie eine Entity … an“
und „Geben Sie eine Architecture … an“.
