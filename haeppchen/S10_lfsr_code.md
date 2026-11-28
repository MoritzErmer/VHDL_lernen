# S10 · Senso: LFSR mit einstellbarer Rückkopplung

7 min · zurück: [S09](S09_lfsr_verstehen.md) · weiter: [S11](S11_lfsr_schleife.md)

## Ziel
Entity und Architecture für ein Schieberegister mit Muster-Eingang und synchronem Reset schreiben.

## Erklärung
Um verschiedene Rückkopplungsmuster zu untersuchen, wird das Muster ein **Eingang**:
- `fb(7 downto 1)`: Rückkopplungsmuster.
- `reset`: **synchroner**, high-aktiver Reset. Er wirkt nur zur Taktflanke, anders als `res_n` (asynchron, low-aktiv).
- `q(7 downto 0)`: aktueller Wert.

Startwert nach beiden Resets: `"00000001"`. Nicht 0 – siehe S09.

Synchroner Reset steht **innerhalb** der Taktabfrage:
```vhdl
if clk'event and clk = '1' then
  if reset = '1' then
    ...
  else
    ...
```

## Aufgabe
Schreibe Entity `galois_lfsr` und Architecture `behav`. Verwende im Prozess eine Variable `q_int` und weise `q` am Ende des Prozesses zu.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity galois_lfsr is
  port(
    clk, res_n : in  std_logic;
    reset      : in  std_logic;
    fb         : in  std_logic_vector(7 downto 1);
    q          : out std_logic_vector(7 downto 0)
    );
end entity galois_lfsr;

architecture behav of galois_lfsr is
begin
  process(clk, res_n) is
    variable q_int : std_logic_vector(7 downto 0);
  begin
    if res_n = '0' then
      q_int := "00000001";
    else
      if clk'event and clk = '1' then
        if reset = '1' then
          q_int := "00000001";
        elsif q_int(7) = '1' then
          q_int := (q_int(6 downto 0) xor fb) & q_int(7);
        else
          q_int := q_int(6 downto 0) & q_int(7);
        end if;
      end if;
    end if;
    q <= q_int;
  end process;
end architecture behav;
```
Die Variable wird vor dem Schreiben gelesen (alter Wert) und behält ihren Wert bis zum nächsten Prozesslauf. Sie wird deshalb zu 8 Flipflops. `q <= q_int` hinter dem `if` macht daraus nur Drähte.
</details>

## Klausur
Synchroner vs. asynchroner Reset (D01, D02), Variable als Register (D04).
