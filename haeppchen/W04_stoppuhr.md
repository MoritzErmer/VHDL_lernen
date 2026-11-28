# W04 · Stoppuhr

15 min · zurück: [W03](W03_parkhaus.md) · weiter: [W05](W05_fussgaengerampel.md)

## Ziel
Kaskadierte Zähler (Zehntel, Sekunden, Minuten) mit Start/Stopp und Nullstellen bauen.

## Erklärung
Eine Stoppuhr zählt Zehntelsekunden, Sekunden und Minuten.

Ports und Generics:
- Generic `TAKTE_PRO_ZEHNTEL : positive := 5_000_000`
- `clk`, `res_n`
- `start_stop : in std_logic` – Impuls: startet die Uhr, wenn sie steht, hält sie an, wenn sie läuft
- `nullen : in std_logic` – Impuls: Zeit auf 0, Uhr steht (hat Vorrang)
- `zehntel : out natural range 0 to 9`
- `sekunden : out natural range 0 to 59`
- `minuten : out natural range 0 to 9`

Kaskade: Ein Teiler erzeugt alle `TAKTE_PRO_ZEHNTEL` Takte einen Schritt. Läuft `zehntel` von 9 auf 0 über, zählt `sekunden` eins weiter, usw.

## Aufgabe
Schreibe Entity `stoppuhr` und Architecture `behav` mit einem einzigen getakteten Prozess.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity stoppuhr is
  generic(TAKTE_PRO_ZEHNTEL : positive := 5_000_000);
  port(
    clk, res_n  : in  std_logic;
    start_stop  : in  std_logic;     -- Impuls: startet bzw. haelt an
    nullen      : in  std_logic;     -- Impuls: Zeit auf 0, Uhr steht
    zehntel     : out natural range 0 to 9;
    sekunden    : out natural range 0 to 59;
    minuten     : out natural range 0 to 9
    );
end entity stoppuhr;

architecture behav of stoppuhr is
  signal teiler : natural range 0 to TAKTE_PRO_ZEHNTEL - 1;
  signal laeuft : std_logic;
  signal z : natural range 0 to 9;
  signal s : natural range 0 to 59;
  signal m : natural range 0 to 9;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      teiler <= 0; laeuft <= '0'; z <= 0; s <= 0; m <= 0;
    else
      if clk'event and clk = '1' then
        if nullen = '1' then
          teiler <= 0; laeuft <= '0'; z <= 0; s <= 0; m <= 0;
        else
          if start_stop = '1' then
            laeuft <= not laeuft;
          end if;
          if laeuft = '1' then
            if teiler = TAKTE_PRO_ZEHNTEL - 1 then
              teiler <= 0;
              if z = 9 then
                z <= 0;
                if s = 59 then
                  s <= 0;
                  if m = 9 then m <= 0; else m <= m + 1; end if;
                else
                  s <= s + 1;
                end if;
              else
                z <= z + 1;
              end if;
            else
              teiler <= teiler + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
  zehntel <= z;
  sekunden <= s;
  minuten <= m;
end architecture behav;
```
Die Ausgänge können keine eigenen Zähler sein (ein `out`-Port lässt sich nicht lesen), deshalb laufen interne Signale `z`, `s`, `m`, die am Ende zugewiesen werden.
</details>

## Klausur
Modulo-Zähler mit Übertrag (M03), Taktteiler (M04).
