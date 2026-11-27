library ieee; use ieee.std_logic_1164.all;

entity tb_uebung04 is
end entity tb_uebung04;

architecture test of tb_uebung04 is
  signal req    : std_logic_vector(3 downto 0);
  signal code   : std_logic_vector(1 downto 0);
  signal valid  : std_logic;
  signal x, y   : std_logic_vector(7 downto 0);
  signal anzahl : std_logic_vector(3 downto 0);
begin
  pe:  entity work.prio_encoder_p port map(req => req, code => code, valid => valid);
  ez:  entity work.einsen_zaehlen port map(x => x, anzahl => anzahl);
  sp:  entity work.spiegeln       port map(x => x, y => y);

  stimulus: process is
  begin
    req <= "0000"; wait for 10 ns; assert valid = '0'                 report "PE 0000" severity error;
    req <= "0101"; wait for 10 ns; assert code = "10" and valid = '1' report "PE 0101" severity error;
    req <= "1000"; wait for 10 ns; assert code = "11" and valid = '1' report "PE 1000" severity error;

    x <= "00000000"; wait for 10 ns; assert anzahl = "0000" report "popcount 0" severity error;
    x <= "10110110"; wait for 10 ns; assert anzahl = "0101" report "popcount 5" severity error;
    assert y = "01101101" report "spiegeln" severity error;
    x <= "11111111"; wait for 10 ns; assert anzahl = "1000" report "popcount 8" severity error;
    report "Test uebung04 beendet";
    wait;
  end process stimulus;
end architecture test;
