-- Testbench fuer alle Projekte aus Block P
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use work.keller_types.all;
entity tb_projekte is
end entity tb_projekte;

architecture sim of tb_projekte is
  constant T : time := 10 ns;
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  signal fertig_sim : boolean := false;
  -- Getraenkeautomat
  signal m1, m2, ausgabe, rueckgeld : std_logic := '0';
  -- Codeschloss
  signal taste, offen, gesperrt : std_logic := '0';
  signal ziffer : std_logic_vector(3 downto 0) := "0000";
  -- Tastatur
  signal lines : std_logic_vector(3 downto 0) := "0000";
  signal columns : std_logic_vector(7 downto 0);
  signal c_num : std_logic_vector(2 downto 0);
  signal l_num : std_logic_vector(1 downto 0);
  signal key_changed, key_state : std_logic;
  -- Empfaenger
  signal ser : std_logic := '0';
  signal par_out : std_logic_vector(7 downto 0);
  signal par_out_ena : std_logic;
  -- Dividierer
  signal init, valid : std_logic := '0';
  signal a, b, q, r : std_logic_vector(3 downto 0) := "0000";
  -- Oszillator
  signal period : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(6, 4));
  signal wave : std_logic;
  signal key_num : std_logic_vector(3 downto 0) := "1010";
  signal rom_period : std_logic_vector(17 downto 0);
  -- Kellerautomat
  signal gedrueckt : boolean := false;
  signal kx : input_type := '!';  -- '!' haelt den Automaten im Grundzustand
  signal ky : output_type;
