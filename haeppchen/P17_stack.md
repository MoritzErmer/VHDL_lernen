# P17 · Klausur F24: Stapelspeicher (Stack)

10 min · zurück: [P16](P16_perioden_rom.md) · weiter: [P18](P18_kellerautomat.md)

## Ziel
Einen generischen Stack mit eigenen Aufzählungstypen und Prüf-Asserts schreiben.

## Erklärung
Nach **F24 A2** (sinngemäß): Ein Stapel (LIFO) merkt sich offene Klammern. Typen im Package:
```vhdl
type stack_character_type is (epsilon, '[', '(', eos);
subtype stack_input_type   is stack_character_type
  range epsilon to '(';
subtype stack_output_type  is stack_character_type
  range '[' to eos;
subtype stack_element_type is stack_character_type
  range '[' to '(';
```
- `push : stack_input_type`: bei jeder Flanke wird das Zeichen abgelegt; `epsilon` heißt „nichts ablegen“.
- `pop : boolean`: oberstes Element entfernen (wenn nicht leer).
- `clr : boolean`: Stapel leeren.
- `tos : stack_output_type` („top of stack“): oberstes Element, `eos` = leer.
- Pro Takt darf **nur eine** Operation angefragt werden → `assert`.

Umsetzung: Array `mem(1 to N)` und Zähler `sp` (Anzahl Elemente). Das oberste Element ist `mem(sp)`.

Wohin mit dem `assert`? In den **getakteten Teil**: Nur zur Taktflanke zählt die Anfrage. Nebenläufig würde es auch bei kurzen Zwischenwerten im Delta-Zyklus anschlagen.

## Aufgabe
Schreibe Entity `stack` (Generic `N`, Ports `clk`, `res_n`, `push`, `pop`, `clr`, `tos`) und Architecture `behav`. Das Package heißt `keller_types` in `work`.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use work.keller_types.all;

entity stack is
  generic(N : positive := 8);
  port(
    clk, res_n : in  std_logic;
    push       : in  stack_input_type;
    pop, clr   : in  boolean;
    tos        : out stack_output_type
    );
end entity stack;

architecture behav of stack is
  type mem_type is array (1 to N) of stack_element_type;
  signal mem : mem_type;
  signal sp  : integer range 0 to N;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      sp <= 0;
    else
      if clk'event and clk = '1' then
        assert not ((push /= epsilon and pop) or
                    (push /= epsilon and clr) or
                    (pop and clr))
          report "mehr als eine Operation" severity error;
        assert not (push /= epsilon and sp = N)
          report "Ueberlauf" severity error;
        if clr then
          sp <= 0;
        elsif push /= epsilon and sp < N then
          mem(sp + 1) <= push;
          sp <= sp + 1;
        elsif pop and sp > 0 then
          sp <= sp - 1;
        end if;
      end if;
    end if;
  end process;
  tos <= mem(sp) when sp > 0 else eos;
end architecture behav;
```
`mem(sp + 1) <= push` geht, weil `push` an dieser Stelle nur `'['` oder `'('` sein kann – die Subtypen haben denselben Grundtyp.
</details>

## Klausur
**F24 A2 F10** (Entity und Architecture `stack` mit Asserts).
