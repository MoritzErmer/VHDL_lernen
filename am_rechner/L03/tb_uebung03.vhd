library ieee; use ieee.std_logic_1164.all;

entity tb_uebung03 is
end entity tb_uebung03;

architecture test of tb_uebung03 is
  signal en : std_logic;
  signal a2 : std_logic_vector(1 downto 0);
  signal y  : std_logic_vector(3 downto 0);
  signal a, b : std_logic_vector(3 downto 0);
  signal gl, gr, kl : std_logic;
begin
  dec: entity work.decoder_2_4 port map(en => en, a => a2, y => y);
  vgl: entity work.vergleicher
    port map(a => a, b => b, gleich => gl, groesser => gr, kleiner => kl);

  stimulus: process is
  begin
    en <= '0'; a2 <= "10"; wait for 10 ns;
    assert y = "0000" report "Decoder: en=0" severity error;
    en <= '1'; wait for 10 ns;
    assert y = "0100" report "Decoder: a=10" severity error;

    a <= "1001"; b <= "0011"; wait for 10 ns;   -- 9 > 3
    assert gl = '0' and gr = '1' and kl = '0' report "9 vs 3" severity error;
    a <= "0101"; b <= "0101"; wait for 10 ns;   -- 5 = 5
    assert gl = '1' and gr = '0' and kl = '0' report "5 vs 5" severity error;
    a <= "0111"; b <= "1000"; wait for 10 ns;   -- 7 < 8
    assert gl = '0' and gr = '0' and kl = '1' report "7 vs 8" severity error;
    report "Test uebung03 beendet";
    wait;
  end process stimulus;
end architecture test;
