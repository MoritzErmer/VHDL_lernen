# W10 · ggT als Steuer- und Rechenwerk

20 min · zurück: [W09](W09_spi_master.md) · weiter: [W11](W11_multiplizierer.md)

## Ziel
Einen Algorithmus in Rechenwerk (Datenpfad) und Steuerwerk (Automat) aufteilen.

## Erklärung
Der größte gemeinsame Teiler mit dem Subtraktionsverfahren:

```
solange x /= y:
  wenn x > y: x := x - y
  sonst:      y := y - x
ggT = x
```

Hardware-Aufteilung:
- **Rechenwerk**: Register `x`, `y` (8 Bit unsigned). Steuersignale `laden`, `x_minus_y`, `y_minus_x`. Statussignale `gleich`, `x_groesser`.
- **Steuerwerk**: Zustände `idle`, `rechnen`, `done`. `start` lädt `a` und `b`, dann wird gerechnet, bis `gleich = '1'`.

Ports: `clk`, `res_n`, `start : in std_logic`, `a`, `b : in std_logic_vector(7 downto 0)` (beide > 0), `ergebnis : out std_logic_vector(7 downto 0)`, `fertig : out std_logic` (in `done`).

## Aufgabe
Schreibe Entity `ggt` und Architecture `behav`: Prozess `rechenwerk`, Statussignale, und das Steuerwerk mit `transition_function`, `state` und `output_function`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity ggt is
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    a, b       : in  std_logic_vector(7 downto 0);   -- beide > 0
    ergebnis   : out std_logic_vector(7 downto 0);
    fertig     : out std_logic
    );
end entity ggt;

architecture behav of ggt is
  type state_type is (idle, rechnen, done);
  signal current_state, next_state : state_type;
  signal x, y : unsigned(7 downto 0);
  signal laden, x_minus_y, y_minus_x : std_logic;   -- Steuersignale
  signal gleich, x_groesser : std_logic;            -- Statussignale
begin
  -- Rechenwerk
  rechenwerk: process(clk, res_n) is
  begin
    if res_n = '0' then
      x <= (others => '0');
      y <= (others => '0');
    else
      if clk'event and clk = '1' then
        if laden = '1' then
          x <= unsigned(a);
          y <= unsigned(b);
        elsif x_minus_y = '1' then
          x <= x - y;
        elsif y_minus_x = '1' then
          y <= y - x;
        end if;
      end if;
    end if;
  end process rechenwerk;
  gleich     <= '1' when x = y else '0';
  x_groesser <= '1' when x > y else '0';
  ergebnis   <= std_logic_vector(x);

  -- Steuerwerk
  transition_function: process(current_state, start, gleich) is
  begin
    next_state <= current_state;
    case current_state is
      when idle | done =>
        if start = '1' then next_state <= rechnen; end if;
      when rechnen =>
        if gleich = '1' then next_state <= done; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= idle;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state, start, gleich, x_groesser) is
  begin
    laden <= '0'; x_minus_y <= '0'; y_minus_x <= '0';
    case current_state is
      when idle | done =>
        laden <= start;
      when rechnen =>
        if gleich = '0' then
          if x_groesser = '1' then x_minus_y <= '1'; else y_minus_x <= '1'; end if;
        end if;
    end case;
  end process output_function;
  fertig <= '1' when current_state = done else '0';
end architecture behav;
```
Die `output_function` hängt auch von `start`, `gleich` und `x_groesser` ab: Die Steuersignale sind Mealy-Ausgänge. So entscheidet das Steuerwerk in jedem Takt neu, welche Subtraktion nötig ist.
</details>

## Klausur
Steuerwerk + Rechenwerk (F06, K01/K02), Dividierwerk (P14).
