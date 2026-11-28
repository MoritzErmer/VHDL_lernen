-- Block P, Projekte 1 und 2: Getraenkeautomat und Codeschloss (eigene Aufgaben)

-- P02: Getraenkeautomat, Moore, Preis 3 Euro, Muenzen 1 und 2 Euro
library ieee; use ieee.std_logic_1164.all;
entity getraenk is
  port(
    clk, res_n         : in  std_logic;
    m1, m2             : in  std_logic;   -- je ein Takt '1' pro eingeworfener Muenze
    ausgabe, rueckgeld : out std_logic
    );
end entity getraenk;

architecture behav of getraenk is
  type state_type is (g0, g1, g2, aus, aus_r);
  signal current_state, next_state : state_type;
begin
  transition_function: process(current_state, m1, m2) is
  begin
    next_state <= current_state;
    case current_state is
      when g0 =>
        if m1 = '1' then next_state <= g1;
        elsif m2 = '1' then next_state <= g2;
        end if;
      when g1 =>
        if m1 = '1' then next_state <= g2;
        elsif m2 = '1' then next_state <= aus;
        end if;
      when g2 =>
        if m1 = '1' then next_state <= aus;
        elsif m2 = '1' then next_state <= aus_r;
        end if;
      when aus | aus_r =>
        next_state <= g0;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= g0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    ausgabe   <= '0';
    rueckgeld <= '0';
    case current_state is
      when aus    => ausgabe <= '1';
      when aus_r  => ausgabe <= '1'; rueckgeld <= '1';
      when others => null;
    end case;
  end process output_function;
end architecture behav;

-- P05: Codeschloss: Code C1 C2 C3, nach drei Fehlern gesperrt
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity codeschloss is
  generic(
    C1 : natural range 0 to 9 := 3;
    C2 : natural range 0 to 9 := 5;
    C3 : natural range 0 to 9 := 1;
    T_OFFEN  : positive := 4;
    T_SPERRE : positive := 8
    );
  port(
    clk, res_n       : in  std_logic;
    taste            : in  std_logic;                     -- ein Takt '1' pro Ziffer
    ziffer           : in  std_logic_vector(3 downto 0);
    offen, gesperrt  : out std_logic
    );
end entity codeschloss;

architecture behav of codeschloss is
  type state_type is (z0, z1, z2, s_offen, s_gesperrt);
  signal current_state, next_state : state_type;
  signal fehler : integer range 0 to 2;       -- bisherige Fehlversuche
  signal zeit   : integer range 0 to 255;
  signal richtig, falsch : std_logic;
begin
  -- welche Ziffer wird im aktuellen Zustand erwartet, und war die Eingabe richtig?
  pruefen: process(current_state, taste, ziffer) is
    variable erwartet : natural range 0 to 9;
  begin
    case current_state is
      when z0     => erwartet := C1;
      when z1     => erwartet := C2;
      when others => erwartet := C3;
    end case;
    richtig <= '0';
    falsch  <= '0';
    if taste = '1' and (current_state = z0 or current_state = z1 or current_state = z2) then
      if to_integer(unsigned(ziffer)) = erwartet then
        richtig <= '1';
      else
        falsch <= '1';
      end if;
    end if;
  end process pruefen;

  transition_function: process(current_state, richtig, falsch, fehler, zeit) is
  begin
    next_state <= current_state;
    case current_state is
      when z0 | z1 | z2 =>
        if falsch = '1' then
          if fehler = 2 then
            next_state <= s_gesperrt;
          else
            next_state <= z0;
          end if;
        elsif richtig = '1' then
          case current_state is
            when z0     => next_state <= z1;
            when z1     => next_state <= z2;
            when others => next_state <= s_offen;
          end case;
        end if;
      when s_offen =>
        if zeit = T_OFFEN - 1 then next_state <= z0; end if;
      when s_gesperrt =>
        if zeit = T_SPERRE - 1 then next_state <= z0; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= z0;
      fehler <= 0;
      zeit   <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        -- Zeitzaehler: zaehlt nur in s_offen und s_gesperrt, in jedem neuen Zustand von vorn
        if next_state /= current_state then
          zeit <= 0;
        elsif current_state = s_offen or current_state = s_gesperrt then
          zeit <= zeit + 1;
        end if;
        -- Fehlerzaehler
        if next_state = s_offen or next_state = s_gesperrt then
          fehler <= 0;
        elsif falsch = '1' then
          fehler <= fehler + 1;
        end if;
      end if;
    end if;
  end process state;

  offen    <= '1' when current_state = s_offen else '0';
  gesperrt <= '1' when current_state = s_gesperrt else '0';
end architecture behav;
