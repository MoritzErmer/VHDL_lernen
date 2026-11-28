# W12 · Frequenzzähler

12 min · zurück: [W11](W11_multiplizierer.md) · weiter: [W13](W13_arbiter.md)

## Ziel
Ein asynchrones Signal sicher einlesen und seine Flanken in einem Zeitfenster zählen.

## Erklärung
Ein Frequenzzähler zählt, wie viele steigende Flanken das Signal `sig` innerhalb einer **Torzeit** hat. Bei einer Torzeit von 1 s ist das direkt die Frequenz in Hz.

Anforderungen:
- `sig` ist asynchron: erst synchronisieren (zwei Flipflops), dann ein drittes Flipflop für die Flankenerkennung (D07).
- Ein Torzähler zählt `TORZEIT` Takte. Am Ende des Fensters: Ergebnis nach `frequenz` übernehmen, Zähler auf 0, einen Takt `neu = '1'`.
- Eine Flanke genau im letzten Takt des Fensters zählt noch mit.

Ports und Generics: Generic `TORZEIT : positive := 50_000_000`, `clk`, `res_n`, `sig : in std_logic`, `frequenz : out natural range 0 to 2**20 - 1`, `neu : out std_logic`.

## Aufgabe
Schreibe Entity `frequenzzaehler` und Architecture `behav`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity frequenzzaehler is
  generic(TORZEIT : positive := 50_000_000);   -- Takte pro Messung (1 s bei 50 MHz)
  port(
    clk, res_n : in  std_logic;
    sig        : in  std_logic;                -- asynchrones Messsignal
    frequenz   : out natural range 0 to 2**20 - 1;
    neu        : out std_logic                 -- ein Takt nach jeder Messung
    );
end entity frequenzzaehler;

architecture behav of frequenzzaehler is
  signal s1, s2, s3 : std_logic;
  signal tor : natural range 0 to TORZEIT - 1;
  signal anzahl : natural range 0 to 2**20 - 1;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      s1 <= '0'; s2 <= '0'; s3 <= '0';
      tor <= 0; anzahl <= 0; frequenz <= 0; neu <= '0';
    else
      if clk'event and clk = '1' then
        s1 <= sig;                      -- Synchronisierer
        s2 <= s1;
        s3 <= s2;                       -- alter Wert fuer die Flankenerkennung
        neu <= '0';
        if tor = TORZEIT - 1 then
          tor <= 0;
          if s2 = '1' and s3 = '0' then
            frequenz <= anzahl + 1;
          else
            frequenz <= anzahl;
          end if;
          anzahl <= 0;
          neu <= '1';
        else
          tor <= tor + 1;
          if s2 = '1' and s3 = '0' and anzahl < 2**20 - 1 then
            anzahl <= anzahl + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture behav;
```
Ohne Synchronisierer könnte eine Flanke genau an der Taktflanke metastabil werden und doppelt oder gar nicht gezählt werden.
</details>

## Klausur
Synchronisierer (D05), Flankenerkennung (D07), Torzeit = Taktteiler (M04).
