-- Haeppchen D01: D-Flipflop mit asynchronem, low-aktivem Reset (Stil wie im Skript)
library ieee; use ieee.std_logic_1164.all;

entity d_ff is
  port(
    clk, res_n : in  std_logic;
    d          : in  std_logic;
    q          : out std_logic
    );
end entity d_ff;

architecture behav of d_ff is
begin
  process(clk, res_n) is          -- NUR clk und res_n in der Sensitivitaetsliste
  begin
    if res_n = '0' then           -- asynchroner Reset: wirkt sofort, ohne Takt
      q <= '0';
    else
      if clk'event and clk = '1' then   -- steigende Taktflanke (= rising_edge(clk))
        q <= d;
      end if;
    end if;
  end process;
end architecture behav;
