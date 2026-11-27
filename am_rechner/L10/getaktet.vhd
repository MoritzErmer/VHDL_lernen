-- Block L: getaktete Schaltplaene (braucht am_rechner/L05/d_ff.vhd)

-- L09: 2-Bit-Zaehler aus Gattern und D-Flipflops
library ieee; use ieee.std_logic_1164.all;
entity zaehler2 is
  port(
    clk, res_n : in  std_logic;
    q0, q1     : out std_logic
    );
end entity zaehler2;

architecture struct of zaehler2 is
  signal d0, d1, q0_int, q1_int : std_logic;
begin
  g0:  entity work.not_1 port map(x => q0_int, y => d0);
  g1:  entity work.xor_2 port map(x0 => q0_int, x1 => q1_int, y => d1);
  ff0: entity work.d_ff  port map(clk => clk, res_n => res_n, d => d0, q => q0_int);
  ff1: entity work.d_ff  port map(clk => clk, res_n => res_n, d => d1, q => q1_int);
  q0 <= q0_int;
  q1 <= q1_int;
end architecture struct;

architecture behav of zaehler2 is
  signal q0_int, q1_int : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      q0_int <= '0';
      q1_int <= '0';
    else
      if clk'event and clk = '1' then
        q0_int <= not q0_int;
        q1_int <= q0_int xor q1_int;
      end if;
    end if;
  end process;
  q0 <= q0_int;
  q1 <= q1_int;
end architecture behav;

-- L12: Flankenerkennung als Strukturbeschreibung (vgl. D07)
library ieee; use ieee.std_logic_1164.all;
entity flanke_s is
  port(
    clk, res_n, taste : in  std_logic;
    puls              : out std_logic
    );
end entity flanke_s;

architecture struct of flanke_s is
  signal taste_d, taste_d_n : std_logic;
begin
  ff: entity work.d_ff  port map(clk => clk, res_n => res_n, d => taste, q => taste_d);
  g1: entity work.not_1 port map(x => taste_d, y => taste_d_n);
  g2: entity work.and_2 port map(x0 => taste, x1 => taste_d_n, y => puls);
end architecture struct;

architecture behav of flanke_s is
  signal taste_d : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      taste_d <= '0';
    else
      if clk'event and clk = '1' then
        taste_d <= taste;
      end if;
    end if;
  end process;
  puls <= taste and not taste_d;
end architecture behav;
