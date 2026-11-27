library ieee; use ieee.std_logic_1164.all;

entity tb_prio_encoder is
end entity tb_prio_encoder;

architecture test of tb_prio_encoder is
  signal req  : std_logic_vector(3 downto 0);
  signal code : std_logic_vector(1 downto 0);
  signal valid : std_logic;
begin
  dut: entity work.prio_encoder port map(req => req, code => code, valid => valid);

  stimulus: process is
  begin
    req <= "0000"; wait for 10 ns; assert valid = '0' report "valid bei 0000" severity error;
    req <= "0001"; wait for 10 ns; assert code = "00" and valid = '1' report "0001" severity error;
    req <= "0110"; wait for 10 ns; assert code = "10" and valid = '1' report "0110" severity error;
    req <= "1011"; wait for 10 ns; assert code = "11" and valid = '1' report "1011" severity error;
    report "Test prio_encoder beendet";
    wait;
  end process stimulus;
end architecture test;
