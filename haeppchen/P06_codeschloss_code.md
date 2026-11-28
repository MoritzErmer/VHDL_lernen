# P06 · Codeschloss: Architecture komplett

12 min · zurück: [P05](P05_codeschloss_entwurf.md) · weiter: [P07](P07_tastatur_decoder_mux.md)

## Ziel
Automat und Zähler sauber trennen: kombinatorische Übergangsfunktion, Zähler im getakteten Prozess.

## Erklärung
Aufteilung:
- Prozess `pruefen` (kombinatorisch): erzeugt `richtig` und `falsch`. Welche Ziffer erwartet wird, hängt vom Zustand ab – dafür eine **Variable** `erwartet`.
- `transition_function`: nutzt `richtig`, `falsch`, `fehler`, `zeit`.
- `state` (getaktet): Zustand **und** beide Zähler.
  - `zeit`: bei Zustandswechsel auf 0, sonst nur in `s_offen`/`s_gesperrt` hochzählen (sonst läuft der Zähler im Ruhezustand über den Wertebereich hinaus – die Simulation bricht dann ab).
  - `fehler`: beim Öffnen oder Sperren auf 0, bei `falsch` + 1.
- Ausgänge nebenläufig (Moore).

## Aufgabe
Schreibe `architecture behav of codeschloss` (Entity aus P05). Signale: `current_state`, `next_state`, `fehler : integer range 0 to 2`, `zeit : integer range 0 to 255`, `richtig`, `falsch`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of codeschloss is
  type state_type is (z0, z1, z2, s_offen, s_gesperrt);
  signal current_state, next_state : state_type;
  signal fehler : integer range 0 to 2;
  signal zeit   : integer range 0 to 255;
  signal richtig, falsch : std_logic;
begin
  pruefen: process(current_state, taste, ziffer) is
    variable erwartet : natural range 0 to 9;
  begin
    case current_state is
      when z0     => erwartet := C1;
      when z1     => erwartet := C2;
      when others => erwartet := C3;
    end case;
    richtig <= '0';
    falsch  <= '0';
    if taste = '1' and (current_state = z0 or
       current_state = z1 or current_state = z2) then
      if to_integer(unsigned(ziffer)) = erwartet then
        richtig <= '1';
      else
        falsch <= '1';
      end if;
    end if;
  end process pruefen;

  transition_function: process(current_state, richtig,
                               falsch, fehler, zeit) is
  begin
    next_state <= current_state;
    case current_state is
      when z0 | z1 | z2 =>
        if falsch = '1' then
          if fehler = 2 then
            next_state <= s_gesperrt;
          else
            next_state <= z0;
          end if;
        elsif richtig = '1' then
          case current_state is
            when z0     => next_state <= z1;
            when z1     => next_state <= z2;
            when others => next_state <= s_offen;
          end case;
        end if;
      when s_offen =>
        if zeit = T_OFFEN - 1 then next_state <= z0; end if;
      when s_gesperrt =>
        if zeit = T_SPERRE - 1 then next_state <= z0; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= z0;
      fehler <= 0;
      zeit   <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;
        elsif current_state = s_offen or
              current_state = s_gesperrt then
          zeit <= zeit + 1;
        end if;
        if next_state = s_offen or
           next_state = s_gesperrt then
          fehler <= 0;
        elsif falsch = '1' then
          fehler <= fehler + 1;
        end if;
      end if;
    end if;
  end process state;

  offen    <= '1' when current_state = s_offen else '0';
  gesperrt <= '1' when current_state = s_gesperrt else '0';
end architecture behav;
```
Feinheit: In `s_gesperrt` erzeugt `pruefen` kein `falsch`, deshalb werden Eingaben dort ignoriert.
</details>

## Klausur
Zähler im Zustandsprozess wie im Steuerwerk aus F24 A1 (K02). Simulierbar in `am_rechner/L12/projekte_fsm.vhd`.
