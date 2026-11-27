-- Lektion 2: Rechnen mit numeric_std (unsigned / signed)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity rechner_8bit is
  port(
    a, b      : in  std_logic_vector(7 downto 0);
    summe     : out std_logic_vector(8 downto 0);   -- 9 Bit: inkl. Uebertrag
    differenz : out std_logic_vector(7 downto 0);   -- a - b (modulo 256)
    a_als_u   : out integer range 0 to 255;         -- a vorzeichenlos gelesen
    a_als_s   : out integer range -128 to 127       -- a im Zweierkomplement gelesen
    );
end entity rechner_8bit;

architecture behav of rechner_8bit is
  signal ua, ub : unsigned(7 downto 0);   -- interne Signale
begin
  ua <= unsigned(a);                      -- Typumwandlung (gleiche Bits!)
  ub <= unsigned(b);

  summe     <= std_logic_vector(resize(ua, 9) + resize(ub, 9));
  differenz <= std_logic_vector(ua - ub);
  a_als_u   <= to_integer(ua);
  a_als_s   <= to_integer(signed(a));
end architecture behav;
