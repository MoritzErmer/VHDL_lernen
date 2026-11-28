# W03 · Parkhaus mit zwei Lichtschranken

18 min · zurück: [W02](W02_lauflicht.md) · weiter: [W04](W04_stoppuhr.md)

## Ziel
Einen Automaten entwerfen, der eine Richtung aus einer Signalfolge erkennt, und damit einen Zähler steuern.

## Erklärung
An der Einfahrt eines Parkhauses liegen zwei Lichtschranken hintereinander: `a` außen, `b` innen (`'1'` = unterbrochen). Ein Auto, das **hineinfährt**, erzeugt die Folge

`a` → `a` und `b` → `b` → keine

Ein Auto, das **herausfährt**, die umgekehrte Folge. Erst wenn die Folge vollständig ist, zählt das Auto. Dreht ein Fahrer mittendrin um, darf nichts gezählt werden.

Ports und Generics:
- Generic `PLAETZE : positive := 50`
- `clk`, `res_n`, `a`, `b : in std_logic` (schon synchronisiert)
- `belegt : out natural range 0 to PLAETZE`
- `voll : out std_logic` – `'1'`, wenn alle Plätze belegt sind

Tipp: Sieben Zustände genügen: `frei`, drei für die Einfahrt, drei für die Ausfahrt. Die Zählimpulse `rein` und `raus` entstehen beim Übergang vom letzten Zustand nach `frei` (Mealy).

## Aufgabe
Schreibe Entity `parkhaus` und Architecture `behav` mit `transition_function` (erzeugt auch `rein`/`raus`) und `state` (Zustand und Zähler).

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity parkhaus is
  generic(PLAETZE : positive := 50);
  port(
    clk, res_n : in  std_logic;
    a, b       : in  std_logic;     -- a aussen, b innen, '1' = unterbrochen
    belegt     : out natural range 0 to PLAETZE;
    voll       : out std_logic
    );
end entity parkhaus;

architecture behav of parkhaus is
  type state_type is (frei, e1, e2, e3, a1, a2, a3);
  signal current_state, next_state : state_type;
  signal rein, raus : std_logic;
  signal anzahl : natural range 0 to PLAETZE;
begin
  transition_function: process(current_state, a, b) is
  begin
    next_state <= current_state;
    rein <= '0';
    raus <= '0';
    case current_state is
      when frei =>
        if a = '1' and b = '0' then next_state <= e1;
        elsif a = '0' and b = '1' then next_state <= a1;
        end if;
      when e1 =>
        if a = '1' and b = '1' then next_state <= e2;
        elsif a = '0' and b = '0' then next_state <= frei;
        end if;
      when e2 =>
        if a = '0' and b = '1' then next_state <= e3;
        elsif a = '1' and b = '0' then next_state <= e1;
        end if;
      when e3 =>
        if a = '0' and b = '0' then next_state <= frei; rein <= '1';
        elsif a = '1' and b = '1' then next_state <= e2;
        end if;
      when a1 =>
        if a = '1' and b = '1' then next_state <= a2;
        elsif a = '0' and b = '0' then next_state <= frei;
        end if;
      when a2 =>
        if a = '1' and b = '0' then next_state <= a3;
        elsif a = '0' and b = '1' then next_state <= a1;
        end if;
      when a3 =>
        if a = '0' and b = '0' then next_state <= frei; raus <= '1';
        elsif a = '1' and b = '1' then next_state <= a2;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= frei;
      anzahl <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if rein = '1' and anzahl < PLAETZE then
          anzahl <= anzahl + 1;
        elsif raus = '1' and anzahl > 0 then
          anzahl <= anzahl - 1;
        end if;
      end if;
    end if;
  end process state;

  belegt <= anzahl;
  voll <= '1' when anzahl = PLAETZE else '0';
end architecture behav;
```
Bei voll besetztem Parkhaus wird nicht weiter gezählt, bei 0 nicht weiter heruntergezählt – der Zählerbereich bleibt sicher.
</details>

## Klausur
Automat mit Zähler (P05, F06), Mealy-Ausgänge (F03).
