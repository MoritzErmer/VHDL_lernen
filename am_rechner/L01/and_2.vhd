-- Lektion 1: UND-Gatter mit 2 Eingängen (wie im Skript, Kap. 2.3.4)
library ieee; use ieee.std_logic_1164.all;

entity and_2 is
  port(
    x0, x1 : in  std_logic;
    y      : out std_logic
    );
end entity and_2;

architecture behav of and_2 is
begin
  y <= x0 and x1;
end architecture behav;
