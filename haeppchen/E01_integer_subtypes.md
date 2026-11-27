# E01 · integer, natural, positive, subtype

5 min · zurück: [D07](D07_flankenerkennung.md) · weiter: [E02](E02_umwandlungen.md)

## Ziel
Den passenden Zahlentyp wählen und begründen können.

## Erklärung
```vhdl
integer               -- mind. -2^31+1 .. 2^31-1
natural  -- = integer range 0 to integer'high
positive -- = integer range 1 to integer'high
```
`natural` und `positive` sind **Subtypen** von
`integer`: gleiche Operationen, eingeschränkter
Wertebereich. Eigene Subtypen:
```vhdl
subtype digit is integer range 0 to 9;
signal z : digit;
variable q_int : integer range 0 to 7;
```
- Verletzt ein Wert den Bereich, bricht die
  **Simulation mit Fehler** ab → gute Fehlersuche.
- Die Synthese nimmt nur so viele Bits wie der
  Bereich braucht (`0 to 9` → 4 Bit).
- Ohne `range` wird ein `integer` **32 Bit** breit!

Faustregel für Generics und Konstanten:
- Größe, die **nie 0** sein darf (Bitbreite N,
  Baudrate, Taktfrequenz) → `positive`
- Größe, die **0** sein darf (Adressbreite eines
  Speichers mit nur 1 Wort, Zählerstand) → `natural`

## Aufgabe
1. Warum ist `positive` ein guter Typ für eine
   Konstante `BAUD_RATE`?
2. Ein generischer RAM hat `ADDR_WIDTH`. Warum
   kann `natural` hier besser sein als `positive`?
3. Wie viele Bits belegt `signal x : integer range
   0 to 100;` in Hardware?

<details><summary>Lösung</summary>

1. Eine Baudrate ist immer > 0 – mit `positive`
   wird ein ungültiger Wert 0 schon vom Simulator
   abgelehnt (und eine Division durch 0
   verhindert).
2. `ADDR_WIDTH = 0` ist sinnvoll: ein RAM mit
   2⁰ = 1 Speicherwort (z.B. bei rekursiver oder
   verteilter Aufteilung bleibt am Ende eine Breite
   von 0 übrig).
3. **7 Bit** (2⁷ = 128 > 100 ≥ 2⁶ = 64).
</details>

## Klausur
**F19 A1 F3a** (`BAUD_RATE` positive), **F19 A2 F10a**
(`ADDR_WIDTH` natural), F20 A1 F1b („Konstante N
geeigneten Typs“), F23 A1 F6a.
