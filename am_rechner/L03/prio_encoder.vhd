-- Lektion 3: Prioritaetsencoder 4 -> 2
-- req(3) hat die hoechste Prioritaet. valid = '1', wenn irgendein req aktiv ist.
library ieee; use ieee.std_logic_1164.all;

entity prio_encoder is
  port(
    req   : in  std_logic_vector(3 downto 0);
    code  : out std_logic_vector(1 downto 0);
    valid : out std_logic
    );
end entity prio_encoder;

architecture dataflow of prio_encoder is
begin
  -- when-else hat eine REIHENFOLGE -> perfekt fuer Prioritaeten
  code <= "11" when req(3) = '1' else
          "10" when req(2) = '1' else
          "01" when req(1) = '1' else
          "00";

  valid <= '0' when req = "0000" else '1';
end architecture dataflow;
