-- Lektion 4, Uebungen 4.1 und 4.2 (Loesungen)

-- Uebung 4.1: Prioritaetsencoder als Prozess
library ieee; use ieee.std_logic_1164.all;

entity prio_encoder_p is
  port(
    req   : in  std_logic_vector(3 downto 0);
    code  : out std_logic_vector(1 downto 0);
    valid : out std_logic
    );
end entity prio_encoder_p;

architecture behav of prio_encoder_p is
begin
  process(req) is
  begin
    -- Default-Zuweisungen: verhindern Latches, weil jeder Pfad einen Wert hat
    code  <= "00";
    valid <= '1';
    if req(3) = '1' then
      code <= "11";
    elsif req(2) = '1' then
      code <= "10";
    elsif req(1) = '1' then
      code <= "01";
    elsif req(0) = '1' then
      code <= "00";
    else
      valid <= '0';
    end if;
  end process;
end architecture behav;

-- Uebung 4.2: Einsen zaehlen (popcount) mit for-Schleife und Variable
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity einsen_zaehlen is
  port(
    x      : in  std_logic_vector(7 downto 0);
    anzahl : out std_logic_vector(3 downto 0)   -- 0..8 braucht 4 Bit
    );
end entity einsen_zaehlen;

architecture behav of einsen_zaehlen is
begin
  process(x) is
    variable zaehler : integer range 0 to 8;
  begin
    zaehler := 0;                          -- WICHTIG: bei jedem Durchlauf neu starten
    for i in x'range loop                  -- x'range = 7 downto 0
      if x(i) = '1' then
        zaehler := zaehler + 1;
      end if;
    end loop;
    anzahl <= std_logic_vector(to_unsigned(zaehler, anzahl'length));
  end process;
end architecture behav;

-- Uebung 4.3 (Bonus): Bitreihenfolge spiegeln mit for-Schleife
library ieee; use ieee.std_logic_1164.all;

entity spiegeln is
  port(
    x : in  std_logic_vector(7 downto 0);
    y : out std_logic_vector(7 downto 0)
    );
end entity spiegeln;

architecture behav of spiegeln is
begin
  process(x) is
  begin
    for i in 0 to 7 loop
      y(i) <= x(7 - i);
    end loop;
  end process;
end architecture behav;
