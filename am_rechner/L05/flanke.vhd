-- Haeppchen D07: Flankenerkennung (1 FF + Kombinatorik = Mealy)
library ieee; use ieee.std_logic_1164.all;

entity flanke is
  port(
    clk, res_n : in  std_logic;
    taste      : in  std_logic;
    puls       : out std_logic   -- 1 Takt lang '1' bei steigender Flanke von taste
    );
end entity flanke;

architecture behav of flanke is
  signal taste_d : std_logic;
begin
  reg: process(clk, res_n) is
  begin
    if res_n = '0' then
      taste_d <= '0';
    else
      if clk'event and clk = '1' then
        taste_d <= taste;
      end if;
    end if;
  end process reg;

  puls <= taste and not taste_d;
end architecture behav;
