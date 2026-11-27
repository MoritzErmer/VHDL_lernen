library ieee; use ieee.std_logic_1164.all;

entity tb_flanke is
end entity tb_flanke;

architecture test of tb_flanke is
  constant T : time := 20 ns;
  signal clk, res_n, taste, puls : std_logic;
  signal ende : boolean := false;
begin
  dut: entity work.flanke
    port map(clk => clk, res_n => res_n, taste => taste, puls => puls);

  -- Takt (wie clk_res_gen im Skript), stoppt am Testende
  takt: process is
  begin
    while not ende loop
      clk <= '1'; wait for T/2;
      clk <= '0'; wait for T/2;
    end loop;
    wait;
  end process takt;

  stimulus: process is
    variable pulse : natural := 0;
  begin
    res_n <= '0'; taste <= '0';
    wait for 0.75 * T;
    res_n <= '1';
    -- Taste 5 Takte lang druecken (Aenderung bei fallender Flanke)
    wait until clk = '0';
    taste <= '1';
    for i in 1 to 5 loop
      wait for T/4;                 -- einmal pro Takt abtasten
      if puls = '1' then pulse := pulse + 1; end if;
      wait until clk = '0';         -- naechste fallende Flanke
    end loop;
    taste <= '0';
    report "Anzahl Abtastungen mit puls='1': " & integer'image(pulse)
         & " (erwartet: 1)";
    assert pulse = 1 report "Fehler: puls nicht genau 1 Takt lang" severity error;
    ende <= true;
    wait;
  end process stimulus;
end architecture test;
