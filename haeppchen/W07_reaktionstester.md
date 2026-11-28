# W07 · Reaktionstester

25 min · zurück: [W06](W06_aufzug.md) · weiter: [W08](W08_uart_rx.md)

## Ziel
Mehrere Prozesse (Zufall, Teiler, Ablauf) zu einem Gerät zusammensetzen.

## Erklärung
Ein Reaktionstester:
1. `start` (Impuls): Eine zufällige Zeit warten: `WARTE_MIN_MS` plus 0 bis 15 mal `WARTE_SCHRITT_MS` Millisekunden.
2. Dann leuchtet `led`, und die Zeit läuft in Millisekunden.
3. `taste` (Impuls): Die Zeit bleibt stehen, `gueltig = '1'`, `ergebnis` zeigt die Millisekunden (höchstens 999).
4. Wer in der Wartezeit drückt, bekommt `fruehstart = '1'`.
5. Mit `start` geht es jederzeit wieder von vorn los.

Ports und Generics:
- Generics `TAKTE_PRO_MS := 50_000`, `WARTE_MIN_MS := 1000`, `WARTE_SCHRITT_MS := 200`
- `clk`, `res_n`, `start`, `taste : in std_logic`
- `led`, `fruehstart`, `gueltig : out std_logic`, `ergebnis : out natural range 0 to 999`

Zufall: ein 8-Bit-LFSR (S09) läuft in jedem Takt. Die unteren 4 Bit beim Start ergeben die Zufallszahl.

## Aufgabe
Schreibe Entity `reaktionstester` und Architecture `behav` mit drei Prozessen: `zufall`, `teiler` (Millisekunden-Impuls `ms_tick`) und `ablauf` (Zustand, Restzeit, Messzeit).

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity reaktionstester is
  generic(
    TAKTE_PRO_MS : positive := 50_000;
    WARTE_MIN_MS : positive := 1000;   -- mindestens so lange warten
    WARTE_SCHRITT_MS : positive := 200 -- plus zufaellig 0..15 Schritte
    );
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;        -- Impuls
    taste      : in  std_logic;        -- Impuls
    led        : out std_logic;        -- jetzt druecken!
    fruehstart : out std_logic;
    ergebnis   : out natural range 0 to 999;   -- Reaktionszeit in ms
    gueltig    : out std_logic
    );
end entity reaktionstester;

architecture behav of reaktionstester is
  type state_type is (bereit, warten, messen, fertig, zu_frueh);
  signal state : state_type;
  signal lfsr  : std_logic_vector(7 downto 0);
  signal ms_teiler : natural range 0 to TAKTE_PRO_MS - 1;
  signal ms_tick   : std_logic;
  signal rest  : natural range 0 to WARTE_MIN_MS + 15 * WARTE_SCHRITT_MS;
  signal zeit  : natural range 0 to 999;
begin
  -- Zufall: laeuft immer, der Zeitpunkt des Starts bestimmt den Wert
  zufall: process(clk, res_n) is
  begin
    if res_n = '0' then
      lfsr <= "00000001";
    else
      if clk'event and clk = '1' then
        if lfsr(7) = '1' then
          lfsr <= (lfsr(6 downto 0) xor "0001110") & lfsr(7);
        else
          lfsr <= lfsr(6 downto 0) & lfsr(7);
        end if;
      end if;
    end if;
  end process zufall;

  -- Millisekunden-Takt
  teiler: process(clk, res_n) is
  begin
    if res_n = '0' then
      ms_teiler <= 0;
      ms_tick <= '0';
    else
      if clk'event and clk = '1' then
        ms_tick <= '0';
        if state = bereit then
          ms_teiler <= 0;
        elsif ms_teiler = TAKTE_PRO_MS - 1 then
          ms_teiler <= 0;
          ms_tick <= '1';
        else
          ms_teiler <= ms_teiler + 1;
        end if;
      end if;
    end if;
  end process teiler;

  ablauf: process(clk, res_n) is
  begin
    if res_n = '0' then
      state <= bereit;
      rest <= 0;
      zeit <= 0;
    else
      if clk'event and clk = '1' then
        case state is
          when bereit | fertig | zu_frueh =>
            if start = '1' then
              state <= warten;
              rest <= WARTE_MIN_MS + to_integer(unsigned(lfsr(3 downto 0))) * WARTE_SCHRITT_MS;
              zeit <= 0;
            end if;
          when warten =>
            if taste = '1' then
              state <= zu_frueh;
            elsif ms_tick = '1' then
              if rest = 0 then
                state <= messen;
              else
                rest <= rest - 1;
              end if;
            end if;
          when messen =>
            if taste = '1' then
              state <= fertig;
            elsif ms_tick = '1' and zeit < 999 then
              zeit <= zeit + 1;
            end if;
        end case;
      end if;
    end if;
  end process ablauf;

  led        <= '1' when state = messen else '0';
  fruehstart <= '1' when state = zu_frueh else '0';
  gueltig    <= '1' when state = fertig else '0';
  ergebnis   <= zeit;
end architecture behav;
```
Der Teiler steht in `bereit` still, damit die erste Millisekunde nach dem Start voll gezählt wird.
</details>

## Klausur
Taktteiler als Enable (M04), LFSR (S09), Automat mit Zählern (P05).
