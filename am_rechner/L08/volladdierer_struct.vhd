-- Haeppchen G01: Volladdierer aus zwei Halbaddierern (braucht am_rechner/L01/halbaddierer.vhd)
library ieee; use ieee.std_logic_1164.all;

entity volladdierer is
  port(
    a, b, cin : in  std_logic;
    s, cout   : out std_logic
    );
end entity volladdierer;

architecture struct of volladdierer is
  signal s1, c1, c2 : std_logic;
begin
  ha1: entity work.halbaddierer
    port map(a => a, b => b, s => s1, c => c1);
  ha2: entity work.halbaddierer
    port map(a => s1, b => cin, s => s, c => c2);
  cout <= c1 or c2;
end architecture struct;
