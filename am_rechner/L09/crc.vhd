-- Haeppchen A03, K01, K02, K06: CRC-Beispiel aus Klausur F24 (nachgebaut)
library ieee; use ieee.std_logic_1164.all;

entity single_step is
  port(
    q : in  std_logic_vector(4 downto 0);
    s : in  std_logic;
    d : out std_logic_vector(4 downto 0)
    );
end entity single_step;

architecture behav of single_step is
begin
  d(4 downto 3) <= q(3 downto 2);
  d(2)          <= q(4) xor s xor q(1);
  d(1)          <= q(0);
  d(0)          <= q(4) xor s;
end architecture behav;

-- K01: serielles Rechenwerk (Medwedew)
library ieee; use ieee.std_logic_1164.all;

entity calc_crc is
  port(
    clk, res_n : in  std_logic;
    s          : in  std_logic;
    crc        : out std_logic_vector(4 downto 0)
    );
end entity calc_crc;

use work.all;
architecture mixed of calc_crc is
  signal q, d : std_logic_vector(4 downto 0);
begin
  isingle_step: entity single_step
    port map(q => q, s => s, d => d);

  reg: process(clk, res_n) is
  begin
    if res_n = '0' then
      q <= (others => '0');
    else
      if clk'event and clk = '1' then
        q <= d;
      end if;
    end if;
  end process reg;

  crc <= q;
end architecture mixed;

-- K02: Steuerwerk
library ieee; use ieee.std_logic_1164.all;

entity ctrl is
  port(
    clk, res_n, start : in  std_logic;
    clr, valid        : out std_logic
    );
end entity ctrl;

architecture behav of ctrl is
  type state_type is (S1, S2, S3, CLEAR);
  signal current_state, next_state : state_type;
begin
  state_p: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= S1;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state_p;

  transition_p: process(current_state, start) is
  begin
    next_state <= current_state;
    case current_state is
      when S1 =>
        if start = '1' then
          next_state <= S2;
        end if;
      when S2 =>
        next_state <= S3;
      when S3 =>
        next_state <= CLEAR;
      when CLEAR =>
        next_state <= S1;
    end case;
  end process transition_p;

  output_p: process(current_state, start) is
  begin
    clr   <= '0';
    valid <= '0';
    case current_state is
      when S1 =>
        if start /= '1' then
          clr <= '1';
        end if;
      when S2 | S3 =>
        null;
      when CLEAR =>
        valid <= '1';
        clr   <= '1';
    end case;
  end process output_p;
end architecture behav;

-- K06: CRC als ROM
library ieee; use ieee.std_logic_1164.all;

entity rom is
  port(
    s   : in  std_logic_vector(10 downto 0);
    crc : out std_logic_vector(4 downto 0)
    );
end entity rom;

library ieee; use ieee.numeric_std.all;
architecture behav of rom is
  type rom_type is array (0 to 2047)
    of std_logic_vector(4 downto 0);

  pure function init_rom return rom_type is
    variable s      : std_logic_vector(10 downto 0);
    variable d, q   : std_logic_vector(4 downto 0);
    variable result : rom_type;
  begin
    for i in rom_type'range loop
      q := (others => '0');
      s := std_logic_vector(to_unsigned(i, 11));
      for j in 0 to 10 loop
        d(4 downto 3) := q(3 downto 2);
        d(2) := q(4) xor s(j) xor q(1);
        d(1) := q(0);
        d(0) := q(4) xor s(j);
        q := d;
      end loop;
      result(i) := d;
    end loop;
    return result;
  end function init_rom;

  signal r : rom_type := init_rom;
begin
  crc <= r(to_integer(unsigned(s)));
end architecture behav;
