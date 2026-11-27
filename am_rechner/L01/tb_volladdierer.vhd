-- Testbench fuer den Volladdierer: testet alle 8 Eingangskombinationen
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_volladdierer is
end entity tb_volladdierer;

architecture test of tb_volladdierer is
  signal a, b, cin, s, cout : std_logic;
begin
  dut: entity work.volladdierer
    port map(a => a, b => b, cin => cin, s => s, cout => cout);

  stimulus: process is
    variable eingang : unsigned(2 downto 0);
    variable soll    : integer;
  begin
    for i in 0 to 7 loop
      eingang := to_unsigned(i, 3);
      a   <= eingang(2);
      b   <= eingang(1);
      cin <= eingang(0);
      wait for 10 ns;
      -- Sollwert: Anzahl der Einsen = a + b + cin
      soll := to_integer(eingang(2 downto 2)) + to_integer(eingang(1 downto 1))
              + to_integer(eingang(0 downto 0));
      assert unsigned'(cout & s) = to_unsigned(soll, 2)
        report "Fehler bei Eingang " & integer'image(i) severity error;
    end loop;
    report "Test Volladdierer beendet";
    wait;
  end process stimulus;
end architecture test;
