-- Lektion 1: Halbaddierer
library ieee; use ieee.std_logic_1164.all;

entity halbaddierer is
  port(
    a, b : in  std_logic;
    s    : out std_logic;   -- Summe
    c    : out std_logic    -- Uebertrag (carry)
    );
end entity halbaddierer;

architecture dataflow of halbaddierer is
begin
  s <= a xor b;
  c <= a and b;
end architecture dataflow;
