-- Vergleicht Moore, Mealy und Medwedew mit der Folge aus Haeppchen F09
library ieee; use ieee.std_logic_1164.all;

entity tb_detektor is
end entity tb_detektor;

architecture test of tb_detektor is
  constant T : time := 20 ns;
  signal clk, res_n, x : std_logic := '0';
  signal y_moore, y_mealy, y_medw : std_logic;
  signal ende : boolean := false;
  constant FOLGE : std_logic_vector(1 to 8) := "10101101";
begin
  dut1: entity work.detektor(moore)
    port map(clk => clk, res_n => res_n, x => x, y => y_moore);
  dut2: entity work.detektor(mealy)
    port map(clk => clk, res_n => res_n, x => x, y => y_mealy);
  dut3: entity work.detektor(medwedew)
    port map(clk => clk, res_n => res_n, x => x, y => y_medw);

  takt: process is
  begin
    while not ende loop
      clk <= '1'; wait for T/2;
      clk <= '0'; wait for T/2;
    end loop;
    wait;
  end process takt;

  stimulus: process is
    variable s_moore, s_mealy, s_medw : string(1 to 8);
  begin
    res_n <= '0';
    wait for 0.75 * T;
    res_n <= '1';
    for i in FOLGE'range loop
      wait until clk = '0';          -- Eingang bei fallender Flanke aendern
      x <= FOLGE(i);
      wait for T/4;                  -- Mealy-Ausgang vor der naechsten steigenden Flanke
      s_mealy(i) := std_logic'image(y_mealy)(2);
      wait until clk = '1';
      wait for 1 ns;                 -- Moore/Medwedew-Ausgang nach der Flanke
      s_moore(i) := std_logic'image(y_moore)(2);
      s_medw(i)  := std_logic'image(y_medw)(2);
    end loop;
    report "x        = 10101101";
    report "Mealy    = " & s_mealy & "  (erwartet 00101001)";
    report "Moore    = " & s_moore & "  (erwartet 00101001, aber 1 Takt spaeter)";
    report "Medwedew = " & s_medw  & "  (wie Moore)";
    assert s_mealy = "00101001" report "Mealy falsch" severity error;
    assert s_moore = "00101001" report "Moore falsch" severity error;
    assert s_medw  = "00101001" report "Medwedew falsch" severity error;
    ende <= true;
    wait;
  end process stimulus;
end architecture test;
