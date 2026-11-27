-- Lektion 2: Arbeiten mit std_logic_vector
library ieee; use ieee.std_logic_1164.all;

entity vektor_spiele is
  port(
    a         : in  std_logic_vector(7 downto 0);
    msb       : out std_logic;                     -- hoechstwertiges Bit
    oberes    : out std_logic_vector(3 downto 0);  -- oberes Nibble
    getauscht : out std_logic_vector(7 downto 0);  -- Nibbles vertauscht
    links     : out std_logic_vector(7 downto 0);  -- um 1 nach links geschoben
    rotiert   : out std_logic_vector(7 downto 0);  -- um 1 nach rechts rotiert
    invers    : out std_logic_vector(7 downto 0);  -- alle Bits invertiert
    nullen    : out std_logic_vector(7 downto 0)   -- konstant 0
    );
end entity vektor_spiele;

architecture behav of vektor_spiele is
begin
  msb       <= a(7);                          -- Indizierung: ein Bit
  oberes    <= a(7 downto 4);                 -- Slice: Teilvektor
  getauscht <= a(3 downto 0) & a(7 downto 4); -- & = Konkatenation
  links     <= a(6 downto 0) & '0';
  rotiert   <= a(0) & a(7 downto 1);
  invers    <= not a;                         -- bitweise
  nullen    <= (others => '0');               -- Aggregat
end architecture behav;
