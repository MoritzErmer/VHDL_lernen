# P16 · Klausur F23: Perioden-ROM und Synthesizer verdrahten

8 min · zurück: [P15](P15_oszillator.md) · weiter: [P17](P17_stack.md)

## Ziel
Ein ROM als konstantes Array schreiben und mit dem Oszillator verbinden.

## Erklärung
Jede Taste einer Oktave hat eine Nummer `key_num` (1 = C … 12 = H, 4 Bit). Das ROM liefert dazu die Periode für `osc`: period = 50 MHz / f, gerundet.

| Note | C | D | E | A | H |
|---|---|---|---|---|---|
| f / Hz | 261,6 | 293,7 | 329,6 | 440,0 | 493,9 |
| period | 191 131 | 170 242 | 151 699 | 113 636 | 101 235 |

(C# 180 375, D# 160 720, F 143 184, F# 135 135, G 127 551, G# 120 395, A# 107 250.)

Nummern 0, 13, 14, 15 bekommen 0 → Stille.

ROM-Muster (E04): konstantes Array, Lesen mit `to_integer(unsigned(...))`:
```vhdl
type rom_type is array (0 to 15) of natural range 0 to 2**18 - 1;
constant ROM : rom_type := (...);
```

## Aufgabe
1. Schreibe Entity und Architecture `behav` für `period_rom` (Eingang `key_num(3 downto 0)`, Ausgang `period(17 downto 0)`).
2. Schreibe `architecture struct of tongenerator` (Ports `clk`, `res_n`, `key_num(3 downto 0)`, `wave`), die ROM und `osc` (N = 18) verbindet.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity period_rom is
  port(
    key_num : in  std_logic_vector(3 downto 0);
    period  : out std_logic_vector(17 downto 0)
    );
end entity period_rom;

library ieee;
use ieee.numeric_std.all;

architecture behav of period_rom is
  type rom_type is array (0 to 15)
    of natural range 0 to 2**18 - 1;
  constant ROM : rom_type := (
    0, 191131, 180375, 170242, 160720, 151699, 143184,
    135135, 127551, 120395, 113636, 107250, 101235,
    0, 0, 0);
begin
  period <= std_logic_vector(to_unsigned(
              ROM(to_integer(unsigned(key_num))), 18));
end architecture behav;

architecture struct of tongenerator is
  signal period : std_logic_vector(17 downto 0);
begin
  rom: entity work.period_rom
    port map(key_num => key_num, period => period);
  o: entity work.osc
    generic map(N => 18)
    port map(clk => clk, res_n => res_n,
             period => period, wave => wave);
end architecture struct;
```
Ist `period = 0`, gilt in `osc` immer `counter + 1 >= 0`: `wave` bleibt `'0'`.
</details>

## Klausur
**F23 A2 F5** (Entity und Architecture `period_rom`). Simulierbar in `am_rechner/L12/projekte_klausur.vhd`.
