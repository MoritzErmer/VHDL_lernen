# W02 · Lauflicht hin und her

12 min · zurück: [W01](W01_werkstatt_start.md) · weiter: [W03](W03_parkhaus.md)

## Ziel
Einen getakteten Baustein mit Teiler, Position und Richtung komplett selbst schreiben.

## Erklärung
Eine einzelne LED wandert von rechts nach links und wieder zurück: Position 0, 1, …, N-1, N-2, …, 0, 1, …

Ports und Generics:
- Generic `N : positive := 8` (Anzahl LEDs, mindestens 2), `T_SCHRITT : positive := 5_000_000` (Takte pro Schritt, bei 50 MHz 0,1 s)
- `clk`, `res_n` (wie immer)
- `en : in std_logic` – nur wenn `'1'`, läuft das Licht weiter
- `leds : out std_logic_vector(N-1 downto 0)` – genau ein Bit ist `'1'`

Nach dem Reset leuchtet `leds(0)`, Richtung nach oben.

## Aufgabe
Schreibe Entity `lauflicht` und Architecture `behav` komplett.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity lauflicht is
  generic(N : positive := 8; T_SCHRITT : positive := 5_000_000);
  port(
    clk, res_n : in  std_logic;
    en         : in  std_logic;
    leds       : out std_logic_vector(N-1 downto 0)
    );
end entity lauflicht;

architecture behav of lauflicht is
  signal teiler : integer range 0 to T_SCHRITT - 1;
  signal pos    : integer range 0 to N - 1;
  signal hoch   : boolean;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      teiler <= 0;
      pos <= 0;
      hoch <= true;
    else
      if clk'event and clk = '1' then
        if en = '1' then
          if teiler = T_SCHRITT - 1 then
            teiler <= 0;
            if hoch then
              if pos = N - 1 then
                hoch <= false;
                pos <= pos - 1;
              else
                pos <= pos + 1;
              end if;
            else
              if pos = 0 then
                hoch <= true;
                pos <= pos + 1;
              else
                pos <= pos - 1;
              end if;
            end if;
          else
            teiler <= teiler + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(pos) is
  begin
    leds <= (others => '0');
    leds(pos) <= '1';
  end process;
end architecture behav;
```
Die Richtung wechselt **an den Enden**: Steht die LED bei N-1, geht sie im selben Schritt schon auf N-2. So leuchtet das Ende nicht doppelt lang.
</details>

## Klausur
Zähler und Teiler (M03, M04), Index mit Integer (P07).
