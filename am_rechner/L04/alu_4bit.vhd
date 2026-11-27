-- Lektion 4: kombinatorischer Prozess - eine kleine ALU
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity alu_4bit is
  port(
    a, b : in  std_logic_vector(3 downto 0);
    op   : in  std_logic_vector(1 downto 0);  -- 00: a+b  01: a-b  10: a and b  11: a or b
    y    : out std_logic_vector(3 downto 0);
    zero : out std_logic                       -- '1', wenn y = 0
    );
end entity alu_4bit;

architecture behav of alu_4bit is
begin
  alu: process(a, b, op) is                    -- ALLE gelesenen Signale!
    variable ergebnis : std_logic_vector(3 downto 0);
  begin
    case op is
      when "00"   => ergebnis := std_logic_vector(unsigned(a) + unsigned(b));
      when "01"   => ergebnis := std_logic_vector(unsigned(a) - unsigned(b));
      when "10"   => ergebnis := a and b;
      when others => ergebnis := a or b;
    end case;

    y <= ergebnis;

    -- Variable hier noetig: wir wollen das Ergebnis im selben Durchlauf weiterverwenden.
    -- Mit "if y = ..." wuerden wir den ALTEN Wert von y lesen (und y ist out -> nicht lesbar)!
    if ergebnis = "0000" then
      zero <= '1';
    else
      zero <= '0';
    end if;
  end process alu;
end architecture behav;
