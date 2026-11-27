# K04 · Klausur F20: Multiplizierer mit Schleife

9 min · zurück: [K03](K03_prio_encoder_8bit.md) · weiter: [K05](K05_volladdierer_unsigned.md)

## Ziel
Einen Algorithmus (Schieben + Addieren) als
kombinatorischen Prozess mit Variablen formulieren.

## Erklärung
Schriftliches Multiplizieren binär: Für jedes Bit
von `b` (vom MSB aus) den Akkumulator **um 1 nach
links schieben** und, wenn das Bit `'1'` ist, `a`
**addieren**.

Beispiel 101 · 110 (5 · 6):
| Bit b(i) | nach Schieben | + a? | ac |
|---|---|---|---|
| b(2)=1 | 000000 | +101 | 000101 |
| b(1)=1 | 001010 | +101 | 001111 |
| b(0)=0 | 011110 | – | 011110 = 30 |

Entity `mult`: Generic `N`, Eingänge `a`, `b`
(N Bit), Ausgang `p` (2N Bit).

## Aufgabe
Schreibe die Architecture `behav` mit **einem**
Prozess, **einer** Schleife und einer Variablen
`ac : unsigned(2*N-1 downto 0)`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.numeric_std.all;

architecture behav of mult is
begin
  process(a, b) is
    variable ac : unsigned(2*N-1 downto 0);
    constant z_extend :
      unsigned(2*N-1 downto N) := (others => '0');
  begin
    ac := (others => '0');
    for i in N-1 downto 0 loop
      ac := ac(ac'left-1 downto 0) & '0';
      if b(i) = '1' then
        ac := ac + (z_extend & unsigned(a));
      end if;
    end loop;
    p <= std_logic_vector(ac);
  end process;
end architecture behav;
```
`z_extend & unsigned(a)` erweitert `a` auf 2N Bit
(alternativ: `resize(unsigned(a), 2*N)`).
</details>

## Klausur
**F20 A1 F6** (Musterlösung schreibt `z_extend & a`,
weil dort `a` schon passend typisiert ist).

Am Rechner: `am_rechner/L09/mult.vhd`
