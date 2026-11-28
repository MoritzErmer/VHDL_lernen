-- Testbench fuer Block W (alle Werkstatt-Aufgaben ausser ggT, der hat eine eigene: tb_ggt.vhd)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity tb_werkstatt is
end entity tb_werkstatt;

architecture sim of tb_werkstatt is
  constant T : time := 10 ns;
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  signal ende : boolean := false;
  -- Lauflicht
  signal en : std_logic := '0';
  signal leds : std_logic_vector(3 downto 0);
  -- Parkhaus
  signal la, lb, voll : std_logic := '0';
  signal belegt : natural range 0 to 2;
  -- Stoppuhr
  signal start_stop, nullen : std_logic := '0';
  signal zehntel : natural range 0 to 9;
  signal sekunden : natural range 0 to 59;
  signal minuten : natural range 0 to 9;
  -- Fussgaengerampel
  signal f_taste : std_logic := '0';
  signal a_rot, a_gelb, a_gruen, f_rot, f_gruen, kommt : std_logic;
  -- Aufzug
  signal ruf : std_logic_vector(2 downto 0) := "000";
  signal m_hoch, m_runter, tuer : std_logic;
  signal etage : natural range 0 to 2;
  -- Reaktionstester
  signal r_start, r_taste, r_led, r_frueh, r_gueltig : std_logic := '0';
  signal r_ergebnis : natural range 0 to 999;
  -- UART
  signal rx : std_logic := '1';
  signal u_daten : std_logic_vector(7 downto 0);
  signal u_gueltig, u_par, u_rahmen : std_logic;
  -- SPI
  signal s_start, s_busy, sclk, mosi, cs_n : std_logic := '0';
  signal s_tx, s_rx : std_logic_vector(7 downto 0) := x"00";
  signal slave_sr : std_logic_vector(7 downto 0) := x"00";
  signal slave_antwort : std_logic_vector(7 downto 0) := x"C3";
  signal antwort_sr : std_logic_vector(7 downto 0) := x"00";
  signal miso : std_logic;
  -- Multiplizierer
  signal m_start, m_fertig : std_logic := '0';
  signal ma, mb : std_logic_vector(7 downto 0) := x"00";
  signal mp : std_logic_vector(15 downto 0);
  -- Frequenzzaehler
  signal sig : std_logic := '0';
  signal frequenz : natural range 0 to 2**20 - 1;
  signal f_neu : std_logic;
  -- Arbiter
  signal req, grant : std_logic_vector(3 downto 0) := "0000";
  -- Mini-CPU
  signal pc : std_logic_vector(3 downto 0);
  signal befehl, ausgabe : std_logic_vector(7 downto 0);
  signal aus_gueltig, halt : std_logic;
  type rom_type is array (0 to 15) of std_logic_vector(7 downto 0);
  -- Programm: gibt 5, 4, 3, 2, 1 aus und danach die Summe 15, dann HLT
  constant ROM : rom_type := (
    x"05",   --  0: LDI 5
    x"40",   --  1: ST 0     Zaehler
    x"00",   --  2: LDI 0
    x"41",   --  3: ST 1     Summe
    x"30",   --  4: LD 0
    x"7D",   --  5: JZ 13
    x"80",   --  6: OUT
    x"51",   --  7: ADD 1
    x"41",   --  8: ST 1
    x"30",   --  9: LD 0
    x"21",   -- 10: SUBI 1
    x"40",   -- 11: ST 0
    x"64",   -- 12: JMP 4
    x"31",   -- 13: LD 1
    x"80",   -- 14: OUT
    x"F0");  -- 15: HLT
