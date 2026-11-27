-- Haeppchen G05: generischer Ripple-Carry-Addierer mit for-generate
library ieee; use ieee.std_logic_1164.all;

entity adder_n is
  generic(
    N : positive
    );
  port(
    a, b : in  std_logic_vector(N-1 downto 0);
    cin  : in  std_logic;
    s    : out std_logic_vector(N-1 downto 0);
    cout : out std_logic
    );
end entity adder_n;

architecture struct of adder_n is
  signal c : std_logic_vector(N downto 0);
begin
  c(0) <= cin;

  stufen: for i in 0 to N-1 generate
    va: entity work.volladdierer
      port map(a => a(i), b => b(i), cin => c(i),
               s => s(i), cout => c(i+1));
  end generate stufen;

  cout <= c(N);
end architecture struct;
