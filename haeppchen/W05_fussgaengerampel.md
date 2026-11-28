# W05 · Fußgängerampel mit Anforderung

20 min · zurück: [W04](W04_stoppuhr.md) · weiter: [W06](W06_aufzug.md)

## Ziel
Eine Ampelsteuerung mit Mindestzeiten und gespeicherter Anforderung komplett entwerfen.

## Erklärung
Eine Straße mit Fußgängerüberweg. Die Autos haben grün, bis ein Fußgänger die Taste drückt.

Ablauf:
1. `gruen`: Autos grün, Fußgänger rot. Bleibt mindestens `T_GRUEN_MIN` Takte, danach nur noch, solange keine Anforderung da ist.
2. `gelb`: `T_GELB` Takte.
3. `fuss_geht`: Autos rot, Fußgänger grün für `T_FUSS` Takte.
4. `raeumen`: beide rot für `T_RAEUMEN` Takte.
5. `rotgelb`: Autos rot und gelb für `T_ROTGELB` Takte, dann wieder 1.

Die Taste ist ein Impuls. Die Anforderung wird gespeichert (`signal_kommt` leuchtet) und erst gelöscht, wenn die Fußgänger grün haben.

Ports: `clk`, `res_n`, `taste : in std_logic`, Ausgänge `auto_rot`, `auto_gelb`, `auto_gruen`, `fuss_rot`, `fuss_gruen`, `signal_kommt` (alle `std_logic`). Die fünf Zeiten sind Generics.

## Aufgabe
Schreibe Entity `fussgaengerampel` und Architecture `behav` mit `transition_function`, `state` (Zustand, Zeitzähler, Anforderung) und `output_function`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity fussgaengerampel is
  generic(
    T_GRUEN_MIN : positive := 20;
    T_GELB      : positive := 3;
    T_FUSS      : positive := 10;
    T_RAEUMEN   : positive := 4;
    T_ROTGELB   : positive := 2
    );
  port(
    clk, res_n                     : in  std_logic;
    taste                          : in  std_logic;   -- Impuls
    auto_rot, auto_gelb, auto_gruen : out std_logic;
    fuss_rot, fuss_gruen           : out std_logic;
    signal_kommt                   : out std_logic
    );
end entity fussgaengerampel;

architecture behav of fussgaengerampel is
  type state_type is (gruen, gelb, fuss_geht, raeumen, rotgelb);
  signal current_state, next_state : state_type;
  signal zeit   : natural range 0 to 255;
  signal wunsch : std_logic;
begin
  transition_function: process(current_state, zeit, wunsch) is
  begin
    next_state <= current_state;
    case current_state is
      when gruen =>
        if zeit >= T_GRUEN_MIN - 1 and wunsch = '1' then next_state <= gelb; end if;
      when gelb =>
        if zeit = T_GELB - 1 then next_state <= fuss_geht; end if;
      when fuss_geht =>
        if zeit = T_FUSS - 1 then next_state <= raeumen; end if;
      when raeumen =>
        if zeit = T_RAEUMEN - 1 then next_state <= rotgelb; end if;
      when rotgelb =>
        if zeit = T_ROTGELB - 1 then next_state <= gruen; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= gruen;
      zeit <= 0;
      wunsch <= '0';
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;
        elsif zeit < 255 then
          zeit <= zeit + 1;
        end if;
        if current_state = fuss_geht then
          wunsch <= '0';
        elsif taste = '1' then
          wunsch <= '1';
        end if;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    auto_rot <= '0'; auto_gelb <= '0'; auto_gruen <= '0';
    fuss_rot <= '1'; fuss_gruen <= '0';
    case current_state is
      when gruen     => auto_gruen <= '1';
      when gelb      => auto_gelb <= '1';
      when fuss_geht => auto_rot <= '1'; fuss_rot <= '0'; fuss_gruen <= '1';
      when raeumen   => auto_rot <= '1';
      when rotgelb   => auto_rot <= '1'; auto_gelb <= '1';
    end case;
  end process output_function;

  signal_kommt <= wunsch;
end architecture behav;
```
`zeit < 255` verhindert, dass der Zähler in `gruen` über den Wertebereich läuft, solange niemand drückt. Fußgänger-Rot ist der Default in der `output_function`.
</details>

## Klausur
Automat mit Timer (M09), Moore-Ausgänge mit Defaults (F05).
