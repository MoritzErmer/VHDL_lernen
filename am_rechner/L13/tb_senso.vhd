-- Testbench fuer Block S: Einzeltests der Komponenten und ein komplettes Spiel
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use work.senso_pkg.all;
entity tb_senso is
end entity tb_senso;

architecture sim of tb_senso is
  constant T : time := 20 ns;   -- 50 MHz
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  signal ende : boolean := false;
  -- Timer
  signal start_timer, dec_duration, res_duration, expired : std_logic := '0';
  -- Taster
  signal tx_n : std_logic := '1';
  signal key : std_logic;
  -- LFSR
  signal lreset : std_logic := '0';
  signal fb : std_logic_vector(7 downto 1) := "0111001";
  signal q1, q2 : std_logic_vector(7 downto 0);
  -- Ausgabe
  signal led_on, all_on : std_logic := '0';
  signal color : color_type := "00";
  signal leds_o : std_logic_vector(3 downto 0);
  -- Spiel
  signal key_in_n : std_logic_vector(3 downto 0) := "1111";
  signal leds : std_logic_vector(3 downto 0);
  signal score_low, score_high : seg7_type;
begin
  clk <= not clk after T/2 when not ende;

  u_timer: entity work.timer generic map(D_INIT => 10, D_STEP => 3, D_MIN => 4)
    port map(clk, res_n, start_timer, dec_duration, res_duration, expired);
  u_button: entity work.button port map(clk, res_n, tx_n, key);
  u_lfsr1: entity work.galois_lfsr(behav) port map(clk, res_n, lreset, fb, q1);
  u_lfsr2: entity work.galois_lfsr(loop_version) port map(clk, res_n, lreset, fb, q2);
  u_output: entity work.output port map(led_on, all_on, color, leds_o);
  u_senso: entity work.senso generic map(D_INIT => 12, D_STEP => 2, D_MIN => 6)
    port map(clk, res_n, key_in_n, leds, score_low, score_high);

  -- LFSR: beide Architectures muessen nach jeder Flanke gleich sein (geprueft in der Taktmitte)
  vergleich: process(clk) is
  begin
    if clk'event and clk = '0' and res_n = '1' then
      assert q1 = q2 report "LFSR-Varianten verschieden" severity error;
    end if;
  end process vergleich;

  process is
    procedure takt(n : positive := 1) is
    begin
      for i in 1 to n loop
        wait until clk'event and clk = '1';
      end loop;
      wait for 1 ns;
    end procedure;

    -- misst, wie viele Takte nach dem Start der Timer ablaeuft
    procedure miss_timer(erwartet : positive) is
      variable n : natural := 0;
    begin
      start_timer <= '1'; takt; start_timer <= '0';
      while expired = '0' loop
        takt; n := n + 1;
        assert n < 100 report "Timer laeuft nicht ab" severity failure;
      end loop;
      assert n = erwartet report "Timerdauer " & integer'image(n) & " statt " & integer'image(erwartet)
        severity error;
      takt;
      assert expired = '0' report "timer_expired laenger als einen Takt" severity error;
    end procedure;

    function ziffer(s : seg7_type) return integer is
    begin
      for i in 0 to 9 loop
        case i is
          when 0 => if s = ('0','0','0','0','0','0','1') then return 0; end if;
          when 1 => if s = ('1','0','0','1','1','1','1') then return 1; end if;
          when 2 => if s = ('0','0','1','0','0','1','0') then return 2; end if;
          when 3 => if s = ('0','0','0','0','1','1','0') then return 3; end if;
          when others => null;
        end case;
      end loop;
      return -1;
    end function;

    type folge_type is array (0 to 63) of integer range 0 to 3;
    variable folge : folge_type;
    variable n_pulses : natural;
    variable farbe : integer;

    procedure druecke(f : integer range 0 to 3) is
    begin
      key_in_n(f) <= '0'; takt(4); key_in_n(f) <= '1'; takt(4);
    end procedure;

    -- schaut zu, wie die Sequenz vorgespielt wird, und merkt sich die Farben
    procedure zuschauen(laenge : positive) is
    begin
      for i in 0 to laenge - 1 loop
        while leds = "0000" loop takt; end loop;
        assert leds = "0001" or leds = "0010" or leds = "0100" or leds = "1000"
          report "beim Vorspielen leuchtet nicht genau eine LED" severity error;
        for j in 0 to 3 loop
          if leds(j) = '1' then folge(i) := j; end if;
        end loop;
        while leds /= "0000" loop takt; end loop;
      end loop;
    end procedure;
  begin
    takt; res_n <= '1'; takt;

    -- 1) Timer: 10 Takte, kuerzer werden bis 4, zuruecksetzen
    miss_timer(10);
    dec_duration <= '1'; takt; dec_duration <= '0';
    miss_timer(7);
    dec_duration <= '1'; takt(3); dec_duration <= '0';   -- 7 -> 4, nicht weiter
    miss_timer(4);
    res_duration <= '1'; takt; res_duration <= '0';
    miss_timer(10);

    -- 2) Taster: langer Druck ergibt genau einen Impuls
    n_pulses := 0;
    tx_n <= '0';
    for i in 1 to 20 loop
      takt; if key = '1' then n_pulses := n_pulses + 1; end if;
    end loop;
    tx_n <= '1';
    for i in 1 to 5 loop
      takt; if key = '1' then n_pulses := n_pulses + 1; end if;
    end loop;
    assert n_pulses = 1 report "Taster: " & integer'image(n_pulses) & " Impulse statt 1" severity error;

    -- 3) LFSR: 250 -> 135 -> 125 -> 250 mit fb = "0111001"
    -- dafuer 250 einstellen: nach dem Reset so lange takten, bis 250 erscheint (liegt im Zyklus von 1?)
    -- 250 liegt nicht im Zyklus von 1, deshalb direkt am Modell pruefen: Zykluslaenge ab 1 ist 30
    lreset <= '1'; takt; lreset <= '0';
    for i in 1 to 30 loop takt; end loop;
    assert q1 = "00000001" report "LFSR: Zykluslaenge ab 1 ist nicht 30" severity error;
    fb <= "0001110";                                   -- maximale Laenge
    lreset <= '1'; takt; lreset <= '0';
    for i in 1 to 254 loop
      takt;
      assert q1 /= "00000001" report "LFSR: Zyklus kuerzer als 255" severity error;
    end loop;
    takt;
    assert q1 = "00000001" report "LFSR: Zyklus nicht 255" severity error;

    -- 4) Ausgabe
    led_on <= '1'; color <= "10"; wait for 1 ns;
    assert leds_o = "0100" report "Ausgabe gelb falsch" severity error;
    all_on <= '1'; wait for 1 ns;
    assert leds_o = "1111" report "Ausgabe alle falsch" severity error;
    led_on <= '0'; all_on <= '0'; wait for 1 ns;
    assert leds_o = "0000" report "Ausgabe aus falsch" severity error;

    -- 5) Das ganze Spiel: drei Runden richtig nachspielen, dann absichtlich falsch
    takt(37);                                          -- irgendwann starten (Zufall)
    assert ziffer(score_low) = 0 and ziffer(score_high) = 0 report "Punktestand nicht 00" severity error;
    druecke(0);                                        -- Start
    for runde in 1 to 3 loop
      zuschauen(runde);
      takt(20);                                        -- Pause nach dem Vorspielen abwarten
      for i in 0 to runde - 1 loop
        druecke(folge(i));
      end loop;
      takt(3);
      assert ziffer(score_low) = runde report "Punktestand nach Runde " & integer'image(runde) & " falsch"
        severity error;
    end loop;
    -- Runde 4: erste Farbe absichtlich falsch
    zuschauen(4);
    takt(20);
    druecke((folge(0) + 1) mod 4);
    takt(2);
    assert leds = "1111" report "Verloren wird nicht angezeigt" severity error;
    while leds = "1111" loop takt; end loop;
    takt(2);
    assert ziffer(score_low) = 0 report "Punktestand nach Neustart nicht 0" severity error;

    report "tb_senso fertig";
    ende <= true;
    wait;
  end process;
end architecture sim;
