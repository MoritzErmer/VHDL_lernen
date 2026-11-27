-- Haeppchen F02-F04: Sequenzdetektor "101" (ueberlappend) als Moore, Mealy und Medwedew
library ieee; use ieee.std_logic_1164.all;

entity detektor is
  port(
    clk, res_n : in  std_logic;
    x          : in  std_logic;
    y          : out std_logic
    );
end entity detektor;

architecture moore of detektor is
  type state_type is (start, s1, s10, s101);
  signal current_state, next_state : state_type;
begin
  transition_function: process(x, current_state) is
  begin
    case current_state is
      when start =>
        if x = '1' then next_state <= s1;
        else            next_state <= start;
        end if;
      when s1 =>
        if x = '1' then next_state <= s1;
        else            next_state <= s10;
        end if;
      when s10 =>
        if x = '1' then next_state <= s101;
        else            next_state <= start;
        end if;
      when s101 =>
        if x = '1' then next_state <= s1;
        else            next_state <= s10;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= start;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    case current_state is
      when s101   => y <= '1';
      when others => y <= '0';
    end case;
  end process output_function;
end architecture moore;

architecture mealy of detektor is
  type state_type is (start, s1, s10);
  signal current_state, next_state : state_type;
begin
  transition_function: process(x, current_state) is
  begin
    case current_state is
      when start =>
        if x = '1' then next_state <= s1;
        else            next_state <= start;
        end if;
      when s1 =>
        if x = '1' then next_state <= s1;
        else            next_state <= s10;
        end if;
      when s10 =>
        if x = '1' then next_state <= s1;
        else            next_state <= start;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= start;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(x, current_state) is
  begin
    y <= '0';
    if current_state = s10 and x = '1' then
      y <= '1';
    end if;
  end process output_function;
end architecture mealy;

architecture medwedew of detektor is
  type state_type is (start, s1, s10, s101);
  signal current_state, next_state : state_type;
  signal next_y : std_logic;
begin
  transition_function: process(x, current_state) is
  begin
    next_y <= '0';
    case current_state is
      when start =>
        if x = '1' then next_state <= s1;
        else            next_state <= start;
        end if;
      when s1 | s101 =>
        if x = '1' then next_state <= s1;
        else            next_state <= s10;
        end if;
      when s10 =>
        if x = '1' then
          next_state <= s101;
          next_y     <= '1';
        else
          next_state <= start;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= start;
      y <= '0';
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        y <= next_y;
      end if;
    end if;
  end process state;
end architecture medwedew;
