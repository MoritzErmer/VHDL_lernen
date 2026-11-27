library ieee; use ieee.std_logic_1164.all;

entity tb_garagentor is
end entity tb_garagentor;

architecture test of tb_garagentor is
  constant T : time := 20 ns;
  signal clk, res_n : std_logic := '0';
  signal taster, oben, unten, hindernis : std_logic := '0';
  signal motor_auf, motor_zu : std_logic;
  signal ende : boolean := false;
begin
  dut: entity work.garagentor
    port map(clk => clk, res_n => res_n, taster => taster, oben => oben,
             unten => unten, hindernis => hindernis,
             motor_auf => motor_auf, motor_zu => motor_zu);

  takt: process is
  begin
    while not ende loop
      clk <= '1'; wait for T/2;
      clk <= '0'; wait for T/2;
    end loop;
    wait;
  end process takt;

  stimulus: process is
    procedure takte(n : positive) is   -- n Takte abwarten (bis zur fallenden Flanke)
    begin
      for i in 1 to n loop
        wait until clk = '0';
      end loop;
    end procedure takte;
  begin
    res_n <= '0'; unten <= '1';
    wait for 0.75 * T; res_n <= '1';
    takte(1);
    assert motor_auf = '0' and motor_zu = '0' report "zu: Motor laeuft" severity error;
    taster <= '1'; takte(1); taster <= '0'; unten <= '0';
    assert motor_auf = '1' report "oeffnet: Motor nicht auf" severity error;
    takte(3); oben <= '1'; takte(1);
    assert motor_auf = '0' report "offen: Motor laeuft noch" severity error;
    taster <= '1'; takte(1); taster <= '0'; oben <= '0';
    assert motor_zu = '1' report "schliesst: Motor nicht zu" severity error;
    hindernis <= '1'; takte(1); hindernis <= '0';
    assert motor_auf = '1' report "Hindernis: Tor oeffnet nicht" severity error;
    report "Test garagentor beendet";
    ende <= true;
    wait;
  end process stimulus;
end architecture test;
