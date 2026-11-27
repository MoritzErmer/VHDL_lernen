library ieee; use ieee.std_logic_1164.all;

entity tb_uebung02 is
end entity tb_uebung02;

architecture test of tb_uebung02 is
  signal x, halb_signed, gespiegelt : std_logic_vector(7 downto 0);
  signal mal4         : std_logic_vector(9 downto 0);
  signal nibble_summe : std_logic_vector(4 downto 0);
begin
  dut: entity work.uebung02
    port map(x => x, mal4 => mal4, halb_signed => halb_signed,
             nibble_summe => nibble_summe, gespiegelt => gespiegelt);

  stimulus: process is
  begin
    x <= "11111010";   -- 250 bzw. -6
    wait for 10 ns;
    assert mal4 = "1111101000"     report "mal4 falsch"         severity error;
    assert halb_signed = "11111101" report "halb_signed falsch" severity error; -- -3
    assert nibble_summe = "11001"  report "nibble_summe falsch" severity error; -- 15+10=25
    assert gespiegelt = "01011111" report "gespiegelt falsch"   severity error;
    report "Test uebung02 beendet";
    wait;
  end process stimulus;
end architecture test;
