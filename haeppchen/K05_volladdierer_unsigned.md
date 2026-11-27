# K05 · Klausur F20: Volladdierer mit „+“

5 min · zurück: [K04](K04_multiplizierer.md) · weiter: [K06](K06_crc_rom.md)

## Ziel
Einzelbits mit `unsigned` addieren und das Ergebnis
auf zwei Ports verteilen.

## Erklärung
Ein einzelnes `std_logic` kann man nicht addieren.
Trick: Mit `'0' &` einen 2-Bit-Vektor bilden und
per **Typqualifikation** als `unsigned` markieren:
```vhdl
unsigned'('0' & a)      -- "0a" als Zahl 0 oder 1
```
Summe von drei solchen Werten: 0 … 3 → passt in
2 Bit = (Übertrag, Summe).

VHDL-2008 erlaubt ein **Aggregat als Ziel** einer
Zuweisung:
```vhdl
(c_out, s) <= ...;      -- 2-Bit-Wert aufteilen
```
Ohne VHDL-2008: Hilfssignal `sum : unsigned(1
downto 0)` und dann `c_out <= sum(1); s <= sum(0);`

## Aufgabe
Schreibe die Architecture `behav` für den
Volladdierer `va` (Eingänge `a`, `b`, `c_in`,
Ausgänge `s`, `c_out`) mit `unsigned` und `+` –
einmal **mit** Aggregat-Ziel.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.numeric_std.all;

architecture behav of va is
begin
  (c_out, s) <= unsigned'('0' & a) +
                unsigned'('0' & b) +
                unsigned'('0' & c_in);
end architecture behav;
```
</details>

## Klausur
**F20 A1 F7**.
