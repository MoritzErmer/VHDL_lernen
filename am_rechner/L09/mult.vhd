-- Haeppchen K03, K04, K05 (Klausuren H19 und F20)
library ieee; use ieee.std_logic_1164.all;

entity mult is
  generic(
    N : positive
    );
  port(
    a, b : in  std_logic_vector(N-1 downto 0);
    p    : out std_logic_vector(2*N-1 downto 0)
    );
end entity mult;

library ieee; use ieee.numeric_std.all;
architecture behav of mult is
begin
  process(a, b) is
    variable ac : unsigned(2*N-1 downto 0);
    constant z_extend :
      unsigned(2*N-1 downto N) := (others => '0');
  begin
    ac := (others => '0');
    for i in N-1 downto 0 loop
      ac := ac(ac'left-1 downto 0) & '0';
      if b(i) = '1' then
        ac := ac + (z_extend & unsigned(a));
      end if;
    end loop;
    p <= std_logic_vector(ac);
  end process;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;

entity va is
  port(
    a, b, c_in : in  std_logic;
    s, c_out   : out std_logic
    );
end entity va;

library ieee; use ieee.numeric_std.all;
architecture behav of va is
begin
  (c_out, s) <= unsigned'('0' & a) +
                unsigned'('0' & b) +
                unsigned'('0' & c_in);
end architecture behav;

library ieee; use ieee.std_logic_1164.all;

entity priorityencoder_8_bit is
  port(
    e : in  std_logic_vector(7 downto 0);
    v : out std_logic;
    a : out std_logic_vector(2 downto 0)
    );
end entity priorityencoder_8_bit;

library ieee; use ieee.numeric_std.all;
architecture behav_loop of priorityencoder_8_bit is
begin
  encoder: process(e) is
  begin
    v <= '0';
    a <= "---";
    for i in 7 downto 0 loop
      if e(i) = '1' then
        v <= '1';
        a <= std_logic_vector(to_unsigned(i, 3));
      end if;
    end loop;
  end process encoder;
end architecture behav_loop;
