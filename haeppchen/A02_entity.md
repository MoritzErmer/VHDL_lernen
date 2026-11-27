# A02 · Die Entity richtig schreiben

5 min · zurück: [A01](A01_hardware_denken.md) · weiter: [A03](A03_architecture.md)

## Ziel
Eine Entity fehlerfrei aus einem Schaltbild aufschreiben.

## Erklärung
```vhdl
library ieee; use ieee.std_logic_1164.all;

entity counter_3bit is
  port(
    clk        : in  std_logic;
    res_n      : in  std_logic;
    q0, q1, q2 : out std_logic
    );
end entity counter_3bit;
```

Regeln, die in der Klausur Punkte kosten:
1. **`library ieee; use ieee.std_logic_1164.all;`**
   steht *vor* der Entity – sonst ist `std_logic`
   unbekannt.
2. Jeder Port: `name : richtung typ`.
3. Ports werden durch `;` **getrennt** – nach dem
   **letzten** Port steht **kein** `;`.
4. Richtungen:
   - `in` → darf nur gelesen werden
   - `out` → darf nur geschrieben werden
     (nicht lesen! – in VHDL-93)
   - `inout` → nur für echte bidirektionale Pins
5. Abschluss: `end entity name;`
6. Vektoren: `std_logic_vector(4 downto 0)` =
   5 Bit, Bit 4 ist links (MSB).

## Aufgabe
Ein Prioritätsencoder hat einen 4-Bit-Eingang `e`,
einen 1-Bit-Ausgang `v` und einen 2-Bit-Ausgang `a`.
Schreibe die Entity `priorityencoder_4_bit`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;

entity priorityencoder_4_bit is
  port(
    e : in  std_logic_vector(3 downto 0);
    v : out std_logic;
    a : out std_logic_vector(1 downto 0)
    );
end entity priorityencoder_4_bit;
```
Check: `library/use` da? Letzter Port ohne `;`?
`end entity …;`?
</details>

## Klausur
Wörtlich so in **Herbst 2019, A1 F1** (4 Punkte).
Ähnlich: F24 A1 F1a (`single_step`), F24 A2 F2.
