# W06 · Aufzug mit drei Etagen

25 min · zurück: [W05](W05_fussgaengerampel.md) · weiter: [W07](W07_reaktionstester.md)

## Ziel
Eine Steuerung mit Auftragsspeicher, Position und Fahrtrichtungsentscheidung selbst bauen.

## Erklärung
Ein Aufzug fährt zwischen den Etagen 0, 1 und 2.

- `ruf : in std_logic_vector(2 downto 0)` – je Etage eine Taste, Impulse. Ein Ruf wird als **Auftrag** gespeichert.
- Der Aufzug steht. Gibt es einen Auftrag für die aktuelle Etage, geht die Tür `T_TUER` Takte auf, der Auftrag ist erledigt.
- Sonst: Auftrag weiter oben → eine Etage hoch fahren (`T_FAHRT` Takte), Auftrag weiter unten → eine Etage runter. Danach wieder neu entscheiden.
- Ausgänge: `motor_hoch`, `motor_runter`, `tuer_auf` (`std_logic`), `etage : out natural range 0 to 2`.
- Nie gleichzeitig fahren und Tür offen.

Zustände: `steht`, `hoch`, `runter`, `tuer`. Dazu Register: Etage `e`, Aufträge `auftrag(2 downto 0)`, Zeitzähler `zeit`. Hilfssignale `oben` und `unten` sagen, ob es Aufträge über bzw. unter der aktuellen Etage gibt.

## Aufgabe
Schreibe Entity `aufzug` und Architecture `behav`. Die Hilfssignale `oben`/`unten` berechnest du in einem kombinatorischen Prozess mit einer Schleife.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity aufzug is
  generic(T_FAHRT : positive := 10; T_TUER : positive := 8);
  port(
    clk, res_n    : in  std_logic;
    ruf           : in  std_logic_vector(2 downto 0);   -- Impulse, eine Taste pro Etage
    motor_hoch    : out std_logic;
    motor_runter  : out std_logic;
    tuer_auf      : out std_logic;
    etage         : out natural range 0 to 2
    );
end entity aufzug;

architecture behav of aufzug is
  type state_type is (steht, hoch, runter, tuer);
  signal current_state, next_state : state_type;
  signal e       : natural range 0 to 2;
  signal auftrag : std_logic_vector(2 downto 0);
  signal zeit    : natural range 0 to 255;
  signal oben, unten : std_logic;     -- Auftraege ueber / unter der aktuellen Etage
begin
  process(e, auftrag) is
  begin
    oben <= '0';
    unten <= '0';
    for i in 0 to 2 loop
      if auftrag(i) = '1' and i > e then oben <= '1'; end if;
      if auftrag(i) = '1' and i < e then unten <= '1'; end if;
    end loop;
  end process;

  transition_function: process(current_state, auftrag, e, oben, unten, zeit) is
  begin
    next_state <= current_state;
    case current_state is
      when steht =>
        if auftrag(e) = '1' then next_state <= tuer;
        elsif oben = '1' then next_state <= hoch;
        elsif unten = '1' then next_state <= runter;
        end if;
      when hoch | runter =>
        if zeit = T_FAHRT - 1 then next_state <= steht; end if;
      when tuer =>
        if zeit = T_TUER - 1 then next_state <= steht; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= steht;
      e <= 0;
      auftrag <= (others => '0');
      zeit <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;
        elsif zeit < 255 then
          zeit <= zeit + 1;
        end if;
        -- angekommen: eine Etage weiter
        if current_state = hoch and next_state = steht then
          e <= e + 1;
        elsif current_state = runter and next_state = steht then
          e <= e - 1;
        end if;
        -- Auftraege merken, erledigt, sobald die Tuer aufgeht
        for i in 0 to 2 loop
          if current_state = tuer and i = e then
            auftrag(i) <= '0';
          elsif ruf(i) = '1' then
            auftrag(i) <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process state;

  motor_hoch   <= '1' when current_state = hoch else '0';
  motor_runter <= '1' when current_state = runter else '0';
  tuer_auf     <= '1' when current_state = tuer else '0';
  etage <= e;
end architecture behav;
```
Die Etage wird beim **Ankommen** geändert (Übergang von `hoch`/`runter` nach `steht`). In der Auftragsschleife hat „erledigt“ Vorrang vor einem neuen Ruf derselben Etage, während die Tür offen ist.
</details>

## Klausur
Automat plus Register (F06, P05), Schleife über einen Vektor (C07).
