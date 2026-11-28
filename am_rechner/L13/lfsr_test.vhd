-- Testbench nach dem Muster "tester - DUT - analyzer": sucht Rueckkopplungsmuster mit maximaler Zykluslaenge

library ieee; use ieee.std_logic_1164.all;
entity clk_res_gen is
  port(clk, res_n : out std_logic);
end entity clk_res_gen;

architecture behav of clk_res_gen is
  signal c : std_logic := '0';
begin
  c <= not c after 10 ns;
  clk <= c;
  res_n <= '0', '1' after 25 ns;
end architecture behav;

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity tester is
  port(
    clk, res_n : in  std_logic;
    reset      : out std_logic;
    fb         : out std_logic_vector(7 downto 1)
    );
end entity tester;

architecture behav of tester is
begin
  process is
  begin
    reset <= '0';
    fb <= (others => '0');
    wait until res_n = '1';
    for i in 0 to 127 loop
      fb <= std_logic_vector(to_unsigned(i, 7));
      reset <= '1';
      wait on clk until clk = '1';
      reset <= '0';
      for j in 1 to 256 loop           -- laenger als der laengste moegliche Zyklus (255)
        wait on clk until clk = '1';
      end loop;
    end loop;
    report "tester: alle Muster durch";
    wait;
  end process;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity analyzer is
  port(
    clk, res_n : in std_logic;
    reset      : in std_logic;
    fb         : in std_logic_vector(7 downto 1);
    q          : in std_logic_vector(7 downto 0)
    );
end entity analyzer;

library ieee; use ieee.numeric_std.all;
architecture behav of analyzer is
begin
  process is
    variable cycle_length_counter : integer;
    variable start_value : std_logic_vector(7 downto 0);
    variable gefunden : natural := 0;
  begin
    wait until res_n = '1';
    loop
      wait on clk until clk = '1' and reset = '1';
      cycle_length_counter := 1;
      wait on clk until clk = '1' and reset = '0';
      start_value := q;
      wait on clk until clk = '1';
      while q /= start_value loop
        cycle_length_counter := cycle_length_counter + 1;
        wait on clk until clk = '1';
        exit when cycle_length_counter > 300;
      end loop;
      if cycle_length_counter = 255 then
        gefunden := gefunden + 1;
        report "maximal: fb = " & integer'image(to_integer(unsigned(fb))) &
               " (Nr. " & integer'image(gefunden) & ")";
      end if;
    end loop;
  end process;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity galois_lfsr_tb is
end entity galois_lfsr_tb;

architecture struct of galois_lfsr_tb is
  signal clk, res_n, reset : std_logic;
  signal fb : std_logic_vector(7 downto 1);
  signal q : std_logic_vector(7 downto 0);
begin
  gen: entity work.clk_res_gen port map(clk => clk, res_n => res_n);
  tst: entity work.tester port map(clk => clk, res_n => res_n, reset => reset, fb => fb);
  dut: entity work.galois_lfsr(behav) port map(clk => clk, res_n => res_n, reset => reset, fb => fb, q => q);
  ana: entity work.analyzer port map(clk => clk, res_n => res_n, reset => reset, fb => fb, q => q);
end architecture struct;
