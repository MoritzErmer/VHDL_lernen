library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_bausteine is
end entity tb_bausteine;

architecture test of tb_bausteine is
  signal clk, res_n : std_logic := '0';
  -- M01
  signal r_en, r_clr : std_logic := '0';
  signal r_d, r_q : std_logic_vector(7 downto 0);
  -- M02
  signal s_load, s_shift, s_in, s_out : std_logic := '0';
  signal s_din, s_q : std_logic_vector(3 downto 0);
  -- M03
  signal z_en, z_ov : std_logic := '0';
  signal z_q : integer range 0 to 9;
  -- M04
  signal tick : std_logic;
  -- M05
  signal roh, sauber : std_logic := '0';
  -- M06
  signal duty : std_logic_vector(3 downto 0);
  signal pwm_out : std_logic;
  -- M07
  signal f_wr, f_rd, f_empty, f_full : std_logic := '0';
  signal f_din, f_dout : std_logic_vector(7 downto 0);
  -- M08
  signal m_we : std_logic := '0';
  signal m_addr : std_logic_vector(2 downto 0);
  signal m_din, m_dout : std_logic_vector(7 downto 0);
  -- M09
  signal rot, gelb, gruen : std_logic;
  -- M10
  signal t_start, tx, busy : std_logic := '0';
  signal t_data : std_logic_vector(7 downto 0);

  procedure takt(signal c : out std_logic) is
  begin
    wait for 5 ns; c <= '1'; wait for 5 ns; c <= '0';
  end procedure;
begin
  m01: entity work.register_n generic map(8) port map(clk, res_n, r_en, r_clr, r_d, r_q);
  m02: entity work.schiebe_reg generic map(4) port map(clk, res_n, s_load, s_shift, s_din, s_in, s_q, s_out);
  m03: entity work.zaehler_mod generic map(9) port map(clk, res_n, z_en, z_q, z_ov);
  m04: entity work.taktteiler generic map(4) port map(clk, res_n, tick);
  m05: entity work.entpreller generic map(4) port map(clk, res_n, roh, sauber);
  m06: entity work.pwm generic map(4) port map(clk, res_n, duty, pwm_out);
  m07: entity work.fifo generic map(4, 8) port map(clk, res_n, f_wr, f_rd, f_din, f_dout, f_empty, f_full);
  m08: entity work.ram generic map(3, 8) port map(clk, m_we, m_addr, m_din, m_dout);
  m09: entity work.ampel port map(clk, res_n, rot, gelb, gruen);
  m10: entity work.sender generic map(4) port map(clk, res_n, t_start, t_data, tx, busy);

  process is
    variable n : integer;
    variable bits : std_logic_vector(9 downto 0);
    variable folge : string(1 to 12);
  begin
    res_n <= '0'; duty <= "0100"; wait for 2 ns; res_n <= '1';
    -- M01
    r_d <= x"5A"; takt(clk); assert r_q = x"00" report "M01 ohne en" severity error;
    r_en <= '1'; takt(clk); assert r_q = x"5A" report "M01 en" severity error;
    r_clr <= '1'; takt(clk); assert r_q = x"00" report "M01 clr" severity error;
    r_en <= '0'; r_clr <= '0';
    -- M02: laden, dann zweimal schieben mit ser_in = 1
    s_din <= "1001"; s_load <= '1'; takt(clk); s_load <= '0';
    assert s_q = "1001" and s_out = '1' report "M02 load" severity error;
    s_shift <= '1'; s_in <= '1'; takt(clk); takt(clk); s_shift <= '0';
    assert s_q = "0111" report "M02 shift" severity error;
    -- M03: 10 Takte mit en -> wieder 0, ueberlauf bei 9
    z_en <= '1';
    for i in 1 to 9 loop takt(clk); end loop;
    assert z_q = 9 and z_ov = '1' report "M03 bei 9" severity error;
    takt(clk); assert z_q = 0 and z_ov = '0' report "M03 Ueberlauf" severity error;
    z_en <= '0';
    -- M04: tick zaehlen ueber 12 Takte -> 3
    n := 0;
    for i in 1 to 12 loop takt(clk); wait for 1 ns; if tick = '1' then n := n + 1; end if; end loop;
    assert n = 3 report "M04 tick " & integer'image(n) severity error;
    -- M05: kurzer Preller (2 Takte) wird ignoriert, langes Signal uebernommen
    roh <= '1'; takt(clk); takt(clk); roh <= '0'; takt(clk); takt(clk);
    assert sauber = '0' report "M05 Preller durchgekommen" severity error;
    roh <= '1'; for i in 1 to 5 loop takt(clk); end loop;
    assert sauber = '1' report "M05 nicht uebernommen" severity error;
    -- M06: duty 4 von 16 -> 4 von 16 Takten '1'
    n := 0;
    for i in 1 to 16 loop takt(clk); wait for 1 ns; if pwm_out = '1' then n := n + 1; end if; end loop;
    assert n = 4 report "M06 pwm " & integer'image(n) severity error;
    -- M07: 4 schreiben -> full, 5. ignoriert, lesen in Reihenfolge
    assert f_empty = '1' report "M07 empty" severity error;
    f_wr <= '1';
    for i in 1 to 5 loop f_din <= std_logic_vector(to_unsigned(i * 11, 8)); takt(clk); end loop;
    f_wr <= '0';
    assert f_full = '1' report "M07 full" severity error;
    f_rd <= '1';
    for i in 1 to 4 loop
      wait for 1 ns;
      assert to_integer(unsigned(f_dout)) = i * 11 report "M07 Reihenfolge" severity error;
      takt(clk);
    end loop;
    f_rd <= '0';
    assert f_empty = '1' report "M07 leer am Ende" severity error;
    -- M08
    m_we <= '1';
    for a in 0 to 7 loop m_addr <= std_logic_vector(to_unsigned(a, 3)); m_din <= std_logic_vector(to_unsigned(a + 100, 8)); takt(clk); end loop;
    m_we <= '0';
    for a in 0 to 7 loop
      m_addr <= std_logic_vector(to_unsigned(a, 3)); wait for 1 ns;
      assert to_integer(unsigned(m_dout)) = a + 100 report "M08 lesen" severity error;
    end loop;
    -- M09: Ampel ueber 12 Takte ab Reset protokollieren
    res_n <= '0'; wait for 1 ns; res_n <= '1';
    for i in 1 to 12 loop
      if rot = '1' and gelb = '1' then folge(i) := 'Y';
      elsif rot = '1' then folge(i) := 'R';
      elsif gruen = '1' then folge(i) := 'G';
      else folge(i) := 'g'; end if;
      takt(clk);
    end loop;
    report "M09 Ampelfolge: " & folge;
    assert folge = "RRRRRYGGGGgg" report "M09 Ampel" severity error;
    -- M10: 0xA5 senden, Bits in der Mitte jeder Bitzeit abtasten
    t_data <= x"A5"; t_start <= '1'; takt(clk); t_start <= '0';
    assert busy = '1' report "M10 busy" severity error;
    for b in 0 to 9 loop
      takt(clk); takt(clk); wait for 1 ns;
      bits(b) := tx;
      takt(clk); takt(clk);
    end loop;
    assert bits = '1' & x"A5" & '0' report "M10 Bitfolge" severity error;
    takt(clk);
    assert busy = '0' and tx = '1' report "M10 Ende" severity error;
    report "Test Block M beendet";
    wait;
  end process;
end architecture test;
