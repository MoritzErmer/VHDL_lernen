-- Block L: Gatterbibliothek fuer Strukturbeschreibungen (Namen wie im Skript, Kap. 2.3.4)
library ieee; use ieee.std_logic_1164.all;
entity not_1 is port(x : in std_logic; y : out std_logic); end entity not_1;
architecture behav of not_1 is begin y <= not x; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity and_2 is port(x0, x1 : in std_logic; y : out std_logic); end entity and_2;
architecture behav of and_2 is begin y <= x0 and x1; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity and_3 is port(x0, x1, x2 : in std_logic; y : out std_logic); end entity and_3;
architecture behav of and_3 is begin y <= x0 and x1 and x2; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity or_2 is port(x0, x1 : in std_logic; y : out std_logic); end entity or_2;
architecture behav of or_2 is begin y <= x0 or x1; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity or_3 is port(x0, x1, x2 : in std_logic; y : out std_logic); end entity or_3;
architecture behav of or_3 is begin y <= x0 or x1 or x2; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity nor_2 is port(x0, x1 : in std_logic; y : out std_logic); end entity nor_2;
architecture behav of nor_2 is begin y <= x0 nor x1; end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity xor_2 is port(x0, x1 : in std_logic; y : out std_logic); end entity xor_2;
architecture behav of xor_2 is begin y <= x0 xor x1; end architecture behav;
