# P15 · Klausur F23: Ton-Oszillator

9 min · zurück: [P14](P14_dividierwerk.md) · weiter: [P16](P16_perioden_rom.md)

## Ziel
Einen Rechteckgenerator mit einstellbarer Periode schreiben und Frequenzen ausrechnen.

## Erklärung
Nach **F23 A2** (sinngemäß): Ein Synthesizer erzeugt Töne als Rechtecksignale. Der Oszillator `osc` bekommt die **Periodendauer in Takten** als Zahl `period`:
- `counter` zählt von 0 bis `period_reg - 1`, dann wieder 0.
- Erste Hälfte der Periode `wave = '0'`, zweite Hälfte `'1'`.
- Der neue Wert von `period` wird erst am **Ende einer Periode** in `period_reg` übernommen – so entstehen beim Tonwechsel keine verstümmelten Halbwellen.
- `wave` wird im getakteten Prozess zugewiesen, ist also selbst ein Flipflop.

Frequenz: f_wave = f_clk / period. Bei 50 MHz und `period` = 50 000 entsteht 1 kHz.

```vhdl
entity osc is
  generic(N : positive);
  port(
    clk, res_n : in  std_logic;
    period     : in  std_logic_vector(N-1 downto 0);
    wave       : out std_logic
    );
end entity osc;
```

## Aufgabe
1. Schreibe `architecture behav of osc` mit den Signalen `period_reg` und `counter` (`unsigned(N-1 downto 0)`).
2. Welcher Automatentyp ist das (Mealy, Moore, Medwedew)?
3. Welches `period` ergibt 250 Hz bei 50 MHz? Wie groß muss `N` mindestens sein?

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.numeric_std.all;

architecture behav of osc is
  signal period_reg : unsigned(N-1 downto 0);
  signal counter    : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      period_reg <= (others => '0');
      counter <= (others => '0');
      wave <= '0';
    else
      if clk'event and clk = '1' then
        if counter + 1 >= period_reg then
          counter <= (others => '0');
          period_reg <= unsigned(period);
          wave <= '0';
        else
          counter <= counter + 1;
          if counter + 1 >= period_reg / 2 then
            wave <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture behav;
```
2. **Medwedew**: Der Ausgang `wave` ist direkt ein Flipflop des Zustands, ohne Logik dahinter.
3. period = 50 000 000 / 250 = **200 000**. 2¹⁷ = 131 072 reicht nicht, 2¹⁸ = 262 144 reicht → **N = 18**. Flipflops: 2 · N + 1 = 37.
</details>

## Klausur
**F23 A2 F1–F4** (Automatentyp, Flipflops, Frequenz und Breite). Automatentypen: F01.
