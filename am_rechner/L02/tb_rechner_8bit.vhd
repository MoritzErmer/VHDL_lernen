library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_rechner_8bit is
end entity tb_rechner_8bit;

architecture test of tb_rechner_8bit is
  signal a, b, differenz : std_logic_vector(7 downto 0);
  signal summe           : std_logic_vector(8 downto 0);
  signal a_als_u         : integer range 0 to 255;
  signal a_als_s         : integer range -128 to 127;
begin
  dut: entity work.rechner_8bit
    port map(a => a, b => b, summe => summe, differenz => differenz,
             a_als_u => a_als_u, a_als_s => a_als_s);

  stimulus: process is
  begin
    a <= x"F0";  -- = "11110000" = 240 (unsigned) bzw. -16 (signed)
    b <= x"20";  -- = 32
    wait for 10 ns;
    report "summe     = " & integer'image(to_integer(unsigned(summe)));
    report "differenz = " & integer'image(to_integer(unsigned(differenz)));
    report "a_als_u   = " & integer'image(a_als_u);
    report "a_als_s   = " & integer'image(a_als_s);
    assert summe = "100010000"  report "summe falsch"     severity error;
    assert differenz = x"D0"    report "differenz falsch" severity error;
    assert a_als_u = 240        report "a_als_u falsch"   severity error;
    assert a_als_s = -16        report "a_als_s falsch"   severity error;
    report "Test rechner_8bit beendet";
    wait;
  end process stimulus;
end architecture test;
