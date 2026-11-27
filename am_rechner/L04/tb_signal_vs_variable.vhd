-- Lektion 4: Der wichtigste Unterschied in VHDL - Signal vs. Variable
-- Diese Datei ist NUR eine Testbench (keine Ports, kein DUT). Einfach simulieren
-- und die Ausgabe verstehen!
library ieee; use ieee.std_logic_1164.all;

entity tb_signal_vs_variable is
end entity tb_signal_vs_variable;

architecture demo of tb_signal_vs_variable is
  signal s : integer := 0;
begin
  process is
    variable v : integer := 0;
  begin
    wait for 10 ns;

    v := 1;          -- Variable: Wert gilt SOFORT
    s <= 1;          -- Signal: Wert wird nur VORGEMERKT
    report "Nach Zuweisung : v = " & integer'image(v) & ", s = " & integer'image(s);

    v := v + 1;      -- liest neuen Wert 1  -> v = 2
    s <= s + 1;      -- liest ALTEN Wert 0 -> merkt 1 vor (ueberschreibt "s <= 1")
    report "Nach Erhoehung : v = " & integer'image(v) & ", s = " & integer'image(s);

    wait for 0 ns;   -- Prozess haelt an -> ein Delta-Zyklus vergeht -> Signale werden aktualisiert
    report "Nach wait      : v = " & integer'image(v) & ", s = " & integer'image(s);
    wait;
  end process;
end architecture demo;
