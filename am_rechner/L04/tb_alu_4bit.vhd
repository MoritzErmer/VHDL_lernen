library ieee; use ieee.std_logic_1164.all;

entity tb_alu_4bit is
end entity tb_alu_4bit;

architecture test of tb_alu_4bit is
  signal a, b, y : std_logic_vector(3 downto 0);
  signal op      : std_logic_vector(1 downto 0);
  signal zero    : std_logic;
begin
  dut: entity work.alu_4bit port map(a => a, b => b, op => op, y => y, zero => zero);

  stimulus: process is
  begin
    a <= "0101"; b <= "0011";
    op <= "00"; wait for 10 ns; assert y = "1000" and zero = '0' report "5+3"   severity error;
    op <= "01"; wait for 10 ns; assert y = "0010" and zero = '0' report "5-3"   severity error;
    op <= "10"; wait for 10 ns; assert y = "0001" and zero = '0' report "5 and 3" severity error;
    op <= "11"; wait for 10 ns; assert y = "0111" and zero = '0' report "5 or 3"  severity error;
    a <= "1010"; b <= "0101";
    op <= "10"; wait for 10 ns; assert y = "0000" and zero = '1' report "zero-Flag" severity error;
    report "Test alu_4bit beendet";
    wait;
  end process stimulus;
end architecture test;
