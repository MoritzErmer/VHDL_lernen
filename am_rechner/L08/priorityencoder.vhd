-- Haeppchen G06: rekursiver Prioritaetsencoder (nach H19 A1 F11). e(0) hat hoechste Prioritaet.
library ieee; use ieee.std_logic_1164.all;

entity priorityencoder is
  generic(
    A_WIDTH : positive
    );
  port(
    e : in  std_logic_vector(2**A_WIDTH - 1 downto 0);
    v : out std_logic;
    a : out std_logic_vector(A_WIDTH - 1 downto 0)
    );
end entity priorityencoder;

architecture recursive of priorityencoder is
  signal v_l, v_h : std_logic;
  signal a_sel    : std_logic;
begin
  v     <= v_l or v_h;
  a_sel <= not v_l when (v_l or v_h) = '1' else '-';

  recursion_end: if A_WIDTH = 1 generate
    v_l  <= e(0);
    v_h  <= e(1);
    a(0) <= a_sel;
  end generate recursion_end;

  recursion: if A_WIDTH > 1 generate
    signal a_l, a_h : std_logic_vector(A_WIDTH - 2 downto 0);
  begin
    a(a'left) <= a_sel;
    a(a'left - 1 downto 0) <= a_l when v_l = '1' else a_h;
    lower: entity work.priorityencoder(recursive)
      generic map(A_WIDTH => A_WIDTH - 1)
      port map(e => e(e'length / 2 - 1 downto 0), v => v_l, a => a_l);
    higher: entity work.priorityencoder(recursive)
      generic map(A_WIDTH => A_WIDTH - 1)
      port map(e => e(e'left downto e'length / 2), v => v_h, a => a_h);
  end generate recursion;
end architecture recursive;
