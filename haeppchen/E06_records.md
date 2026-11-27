# E06 · Records

4 min · zurück: [E05](E05_rom.md) · weiter: [E07](E07_aggregate.md)

## Ziel
Zusammengehörige Werte verschiedener Typen bündeln.

## Erklärung
Ein **Record** ist wie ein `struct` in C:
```vhdl
type pair_type is record
  state  : state_type;
  output : output_type;
end record;

constant p : pair_type := (q1, '*');
...
next_state <= p.state;     -- Feldzugriff mit .
y          <= p.output;
```
- Felder können verschiedene Typen haben (Array:
  alle Elemente gleicher Typ).
- Aggregat für Records: positional `(q1, '*')` oder
  named `(state => q1, output => '*')`.
- Kombination mit Arrays: eine Zustandstabelle, die
  pro Feld Folgezustand **und** Ausgabe enthält:
  ```vhdl
  type table_type is array
    (state_type, input_type) of pair_type;
  ```
  Zugriff: `table(state, x).state`

## Aufgabe
Ein Stack-Element besteht aus einem Zeichen
(`character`) und einer Position (`integer range 0
to 99`).
1. Deklariere einen Record-Typ `element_type`.
2. Schreibe eine Konstante `LEER` mit Zeichen `' '`
   und Position 0 (named association).

<details><summary>Lösung</summary>

```vhdl
type element_type is record
  zeichen  : character;
  position : integer range 0 to 99;
end record;

constant LEER : element_type :=
  (zeichen => ' ', position => 0);
```
</details>

## Klausur
**F24 A2** (`state_output_pair_type`, Zugriff
`transition_table(state, x).state` in F9).
