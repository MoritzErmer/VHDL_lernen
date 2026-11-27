-- Prueft alle Block-L-Schaltungen: behav und struct muessen sich gleich verhalten
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_block_l is
end entity tb_block_l;

architecture test of tb_block_l is
  signal a, b, c : std_logic;
  signal ha_s1, ha_c1, ha_s2, ha_c2, y1, z1, y2, z2, m1, m2, mx1, mx2, va_s, va_c : std_logic;
  signal d4 : std_logic_vector(3 downto 0);
  signal sel2 : std_logic_vector(1 downto 0);
  signal m4a, m4b : std_logic;
  signal a2, b2, s2 : std_logic_vector(1 downto 0);
  signal c2 : std_logic;
  signal clk, res_n, taste : std_logic := '0';
  signal zq0a, zq1a, zq0b, zq1b, pa, pb : std_logic;
  signal anzahl : std_logic_vector(3 downto 0);
  signal n2y, n2z : std_logic;
begin
  ha1: entity work.halbaddierer(behav)  port map(a, b, ha_s1, ha_c1);
  ha2: entity work.halbaddierer(struct) port map(a, b, ha_s2, ha_c2);
  n1:  entity work.netz(behav)  port map(a, b, c, y1, z1);
  n2:  entity work.netz(struct) port map(a, b, c, y2, z2);
  me1: entity work.mehrheit(behav)  port map(a, b, c, m1);
  me2: entity work.mehrheit(struct) port map(a, b, c, m2);
  mu1: entity work.mux2(behav)  port map(a, b, c, mx1);
  mu2: entity work.mux2(struct) port map(a, b, c, mx2);
  va:  entity work.volladdierer port map(a, b, c, va_s, va_c);
  m41: entity work.mux4(behav)  port map(d4, sel2, m4a);
  m42: entity work.mux4(struct) port map(d4, sel2, m4b);
  add: entity work.addierer_2bit port map(a2, b2, s2, c2);
  z1i: entity work.zaehler2(behav)  port map(clk, res_n, zq0a, zq1a);
  z2i: entity work.zaehler2(struct) port map(clk, res_n, zq0b, zq1b);
  f1:  entity work.flanke_s(behav)  port map(clk, res_n, taste, pa);
  f2:  entity work.flanke_s(struct) port map(clk, res_n, taste, pb);
  top: entity work.tasten_zaehler port map(clk, res_n, taste, anzahl);
  nz2: entity work.netz2 port map(a, b, c, n2y, n2z);

  process is
    variable v : unsigned(2 downto 0);
    variable n : integer;
    procedure takt is begin
      clk <= '1'; wait for 5 ns; clk <= '0'; wait for 5 ns;
    end procedure;
  begin
    for i in 0 to 7 loop
      v := to_unsigned(i, 3);
      a <= v(2); b <= v(1); c <= v(0);
      wait for 10 ns;
      assert ha_s1 = ha_s2 and ha_c1 = ha_c2 report "halbaddierer" severity error;
      assert y1 = y2 and z1 = z2 report "netz" severity error;
      assert m1 = m2 report "mehrheit" severity error;
      assert n2y = (a and b) and n2z = ((a and b) or c) report "netz2" severity error;
      assert mx1 = mx2 report "mux2" severity error;
      n := to_integer(v(2 downto 2)) + to_integer(v(1 downto 1)) + to_integer(v(0 downto 0));
      assert unsigned'(va_c & va_s) = to_unsigned(n, 2) report "volladdierer" severity error;
      assert m1 = '1' xnor (n >= 2) = true report "mehrheit falsch" severity error;
    end loop;
    for i in 0 to 63 loop
      d4 <= std_logic_vector(to_unsigned(i, 6)(3 downto 0));
      sel2 <= std_logic_vector(to_unsigned(i, 6)(5 downto 4));
      wait for 10 ns;
      assert m4a = m4b report "mux4" severity error;
    end loop;
    for i in 0 to 15 loop
      a2 <= std_logic_vector(to_unsigned(i, 4)(3 downto 2));
      b2 <= std_logic_vector(to_unsigned(i, 4)(1 downto 0));
      wait for 10 ns;
      assert to_integer(unsigned(c2 & s2)) = (i / 4) + (i mod 4) report "addierer_2bit" severity error;
    end loop;
    -- getaktet: Zaehler und Flanke, behav gegen struct
    res_n <= '0'; wait for 3 ns; res_n <= '1';
    for i in 0 to 9 loop
      takt;
      assert zq0a = zq0b and zq1a = zq1b report "zaehler2" severity error;
      assert to_integer(unsigned'(zq1a & zq0a)) = (i + 1) mod 4 report "zaehler2 zaehlt falsch" severity error;
    end loop;
    for i in 0 to 19 loop
      if i mod 5 = 1 then taste <= '1'; elsif i mod 5 = 3 then taste <= '0'; end if;
      wait for 2 ns;
      assert pa = pb report "flanke_s" severity error;
      takt;
    end loop;
    takt; takt; takt;
    report "Tastendruecke gezaehlt: " & integer'image(to_integer(unsigned(anzahl))) & " (erwartet 4)";
    assert to_integer(unsigned(anzahl)) = 4 report "tasten_zaehler" severity error;
    report "Test Block L beendet";
    wait;
  end process;
end architecture test;
