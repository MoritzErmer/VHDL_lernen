-- testet BEIDE Architectures von mux4 gleichzeitig
library ieee; use ieee.std_logic_1164.all;

entity tb_mux4 is
end entity tb_mux4;

architecture test of tb_mux4 is
  signal d0, d1, d2, d3, y1, y2 : std_logic_vector(7 downto 0);
  signal sel : std_logic_vector(1 downto 0);
begin
  -- gleiche Entity, verschiedene Architectures: entity work.<entity>(<architecture>)
  dut1: entity work.mux4(when_else)
    port map(d0 => d0, d1 => d1, d2 => d2, d3 => d3, sel => sel, y => y1);
  dut2: entity work.mux4(with_select)
    port map(d0 => d0, d1 => d1, d2 => d2, d3 => d3, sel => sel, y => y2);

  stimulus: process is
  begin
    d0 <= x"A0"; d1 <= x"B1"; d2 <= x"C2"; d3 <= x"D3";
    sel <= "00"; wait for 10 ns;
    assert y1 = x"A0" and y2 = x"A0" report "Fehler sel=00" severity error;
    sel <= "01"; wait for 10 ns;
    assert y1 = x"B1" and y2 = x"B1" report "Fehler sel=01" severity error;
    sel <= "10"; wait for 10 ns;
    assert y1 = x"C2" and y2 = x"C2" report "Fehler sel=10" severity error;
    sel <= "11"; wait for 10 ns;
    assert y1 = x"D3" and y2 = x"D3" report "Fehler sel=11" severity error;
    report "Test mux4 beendet";
    wait;
  end process stimulus;
end architecture test;
