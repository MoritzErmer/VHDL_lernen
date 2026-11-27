-- Lektion 2, Uebung 2.1 (Loesung)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity uebung02 is
  port(
    x             : in  std_logic_vector(7 downto 0);
    mal4          : out std_logic_vector(9 downto 0);  -- x * 4 (vorzeichenlos)
    halb_signed   : out std_logic_vector(7 downto 0);  -- x / 2 im Zweierkomplement
    nibble_summe  : out std_logic_vector(4 downto 0);  -- oberes + unteres Nibble
    gespiegelt    : out std_logic_vector(7 downto 0)   -- Bitreihenfolge umgedreht
    );
end entity uebung02;

architecture behav of uebung02 is
begin
  -- Schieben um 2 nach links = zwei Nullen anhaengen
  mal4 <= x & "00";

  -- arithmetisches Rechtsschieben: Vorzeichenbit (MSB) wird dupliziert
  halb_signed <= x(7) & x(7 downto 1);

  -- beide Nibbles auf 5 Bit erweitern, dann addieren
  nibble_summe <= std_logic_vector(resize(unsigned(x(7 downto 4)), 5)
                                 + resize(unsigned(x(3 downto 0)), 5));

  -- Spiegeln "von Hand" (in Lektion 4 machst du das mit einer for-Schleife)
  gespiegelt <= x(0) & x(1) & x(2) & x(3) & x(4) & x(5) & x(6) & x(7);
end architecture behav;
