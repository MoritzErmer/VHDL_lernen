# C07 · for-Schleife = kopierte Hardware

6 min · zurück: [C06](C06_latch_falle.md) · weiter: [C08](C08_variable_akkumulator.md)

## Ziel
Schleifen als **Hardware** verstehen und damit
Priorität elegant bauen.

## Erklärung
Eine `for`-Schleife läuft in Hardware **nicht
nacheinander**: Das Synthese-Tool **rollt sie ab**
(kopiert den Rumpf N-mal). Die Grenzen müssen
deshalb **konstant** sein.

```vhdl
for i in 7 downto 0 loop   -- i: implizit deklariert
  ...                      -- i ist konstant im Rumpf
end loop;
```
`for i in e'range loop` läuft über alle Indizes von
`e` (bei `downto` von oben nach unten).

**Priorität per Überschreiben:** Weil die *letzte*
Signalzuweisung gewinnt (C02), gewinnt der **zuletzt**
geprüfte Index:
```vhdl
encoder: process(e) is
begin
  v <= '0';
  a <= "--";
  for i in 3 downto 0 loop
    if e(i) = '1' then
      v <= '1';
      a <= std_logic_vector(to_unsigned(i, 2));
    end if;
  end loop;
end process encoder;
```
`3 downto 0` → Index 0 wird zuletzt geprüft →
**Index 0 hat die höchste Priorität**.

## Aufgabe
1. Warum lässt sich diese Version leichter auf 8 Bit
   erweitern als eine `if/elsif`-Kette?
2. Was musst du für 8 Bit ändern?

<details><summary>Lösung</summary>

1. Nur der **Schleifenbereich** wird angepasst; bei
   `if/elsif` braucht jedes neue Bit einen neuen
   Zweig.
2. `a <= "---";`, Schleife `for i in 7 downto 0`,
   `to_unsigned(i, 3)`, und Ports
   `e(7 downto 0)`, `a(2 downto 0)`.
   (Plus `use ieee.numeric_std.all;` für
   `to_unsigned`.)
</details>

## Klausur
**Herbst 2019, A1 F5, F7, F8** (17 Punkte zusammen!).
