library ieee; use ieee.std_logic_1164.all;

entity tb_siebenseg is
end entity tb_siebenseg;

architecture test of tb_siebenseg is
  signal hex : std_logic_vector(3 downto 0);
  signal seg : std_logic_vector(6 downto 0);
begin
  dut: entity work.siebenseg port map(hex => hex, seg => seg);

  stimulus: process is
  begin
    hex <= x"0"; wait for 10 ns; assert seg = "0111111" report "0 falsch" severity error;
    hex <= x"7"; wait for 10 ns; assert seg = "0000111" report "7 falsch" severity error;
    hex <= x"A"; wait for 10 ns; assert seg = "1110111" report "A falsch" severity error;
    hex <= x"F"; wait for 10 ns; assert seg = "1110001" report "F falsch" severity error;
    report "Test siebenseg beendet";
    wait;
  end process stimulus;
end architecture test;
