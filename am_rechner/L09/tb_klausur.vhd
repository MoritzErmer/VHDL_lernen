-- prueft K01-K06: ROM gegen serielles Rechenwerk, Steuerwerk-Ablauf,
-- Multiplizierer (N=3, alle Kombinationen), Volladdierer, Prioritaetsencoder
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_klausur is
end entity tb_klausur;

architecture test of tb_klausur is
  constant T : time := 20 ns;
  signal clk, res_n, s_ser, start : std_logic := '0';
  signal crc_ser, crc_rom : std_logic_vector(4 downto 0);
  signal msg : std_logic_vector(10 downto 0);
  signal clr, valid : std_logic;
  signal a, b : std_logic_vector(2 downto 0);
  signal p : std_logic_vector(5 downto 0);
  signal fa, fb, fc, fs, fco : std_logic;
  signal e : std_logic_vector(7 downto 0);
  signal ev : std_logic;
  signal ea : std_logic_vector(2 downto 0);
begin
  ser: entity work.calc_crc port map(clk => clk, res_n => res_n, s => s_ser, crc => crc_ser);
  rm:  entity work.rom      port map(s => msg, crc => crc_rom);
  st:  entity work.ctrl     port map(clk => clk, res_n => res_n, start => start,
                                     clr => clr, valid => valid);
  mu:  entity work.mult generic map(N => 3) port map(a => a, b => b, p => p);
  fv:  entity work.va port map(a => fa, b => fb, c_in => fc, s => fs, c_out => fco);
  pe:  entity work.priorityencoder_8_bit port map(e => e, v => ev, a => ea);

  stimulus: process is
    procedure takt is
    begin
      wait for T/2; clk <= '1'; wait for T/2; clk <= '0';
    end procedure takt;
    variable f : unsigned(2 downto 0);
    variable seq : string(1 to 6);
  begin
    -- ROM gegen seriell (Bits s(0) .. s(10) nacheinander)
    for m in 0 to 2047 loop
      if m mod 97 = 0 or m = 2047 then
        msg <= std_logic_vector(to_unsigned(m, 11));
        res_n <= '0'; wait for 1 ns; res_n <= '1';
        for j in 0 to 10 loop
          s_ser <= msg(j);
          takt;
        end loop;
        wait for 1 ns;
        assert crc_ser = crc_rom
          report "ROM /= seriell bei " & integer'image(m) severity error;
      end if;
    end loop;
    -- Steuerwerk: S1 -start-> S2 -> S3 -> CLEAR -> S1
    res_n <= '0'; wait for 1 ns; res_n <= '1';
    start <= '0'; wait for 1 ns;
    assert clr = '1' and valid = '0' report "ctrl S1 ohne start" severity error;
    start <= '1'; takt; start <= '0';   -- -> S2
    takt; takt;                          -- -> S3 -> CLEAR
    wait for 1 ns;
    assert clr = '1' and valid = '1' report "ctrl CLEAR" severity error;
    takt; wait for 1 ns;                 -- -> S1
    assert valid = '0' report "ctrl zurueck in S1" severity error;
    -- Multiplizierer N=3
    for i in 0 to 7 loop
      for j in 0 to 7 loop
        a <= std_logic_vector(to_unsigned(i, 3));
        b <= std_logic_vector(to_unsigned(j, 3));
        wait for 10 ns;
        assert to_integer(unsigned(p)) = i * j
          report "mult falsch " & integer'image(i) & "*" & integer'image(j) severity error;
      end loop;
    end loop;
    -- Volladdierer
    for i in 0 to 7 loop
      f := to_unsigned(i, 3);
      fa <= f(2); fb <= f(1); fc <= f(0);
      wait for 10 ns;
      assert to_integer(unsigned'(fco & fs)) = to_integer(f(2 downto 2))
             + to_integer(f(1 downto 1)) + to_integer(f(0 downto 0))
        report "va falsch" severity error;
    end loop;
    -- Prioritaetsencoder 8 Bit
    for i in 1 to 255 loop
      e <= std_logic_vector(to_unsigned(i, 8));
      wait for 10 ns;
      for k in 0 to 7 loop
        if e(k) = '1' then
          assert ev = '1' and to_integer(unsigned(ea)) = k
            report "prio8 falsch bei " & integer'image(i) severity error;
          exit;
        end if;
      end loop;
    end loop;
    report "Test Klausur-Loesungen K01-K06 beendet";
    wait;
  end process stimulus;
end architecture test;
