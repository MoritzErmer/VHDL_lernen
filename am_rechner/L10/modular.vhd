-- L10: Modularisierung - Tastendruck-Zaehler aus drei Modulen
-- taste (asynchron) -> synchronisierer -> flanke -> zaehler4 -> anzahl

library ieee; use ieee.std_logic_1164.all;
entity synchronisierer is
  port(
    clk, res_n : in  std_logic;
    async_in   : in  std_logic;
    sync_out   : out std_logic
    );
end entity synchronisierer;

architecture behav of synchronisierer is
  signal ff1, ff2 : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      ff1 <= '0';
      ff2 <= '0';
    else
      if clk'event and clk = '1' then
        ff1 <= async_in;
        ff2 <= ff1;
      end if;
    end if;
  end process;
  sync_out <= ff2;
end architecture behav;

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity zaehler4 is
  port(
    clk, res_n : in  std_logic;
    en         : in  std_logic;
    q          : out std_logic_vector(3 downto 0)
    );
end entity zaehler4;

architecture behav of zaehler4 is
  signal cnt : unsigned(3 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= (others => '0');
    else
      if clk'event and clk = '1' then
        if en = '1' then
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  q <= std_logic_vector(cnt);
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity tasten_zaehler is
  port(
    clk, res_n : in  std_logic;
    taste      : in  std_logic;
    anzahl     : out std_logic_vector(3 downto 0)
    );
end entity tasten_zaehler;

architecture struct of tasten_zaehler is
  signal taste_sync, puls : std_logic;
begin
  sync: entity work.synchronisierer
    port map(clk => clk, res_n => res_n, async_in => taste, sync_out => taste_sync);
  edge: entity work.flanke_s(behav)
    port map(clk => clk, res_n => res_n, taste => taste_sync, puls => puls);
  cnt:  entity work.zaehler4
    port map(clk => clk, res_n => res_n, en => puls, q => anzahl);
end architecture struct;
