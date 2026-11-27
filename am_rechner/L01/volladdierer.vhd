-- Lektion 1, Uebung 1.2: Volladdierer (Loesung)
library ieee; use ieee.std_logic_1164.all;

entity volladdierer is
  port(
    a, b, cin : in  std_logic;
    s         : out std_logic;
    cout      : out std_logic
    );
end entity volladdierer;

architecture dataflow of volladdierer is
begin
  s    <= a xor b xor cin;
  cout <= (a and b) or (a and cin) or (b and cin);
end architecture dataflow;
