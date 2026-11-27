-- Lektion 3: 4:1-Multiplexer, zwei Architectures fuer dieselbe Entity
library ieee; use ieee.std_logic_1164.all;

entity mux4 is
  port(
    d0, d1, d2, d3 : in  std_logic_vector(7 downto 0);
    sel            : in  std_logic_vector(1 downto 0);
    y              : out std_logic_vector(7 downto 0)
    );
end entity mux4;

-- Variante 1: bedingte Signalzuweisung (when ... else)
architecture when_else of mux4 is
begin
  y <= d0 when sel = "00" else
       d1 when sel = "01" else
       d2 when sel = "10" else
       d3;
end architecture when_else;

-- Variante 2: selektive Signalzuweisung (with ... select)
architecture with_select of mux4 is
begin
  with sel select
    y <= d0 when "00",
         d1 when "01",
         d2 when "10",
         d3 when others;
end architecture with_select;
