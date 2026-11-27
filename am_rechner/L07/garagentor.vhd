-- Haeppchen F08: Garagentor-Steuerung (Moore)
library ieee; use ieee.std_logic_1164.all;

entity garagentor is
  port(
    clk, res_n          : in  std_logic;
    taster              : in  std_logic;  -- 1-Takt-Puls
    oben, unten         : in  std_logic;  -- Endschalter
    hindernis           : in  std_logic;  -- Lichtschranke
    motor_auf, motor_zu : out std_logic
    );
end entity garagentor;

architecture moore of garagentor is
  type state_type is (zu, oeffnet, offen, schliesst);
  signal current_state, next_state : state_type;
begin
  transition_function: process(current_state,
      taster, oben, unten, hindernis) is
  begin
    next_state <= current_state;
    case current_state is
      when zu =>
        if taster = '1' then
          next_state <= oeffnet;
        end if;
      when oeffnet =>
        if oben = '1' then
          next_state <= offen;
        end if;
      when offen =>
        if taster = '1' then
          next_state <= schliesst;
        end if;
      when schliesst =>
        if hindernis = '1' then
          next_state <= oeffnet;
        elsif unten = '1' then
          next_state <= zu;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= zu;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    motor_auf <= '0';
    motor_zu  <= '0';
    case current_state is
      when oeffnet   => motor_auf <= '1';
      when schliesst => motor_zu  <= '1';
      when others    => null;
    end case;
  end process output_function;
end architecture moore;
