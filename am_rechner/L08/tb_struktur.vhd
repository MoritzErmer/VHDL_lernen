-- testet adder_n (N=4), schiebereg (N=4) und priorityencoder (A_WIDTH=3)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_struktur is
end entity tb_struktur;

architecture test of tb_struktur is
  signal a, b, s : std_logic_vector(3 downto 0);
  signal cin, cout : std_logic;
  signal clk, res_n, ser_in : std_logic := '0';
  signal par_out : std_logic_vector(3 downto 0);
  signal e : std_logic_vector(7 downto 0);
  signal v : std_logic;
  signal pa : std_logic_vector(2 downto 0);
begin
  add: entity work.adder_n generic map(N => 4)
    port map(a => a, b => b, cin => cin, s => s, cout => cout);
  sr: entity work.schiebereg generic map(N => 4)
    port map(clk => clk, res_n => res_n, ser_in => ser_in, par_out => par_out);
  pe: entity work.priorityencoder(recursive) generic map(A_WIDTH => 3)
    port map(e => e, v => v, a => pa);

  stimulus: process is
    constant BITS : std_logic_vector(1 to 4) := "1011";
  begin
    -- Addierer: alle Kombinationen
    for i in 0 to 15 loop
      for j in 0 to 15 loop
        a <= std_logic_vector(to_unsigned(i, 4));
        b <= std_logic_vector(to_unsigned(j, 4));
        cin <= '1';
        wait for 10 ns;
        assert to_integer(unsigned(cout & s)) = i + j + 1
          report "adder_n falsch bei " & integer'image(i) & "+" & integer'image(j)
          severity error;
      end loop;
    end loop;
    -- Schieberegister: 4 Bits einschieben
    res_n <= '1';
    for i in BITS'range loop
      ser_in <= BITS(i);
      wait for 2 ns;   -- Eingang NICHT im selben Moment wie die Flanke aendern (Haeppchen I05)
      clk <= '1'; wait for 5 ns; clk <= '0'; wait for 3 ns;
    end loop;
    assert par_out = "1101" report "schiebereg falsch" severity error;
    -- Prioritaetsencoder: Index des niedrigsten gesetzten Bits
    for i in 1 to 255 loop
      e <= std_logic_vector(to_unsigned(i, 8));
      wait for 10 ns;
      for k in 0 to 7 loop
        if e(k) = '1' then
          assert v = '1' and to_integer(unsigned(pa)) = k
            report "priorityencoder falsch bei " & integer'image(i) severity error;
          exit;
        end if;
      end loop;
    end loop;
    e <= (others => '0'); wait for 10 ns;
    assert v = '0' report "priorityencoder: v bei 0" severity error;
    report "Test Struktur (adder_n, schiebereg, priorityencoder) beendet";
    wait;
  end process stimulus;
end architecture test;
