-- Testbench fuer den Halbaddierer (wie Testbenches funktionieren: Lektion 6)
library ieee; use ieee.std_logic_1164.all;

entity tb_halbaddierer is
end entity tb_halbaddierer;

architecture test of tb_halbaddierer is
  signal a, b, s, c : std_logic;
begin
  dut: entity work.halbaddierer
    port map(a => a, b => b, s => s, c => c);

  stimulus: process is
  begin
    a <= '0'; b <= '0'; wait for 10 ns;
    assert s = '0' and c = '0' report "Fehler bei 0+0" severity error;
    a <= '0'; b <= '1'; wait for 10 ns;
    assert s = '1' and c = '0' report "Fehler bei 0+1" severity error;
    a <= '1'; b <= '0'; wait for 10 ns;
    assert s = '1' and c = '0' report "Fehler bei 1+0" severity error;
    a <= '1'; b <= '1'; wait for 10 ns;
    assert s = '0' and c = '1' report "Fehler bei 1+1" severity error;
    report "Test Halbaddierer beendet";
    wait;   -- Prozess fuer immer anhalten
  end process stimulus;
end architecture test;
