-- Haeppchen G05 (Aufgabe): Schieberegister aus N d_ff (braucht am_rechner/L05/d_ff.vhd)
library ieee; use ieee.std_logic_1164.all;

entity schiebereg is
  generic(
    N : positive
    );
  port(
    clk, res_n : in  std_logic;
    ser_in     : in  std_logic;
    par_out    : out std_logic_vector(N-1 downto 0)
    );
end entity schiebereg;

architecture struct of schiebereg is
  signal z : std_logic_vector(N downto 0);
begin
  z(N) <= ser_in;
  stufen: for i in N-1 downto 0 generate
    ff: entity work.d_ff
      port map(clk => clk, res_n => res_n, d => z(i+1), q => z(i));
  end generate stufen;
  par_out <= z(N-1 downto 0);
end architecture struct;