begin
  clk <= not clk after T/2 when not ende;

  d_lauf: entity work.lauflicht generic map(N => 4, T_SCHRITT => 2) port map(clk, res_n, en, leds);
  d_park: entity work.parkhaus generic map(PLAETZE => 2) port map(clk, res_n, la, lb, belegt, voll);
  d_uhr: entity work.stoppuhr generic map(TAKTE_PRO_ZEHNTEL => 2)
    port map(clk, res_n, start_stop, nullen, zehntel, sekunden, minuten);
  d_ampel: entity work.fussgaengerampel generic map(T_GRUEN_MIN => 6, T_GELB => 2, T_FUSS => 4, T_RAEUMEN => 2, T_ROTGELB => 1)
    port map(clk, res_n, f_taste, a_rot, a_gelb, a_gruen, f_rot, f_gruen, kommt);
  d_aufzug: entity work.aufzug generic map(T_FAHRT => 3, T_TUER => 2)
    port map(clk, res_n, ruf, m_hoch, m_runter, tuer, etage);
  d_reakt: entity work.reaktionstester generic map(TAKTE_PRO_MS => 2, WARTE_MIN_MS => 5, WARTE_SCHRITT_MS => 1)
    port map(clk, res_n, r_start, r_taste, r_led, r_frueh, r_ergebnis, r_gueltig);
  d_uart: entity work.uart_rx generic map(TAKTE_PRO_BIT => 8)
    port map(clk, res_n, rx, u_daten, u_gueltig, u_par, u_rahmen);
  d_spi: entity work.spi_master generic map(TEILER => 2)
    port map(clk, res_n, s_start, s_tx, s_rx, s_busy, sclk, mosi, cs_n, miso);
  d_mult: entity work.mult_seq generic map(N => 8) port map(clk, res_n, m_start, ma, mb, mp, m_fertig);
  d_freq: entity work.frequenzzaehler generic map(TORZEIT => 100) port map(clk, res_n, sig, frequenz, f_neu);
  d_arb: entity work.arbiter port map(clk, res_n, req, grant);
  d_cpu: entity work.mini_cpu port map(clk, res_n, pc, befehl, ausgabe, aus_gueltig, halt);

  befehl <= ROM(to_integer(unsigned(pc)));

  -- SPI-Slave: liest MOSI bei steigender SCLK, schiebt seine Antwort bei fallender SCLK heraus
  slave: process(sclk, cs_n) is
  begin
    if cs_n = '1' then
      antwort_sr <= slave_antwort;
    elsif sclk'event and sclk = '1' then
      slave_sr <= slave_sr(6 downto 0) & mosi;
    elsif sclk'event and sclk = '0' then
      antwort_sr <= antwort_sr(6 downto 0) & '0';
    end if;
  end process slave;
  miso <= antwort_sr(7);

  process is
    procedure takt(n : positive := 1) is
    begin
      for i in 1 to n loop
        wait until clk'event and clk = '1';
      end loop;
      wait for 1 ns;
    end procedure;

    procedure puls(signal s : out std_logic) is
    begin
      s <= '1'; takt; s <= '0';
    end procedure;

    procedure auto(rein : boolean) is
    begin
      if rein then
        la <= '1'; takt(2); lb <= '1'; takt(2); la <= '0'; takt(2); lb <= '0'; takt(2);
      else
        lb <= '1'; takt(2); la <= '1'; takt(2); lb <= '0'; takt(2); la <= '0'; takt(2);
      end if;
    end procedure;

    procedure uart_send(d : std_logic_vector(7 downto 0); par_ok, stop_ok : boolean) is
      variable p : std_logic := '0';
    begin
      rx <= '0'; wait for 8 * T;
      for i in 0 to 7 loop
        rx <= d(i); p := p xor d(i); wait for 8 * T;
      end loop;
      if par_ok then rx <= p; else rx <= not p; end if;
      wait for 8 * T;
      if stop_ok then rx <= '1'; else rx <= '0'; end if;
      wait for 8 * T;
      rx <= '1';
      wait for 8 * T;
    end procedure;

    procedure multipliziere(x, y : natural) is
    begin
      ma <= std_logic_vector(to_unsigned(x, 8));
      mb <= std_logic_vector(to_unsigned(y, 8));
      puls(m_start);
      while m_fertig = '0' loop takt; end loop;
      assert to_integer(unsigned(mp)) = x * y
        report "Multiplikation " & integer'image(x) & "*" & integer'image(y) & " falsch" severity error;
    end procedure;

    variable gesehen : std_logic_vector(3 downto 0);
    variable n : natural;
    variable ausgaben : natural;
    variable letzte : natural;
  begin
    takt; res_n <= '1'; takt;

    -- W02 Lauflicht: Positionen 0 1 2 3 2 1 0 1
    en <= '1';
    for i in 0 to 7 loop
      case i is
        when 0 | 6 => assert leds = "0001" report "Lauflicht Schritt " & integer'image(i) severity error;
        when 1 | 5 | 7 => assert leds = "0010" report "Lauflicht Schritt " & integer'image(i) severity error;
        when 2 | 4 => assert leds = "0100" report "Lauflicht Schritt " & integer'image(i) severity error;
        when others => assert leds = "1000" report "Lauflicht Schritt 3" severity error;
      end case;
      takt(2);
    end loop;
    en <= '0';

    -- W03 Parkhaus: rein, rein (voll), rein (kein Platz), raus; abgebrochene Einfahrt
    auto(true);
    assert belegt = 1 report "Parkhaus 1 falsch" severity error;
    auto(true);
    assert belegt = 2 and voll = '1' report "Parkhaus voll falsch" severity error;
    auto(true);
    assert belegt = 2 report "Parkhaus zaehlt ueber" severity error;
    auto(false);
    assert belegt = 1 and voll = '0' report "Parkhaus raus falsch" severity error;
    la <= '1'; takt(2); la <= '0'; takt(2);                    -- nur angetastet
    assert belegt = 1 report "Parkhaus zaehlt abgebrochene Einfahrt" severity error;

    -- W04 Stoppuhr: 2 Takte pro Zehntel, 1,3 s laufen lassen
    puls(start_stop);
    takt(26);
    puls(start_stop);
    assert sekunden = 1 and zehntel = 3 report "Stoppuhr falsch: " & integer'image(sekunden) & "," &
      integer'image(zehntel) severity error;
    takt(10);
    assert sekunden = 1 and zehntel = 3 report "Stoppuhr laeuft nach Stopp weiter" severity error;
    puls(nullen);
    assert sekunden = 0 and zehntel = 0 and minuten = 0 report "Stoppuhr nullen falsch" severity error;

    -- W05 Ampel: ohne Anforderung bleibt gruen; mit Anforderung kommt fuss_gruen
    takt(20);
    assert a_gruen = '1' and f_rot = '1' report "Ampel ohne Anforderung falsch" severity error;
    puls(f_taste);
    assert kommt = '1' report "Signal kommt fehlt" severity error;
    n := 0;
    while f_gruen = '0' loop takt; n := n + 1; assert n < 20 report "Fussgaenger wird nie gruen" severity failure; end loop;
    assert a_rot = '1' report "Autos nicht rot bei Fussgaenger gruen" severity error;
    takt(4);
    assert kommt = '0' report "Anforderung nicht geloescht" severity error;
    n := 0;
    while a_gruen = '0' loop takt; n := n + 1; end loop;
    assert f_rot = '1' report "Fussgaenger nicht rot" severity error;

    -- W06 Aufzug: Ruf aus Etage 2, dann 0
    puls(ruf(2));
    n := 0;
    while tuer = '0' loop takt; n := n + 1; assert n < 50 report "Aufzug kommt nicht" severity failure; end loop;
    assert etage = 2 report "Aufzug falsche Etage" severity error;
    puls(ruf(0));
    n := 0;
    while not (tuer = '1' and etage = 0) loop
      takt; n := n + 1; assert n < 50 report "Aufzug kommt nicht zurueck" severity failure;
      assert not (m_hoch = '1' and m_runter = '1') report "beide Motoren an" severity error;
      assert not (tuer = '1' and (m_hoch = '1' or m_runter = '1')) report "faehrt mit offener Tuer" severity error;
    end loop;

    -- W07 Reaktionstester: einmal zu frueh, einmal richtig
    puls(r_start);
    takt(3);
    puls(r_taste);
    assert r_frueh = '1' report "Fruehstart nicht erkannt" severity error;
    puls(r_start);
    while r_led = '0' loop takt; end loop;
    takt(10);                                                   -- 10 Takte = 5 ms
    puls(r_taste);
    assert r_gueltig = '1' and r_ergebnis = 5 report "Reaktionszeit " & integer'image(r_ergebnis) & " statt 5"
      severity error;

    -- W08 UART
    uart_send(x"A5", true, true);
    wait until u_gueltig = '1' for 200 * T;
    wait for 1 ns;
    assert u_daten = x"A5" and u_par = '0' and u_rahmen = '0' report "UART A5 falsch" severity error;
    uart_send(x"3C", false, true);
    wait until u_gueltig = '1' for 200 * T;
    wait for 1 ns;
    assert u_daten = x"3C" and u_par = '1' report "UART Paritaetsfehler nicht erkannt" severity error;
    uart_send(x"0F", true, false);
    wait until u_gueltig = '1' for 200 * T;
    wait for 1 ns;
    assert u_rahmen = '1' report "UART Rahmenfehler nicht erkannt" severity error;

    -- W09 SPI: senden x"5A", Slave antwortet x"C3"
    s_tx <= x"5A";
    puls(s_start);
    while s_busy = '1' loop takt; end loop;
    assert slave_sr = x"5A" report "SPI: Slave hat falsch empfangen" severity error;
    assert s_rx = x"C3" report "SPI: Master hat falsch empfangen" severity error;

    -- W11 Multiplizierer
    multipliziere(13, 11);
    multipliziere(255, 255);
    multipliziere(0, 77);

    -- W12 Frequenzzaehler: 7 Flanken pro Torzeit (100 Takte)
    wait until f_neu = '1';
    for i in 1 to 7 loop
      sig <= '1'; takt(5); sig <= '0'; takt(5);
    end loop;
    wait until f_neu = '1';
    wait for 1 ns;
    assert frequenz = 7 report "Frequenz " & integer'image(frequenz) & " statt 7" severity error;

    -- W13 Arbiter: alle fragen, jeder kommt der Reihe nach dran
    req <= "1111";
    gesehen := "0000";
    for i in 1 to 4 loop
      takt;
      assert grant = "0001" or grant = "0010" or grant = "0100" or grant = "1000"
        report "Arbiter: nicht genau ein grant" severity error;
      gesehen := gesehen or grant;
      req <= req and not grant;                              -- wer dran war, gibt ab
    end loop;
    assert gesehen = "1111" report "Arbiter: nicht jeder kam dran" severity error;
    req <= "0101"; takt(2);
    req <= "0100"; takt(2);
    assert grant = "0100" report "Arbiter: Wechsel nach Abgabe falsch" severity error;
    req <= "0000"; takt;

    report "tb_werkstatt fertig";
    ende <= true;
    wait;
  end process;

  -- Mini-CPU: Ausgaben mitschreiben
  cpu_check: process is
    variable n : natural := 0;
  begin
    wait until res_n = '1';
    loop
      wait until clk'event and clk = '1';
      exit when halt = '1';
      if aus_gueltig = '1' then
        n := n + 1;
        assert (n <= 5 and to_integer(unsigned(ausgabe)) = 6 - n) or (n = 6 and to_integer(unsigned(ausgabe)) = 15)
          report "CPU Ausgabe " & integer'image(n) & " falsch: " & integer'image(to_integer(unsigned(ausgabe)))
          severity error;
      end if;
    end loop;
    assert n = 6 report "CPU: " & integer'image(n) & " Ausgaben statt 6" severity error;
    report "Mini-CPU angehalten";
    wait;
  end process cpu_check;
end architecture sim;
