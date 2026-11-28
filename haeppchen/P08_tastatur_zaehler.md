# P08 · Klausur F20: Binärzähler mit Freigabe

6 min · zurück: [P07](P07_tastatur_decoder_mux.md) · weiter: [P09](P09_tastatur_speicher.md)

## Ziel
Einen generischen Zähler schreiben, der sich zu einer Zählerkette verbinden lässt.

## Erklärung
Der Tastatur-Controller braucht zwei Zähler:
- **Zeilenzähler** (2 Bit) zählt in jedem Takt.
- **Spaltenzähler** (3 Bit) zählt nur, wenn der Zeilenzähler gerade bei 3 steht – also einmal pro vollem Zeilendurchlauf.

Dafür bekommt `binary_counter` einen Freigabe-Eingang `inc` und einen Ausgang `max` (`'1'`, wenn der Zähler auf dem größten Wert steht). Verbindet man `max` des einen mit `inc` des anderen, entsteht ein Zähler mit 5 Bit.

Tipp: `inc : in std_logic := '1'` – ein **Defaultwert** am Port. Bleibt der Port in der Instanz unbeschaltet, gilt `'1'`.

## Aufgabe
Schreibe Entity und Architecture `behav` für `binary_counter` mit Generic `N`, Ports `clk`, `res_n`, `inc` (Default `'1'`), `q(N-1 downto 0)` und `max`.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity binary_counter is
  generic(N : positive);
  port(
    clk, res_n : in  std_logic;
    inc        : in  std_logic := '1';
    q          : out std_logic_vector(N-1 downto 0);
    max        : out std_logic
    );
end entity binary_counter;

library ieee;
use ieee.numeric_std.all;

architecture behav of binary_counter is
  signal cnt : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= (others => '0');
    else
      if clk'event and clk = '1' then
        if inc = '1' then
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  q   <= std_logic_vector(cnt);
  max <= '1' when cnt = 2**N - 1 else '0';
end architecture behav;
```
Ein Ausgangsport kann nicht gelesen werden (in VHDL-93), deshalb zählt das interne Signal `cnt`. Der Überlauf von `unsigned` geht von selbst wieder auf 0.
</details>

## Klausur
**F20 A2** (Line Counter, Column Counter).