begin
  clk <= not clk after T/2 when not fertig_sim;

  dut1: entity work.getraenk port map(clk, res_n, m1, m2, ausgabe, rueckgeld);
  dut2: entity work.codeschloss generic map(T_OFFEN => 4, T_SPERRE => 8)
    port map(clk, res_n, taste, ziffer, offen, gesperrt);
  dut3: entity work.keyboard_controller
    port map(clk, res_n, lines, columns, c_num, l_num, key_changed, key_state);
  dut4: entity work.receiver generic map(BIT_TAKTE => 8)
    port map(clk, res_n, ser, par_out, par_out_ena);
  dut5: entity work.div_seq generic map(N => 4, M => 4)
    port map(clk, res_n, init, a, b, q, r, valid);
  dut6: entity work.osc generic map(N => 4) port map(clk, res_n, period, wave);
  dut6r: entity work.period_rom port map(key_num, rom_period);
  dut7: entity work.kellerautomat port map(clk, res_n, kx, ky);

  -- Tastatur: Taste an Spalte 5, Zeile 2 gedrueckt, Zeilen haengen an der aktiven Spalte
  lines <= "0100" when columns(5) = '1' and gedrueckt else "0000";

  process is
    procedure takt(n : positive := 1) is
    begin
      for i in 1 to n loop
        wait until clk'event and clk = '1';
      end loop;
      wait for 1 ns;
    end procedure;

    procedure muenze(signal m : out std_logic) is
    begin
      m <= '1'; takt; m <= '0';
    end procedure;

    procedure tippe(z : natural) is
    begin
      ziffer <= std_logic_vector(to_unsigned(z, 4));
      taste <= '1'; takt; taste <= '0'; takt;
    end procedure;

    procedure send_byte(d : std_logic_vector(7 downto 0)) is
    begin
      ser <= '1'; wait for 8 * T;               -- Startbit
      for i in 0 to 7 loop
        ser <= d(i); wait for 8 * T;            -- LSB zuerst
      end loop;
      ser <= '0'; wait for 8 * T;               -- Stoppbit
    end procedure;

    procedure keller(folge : string; erwartet : output_type) is
    begin
      for i in folge'range loop
        kx <= input_type'value("'" & folge(i) & "'");
        wait for 1 ns;                          -- Mealy-Ausgang vor der Flanke
        if folge(i) = '!' then
          assert ky = erwartet report "Kellerautomat falsch bei " & folge severity error;
        else
          assert ky = '*' report "Kellerautomat: '*' erwartet" severity error;
        end if;
        takt;
      end loop;
    end procedure;

    procedure dividiere(av, bv, qv, rv : natural) is
    begin
      a <= std_logic_vector(to_unsigned(av, 4));
      b <= std_logic_vector(to_unsigned(bv, 4));
      init <= '1'; takt; init <= '0';
      for i in 1 to 3 loop
        assert valid = '0' report "valid zu frueh" severity error;
        takt;
      end loop;
      takt;                                     -- N = 4 Takte nach init
      assert valid = '1' and unsigned(q) = qv and unsigned(r) = rv
        report "Division " & integer'image(av) & "/" & integer'image(bv) & " falsch" severity error;
      takt;
      assert valid = '0' report "valid zu lang" severity error;
    end procedure;

    variable ok_keys : boolean;
  begin
    wait for 2 ns;
    res_n <= '0'; wait for 25 ns; res_n <= '1';
    takt;

    -- 1) Getraenkeautomat: 1 + 2 -> Ausgabe; 2 + 2 -> Ausgabe mit Rueckgeld
    muenze(m1);
    m2 <= '1'; takt; m2 <= '0';
    assert ausgabe = '1' and rueckgeld = '0' report "Getraenk 1+2 falsch" severity error;
    takt;
    assert ausgabe = '0' report "Getraenk Ausgabe zu lang" severity error;
    muenze(m2);
    m2 <= '1'; takt; m2 <= '0';
    assert ausgabe = '1' and rueckgeld = '1' report "Getraenk 2+2 falsch" severity error;
    takt;
    muenze(m1); muenze(m1); muenze(m1);
    assert ausgabe = '1' and rueckgeld = '0' report "Getraenk 1+1+1 falsch" severity error;
    takt;

    -- 2) Codeschloss: richtiger Code 3 5 1
    tippe(3); tippe(5); tippe(1);
    assert offen = '1' report "Codeschloss nicht offen" severity error;
    takt(5);
    assert offen = '0' report "Codeschloss bleibt zu lange offen" severity error;
    -- falsch, falsch, dann richtig: oeffnet trotzdem
    tippe(4); tippe(3); tippe(2); tippe(3); tippe(5); tippe(1);
    assert offen = '1' and gesperrt = '0' report "Codeschloss nach zwei Fehlern falsch" severity error;
    takt(6);
    -- drei Fehler: gesperrt, Eingaben werden ignoriert
    tippe(9); tippe(9); tippe(9);
    assert gesperrt = '1' report "Codeschloss nicht gesperrt" severity error;
    tippe(3); tippe(5); tippe(1);
    assert offen = '0' report "Codeschloss oeffnet trotz Sperre" severity error;
    takt(8);
    assert gesperrt = '0' report "Sperre endet nicht" severity error;

    -- 3) Tastatur: nach einem vollen Durchlauf (32 Takte) muss die Taste gemeldet sein
    ok_keys := false;
    gedrueckt <= true;
    for i in 1 to 40 loop
      if key_changed = '1' and c_num = "101" and l_num = "10" and key_state = '1' then
        ok_keys := true;
      end if;
      takt;
    end loop;
    assert ok_keys report "Tastatur meldet Taste nicht" severity error;
    -- im zweiten Durchlauf keine Aenderung mehr
    for i in 1 to 32 loop
      assert key_changed = '0' report "Tastatur meldet Taste doppelt" severity error;
      takt;
    end loop;

    -- 4) Empfaenger
    send_byte(x"A5");
    wait for 30 * T;
    assert par_out = x"A5" report "Empfaenger falsch" severity error;
    send_byte(x"3C");
    wait for 30 * T;
    assert par_out = x"3C" report "Empfaenger zweites Byte falsch" severity error;

    -- 5) Dividierer
    dividiere(14, 3, 4, 2);
    dividiere(13, 5, 2, 3);
    dividiere(15, 1, 15, 0);
    dividiere(7, 9, 0, 7);

    -- 6) Oszillator: Periode 6 -> 3 Takte '0', 3 Takte '1'; ROM A = 113636
    assert to_integer(unsigned(rom_period)) = 113636 report "ROM falsch" severity error;
    wait until wave'event and wave = '1';
    wait for 1 ns;
    takt(2); assert wave = '1' report "Oszillator zu kurz '1'" severity error;
    takt(1); assert wave = '0' report "Oszillator zu lang '1'" severity error;
    takt(2); assert wave = '0' report "Oszillator zu kurz '0'" severity error;
    takt(1); assert wave = '1' report "Oszillator zu lang '0'" severity error;

    -- 7) Kellerautomat: Beispiele gueltig und ungueltig
    keller("x-x!", '1');
    keller("(x-x)-[x]!", '1');
    keller("[(((x-[x])-x))]!", '1');
    keller("((x-[x]-x)-[[x]])!", '1');
    keller("xx!", '0');
    keller("x--x!", '0');
    keller("[x-x]!", '0');
    keller("(x-x]!", '0');
    keller("(x-[x]-x)-[[x]])!", '0');
    keller("(x!", '0');
    keller("x!", '1');

    report "tb_projekte fertig";
    fertig_sim <= true;
    wait;
  end process;
end architecture sim;
