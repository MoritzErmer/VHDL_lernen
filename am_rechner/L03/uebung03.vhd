-- Lektion 3, Uebungen 3.1 und 3.2 (Loesungen)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

-- Uebung 3.1: 2-zu-4-Decoder mit Enable (one-hot-Ausgang)
entity decoder_2_4 is
  port(
    en : in  std_logic;
    a  : in  std_logic_vector(1 downto 0);
    y  : out std_logic_vector(3 downto 0)
    );
end entity decoder_2_4;

architecture behav of decoder_2_4 is
begin
  y <= "0000" when en = '0' else
       "0001" when a = "00" else
       "0010" when a = "01" else
       "0100" when a = "10" else
       "1000";
end architecture behav;

-- Uebung 3.2: 4-Bit-Vergleicher fuer vorzeichenlose Zahlen
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity vergleicher is
  port(
    a, b              : in  std_logic_vector(3 downto 0);
    gleich, groesser, kleiner : out std_logic
    );
end entity vergleicher;

architecture behav of vergleicher is
begin
  gleich   <= '1' when unsigned(a) = unsigned(b) else '0';
  groesser <= '1' when unsigned(a) > unsigned(b) else '0';
  kleiner  <= '1' when unsigned(a) < unsigned(b) else '0';
end architecture behav;
