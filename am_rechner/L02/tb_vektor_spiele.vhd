library ieee; use ieee.std_logic_1164.all;

entity tb_vektor_spiele is
end entity tb_vektor_spiele;

architecture test of tb_vektor_spiele is
  signal a, getauscht, links, rotiert, invers, nullen : std_logic_vector(7 downto 0);
  signal oberes : std_logic_vector(3 downto 0);
  signal msb    : std_logic;
begin
  dut: entity work.vektor_spiele
    port map(a => a, msb => msb, oberes => oberes, getauscht => getauscht,
             links => links, rotiert => rotiert, invers => invers, nullen => nullen);

  stimulus: process is
  begin
    a <= "10110001";
    wait for 10 ns;
    assert msb = '1'                report "msb falsch"       severity error;
    assert oberes = "1011"          report "oberes falsch"    severity error;
    assert getauscht = "00011011"   report "getauscht falsch" severity error;
    assert links = "01100010"       report "links falsch"     severity error;
    assert rotiert = "11011000"     report "rotiert falsch"   severity error;
    assert invers = "01001110"      report "invers falsch"    severity error;
    assert nullen = x"00"           report "nullen falsch"    severity error;
    report "Test vektor_spiele beendet";
    wait;
  end process stimulus;
end architecture test;
