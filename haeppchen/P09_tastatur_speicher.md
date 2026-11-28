# P09 · Klausur F20: Tastenspeicher mit 2D-Array

8 min · zurück: [P08](P08_tastatur_zaehler.md) · weiter: [P10](P10_tastatur_top.md)

## Ziel
Ein zweidimensionales Array als Speicher nutzen und Änderungen erkennen.

## Erklärung
`keyboard_state` merkt sich für jede der 8 × 4 Tasten den zuletzt gelesenen Zustand. Kommt die Abfrage wieder bei derselben Taste an, vergleicht er:
- `key_changed = '1'`, wenn sich der Zustand gegenüber dem gespeicherten geändert hat (gedrückt **oder** losgelassen),
- `key_state` = aktueller Zustand der Taste.

Zweidimensionaler Array-Typ (E05):
```vhdl
subtype c_type is integer range 0 to 7;
subtype l_type is integer range 0 to 3;
type matrix_type is array (c_type, l_type) of std_logic;
signal matrix : matrix_type;
```
Zugriff mit zwei Indizes: `matrix(c, l)`. Alles löschen: `(others => (others => '0'))`.

Ports: `clk`, `res_n`, `column_number(2 downto 0)`, `line_number(1 downto 0)`, `key_in`, `key_changed`, `key_state`.

## Aufgabe
Schreibe Entity und Architecture `behav` für `keyboard_state`. Der Speicher übernimmt mit jeder Taktflanke `key_in` an der aktuellen Stelle, `key_changed` ist kombinatorisch.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity keyboard_state is
  port(
    clk, res_n    : in  std_logic;
    column_number : in  std_logic_vector(2 downto 0);
    line_number   : in  std_logic_vector(1 downto 0);
    key_in        : in  std_logic;
    key_changed   : out std_logic;
    key_state     : out std_logic
    );
end entity keyboard_state;

library ieee;
use ieee.numeric_std.all;

architecture behav of keyboard_state is
  subtype c_type is integer range 0 to 7;
  subtype l_type is integer range 0 to 3;
  type matrix_type is array (c_type, l_type) of std_logic;
  signal matrix : matrix_type;
  signal c : c_type;
  signal l : l_type;
begin
  c <= to_integer(unsigned(column_number));
  l <= to_integer(unsigned(line_number));

  process(clk, res_n) is
  begin
    if res_n = '0' then
      matrix <= (others => (others => '0'));
    else
      if clk'event and clk = '1' then
        matrix(c, l) <= key_in;
      end if;
    end if;
  end process;

  key_changed <= key_in xor matrix(c, l);
  key_state   <= key_in;
end architecture behav;
```
`xor` ist genau dann `'1'`, wenn alter und neuer Wert verschieden sind.
</details>

## Klausur
**F20 A2** (Keyboard State).
