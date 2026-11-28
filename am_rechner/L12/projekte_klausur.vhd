-- Block P, Projekte 3 bis 7: nach Klausuraufgaben (sinngemaess, eigene Umsetzung)

-- ===== Projekt 3: Tastatur-Controller (nach F20 A2) =====
library ieee; use ieee.std_logic_1164.all;
entity decoder is
  generic(N : positive);
  port(
    s : in  std_logic_vector(N-1 downto 0);
    o : out std_logic_vector(2**N - 1 downto 0)
    );
end entity decoder;

library ieee; use ieee.numeric_std.all;
architecture behav of decoder is
begin
  process(s) is
  begin
    o <= (others => '0');
    o(to_integer(unsigned(s))) <= '1';
  end process;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity mux is
  generic(N : positive);
  port(
    x : in  std_logic_vector(2**N - 1 downto 0);
    s : in  std_logic_vector(N-1 downto 0);
    y : out std_logic
    );
end entity mux;

library ieee; use ieee.numeric_std.all;
architecture behav of mux is
begin
  y <= x(to_integer(unsigned(s)));
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity binary_counter is
  generic(N : positive);
  port(
    clk, res_n : in  std_logic;
    inc        : in  std_logic := '1';
    q          : out std_logic_vector(N-1 downto 0);
    max        : out std_logic
    );
end entity binary_counter;

library ieee; use ieee.numeric_std.all;
architecture behav of binary_counter is
  signal cnt : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= (others => '0');
    else
      if clk'event and clk = '1' then
        if inc = '1' then
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  q   <= std_logic_vector(cnt);
  max <= '1' when cnt = 2**N - 1 else '0';
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity keyboard_state is
  port(
    clk, res_n    : in  std_logic;
    column_number : in  std_logic_vector(2 downto 0);
    line_number   : in  std_logic_vector(1 downto 0);
    key_in        : in  std_logic;
    key_changed   : out std_logic;
    key_state     : out std_logic
    );
end entity keyboard_state;

library ieee; use ieee.numeric_std.all;
architecture behav of keyboard_state is
  subtype c_type is integer range 0 to 7;
  subtype l_type is integer range 0 to 3;
  type matrix_type is array (c_type, l_type) of std_logic;
  signal matrix : matrix_type;
  signal c : c_type;
  signal l : l_type;
begin
  c <= to_integer(unsigned(column_number));
  l <= to_integer(unsigned(line_number));
  process(clk, res_n) is
  begin
    if res_n = '0' then
      matrix <= (others => (others => '0'));
    else
      if clk'event and clk = '1' then
        matrix(c, l) <= key_in;
      end if;
    end if;
  end process;
  key_changed <= key_in xor matrix(c, l);
  key_state   <= key_in;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity keyboard_controller is
  port(
    clk, res_n  : in  std_logic;
    lines       : in  std_logic_vector(3 downto 0);
    columns     : out std_logic_vector(7 downto 0);
    c_num       : out std_logic_vector(2 downto 0);
    l_num       : out std_logic_vector(1 downto 0);
    key_changed : out std_logic;
    key_state   : out std_logic
    );
end entity keyboard_controller;

architecture struct of keyboard_controller is
  signal last_line, selected_line : std_logic;
  signal c, cn : std_logic_vector(2 downto 0);
  signal l : std_logic_vector(1 downto 0);
begin
  line_counter: entity work.binary_counter generic map(N => 2)
    port map(clk => clk, res_n => res_n, q => l, max => last_line);
  column_counter: entity work.binary_counter generic map(N => 3)
    port map(clk => clk, res_n => res_n, inc => last_line, q => c, max => open);
  column_decoder: entity work.decoder generic map(N => 3)
    port map(s => c, o => columns);
  line_mux: entity work.mux generic map(N => 2)
    port map(x => lines, s => l, y => selected_line);
  state: entity work.keyboard_state
    port map(clk => clk, res_n => res_n, column_number => c, line_number => l,
             key_in => selected_line, key_changed => key_changed, key_state => key_state);
  c_num <= c;
  l_num <= l;
end architecture struct;

-- ===== Projekt 4: serieller Empfaenger (nach F19 A1) =====
-- Rahmen wie in der Klausur: Ruhe '0', Startbit '1', 8 Datenbits LSB zuerst, Stoppbit '0'
library ieee; use ieee.std_logic_1164.all;
entity receiver is
  generic(BIT_TAKTE : positive := 8);          -- Takte pro Bit (gerade Zahl)
  port(
    clk, res_n  : in  std_logic;
    ser_in      : in  std_logic;
    par_out     : out std_logic_vector(7 downto 0);
    par_out_ena : out std_logic
    );
end entity receiver;

architecture behav of receiver is
  type state_type is (ruhe, empfang);
  signal state : state_type;
  signal ser_in_d, ser_in_dd : std_logic;        -- Synchronisierer
  signal teiler : integer range 0 to BIT_TAKTE - 1;
  signal bitnr  : integer range 0 to 9;
  signal data   : std_logic_vector(9 downto 0);   -- Stopp & Daten & Start
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      state <= ruhe;
      ser_in_d <= '0';
      ser_in_dd <= '0';
      teiler <= 0;
      bitnr <= 0;
      data <= (others => '0');
      par_out_ena <= '0';
    else
      if clk'event and clk = '1' then
        ser_in_d  <= ser_in;
        ser_in_dd <= ser_in_d;
        par_out_ena <= '0';
        case state is
          when ruhe =>
            if ser_in_dd = '1' then            -- Beginn des Startbits
              state  <= empfang;
              teiler <= BIT_TAKTE / 2;         -- erste Abtastung in der Bitmitte
              bitnr  <= 0;
            end if;
          when empfang =>
            if teiler = BIT_TAKTE - 1 then
              teiler <= 0;
              data <= ser_in_dd & data(9 downto 1);
              if bitnr = 9 then
                state <= ruhe;
                par_out_ena <= '1';
              else
                bitnr <= bitnr + 1;
              end if;
            else
              teiler <= teiler + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
  par_out <= data(8 downto 1);
end architecture behav;

-- ===== Projekt 5: N-schrittiges Dividierwerk mit divstep (nach F22 A1) =====
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity div_seq is
  generic(N : positive := 4;     -- Breite Dividend a (mindestens 2)
          M : positive := 4);    -- Breite Divisor b
  port(
    clk, res_n : in  std_logic;
    init       : in  std_logic;
    a          : in  std_logic_vector(N-1 downto 0);
    b          : in  std_logic_vector(M-1 downto 0);
    q          : out std_logic_vector(N-1 downto 0);
    r          : out std_logic_vector(M-1 downto 0);
    valid      : out std_logic
    );
end entity div_seq;

architecture behav of div_seq is
  -- ein Schritt der Schulmethode: f = Rest (M Bit) & Dividend/Quotient (N Bit)
  procedure divstep(f : inout unsigned(M+N-1 downto 0);
                    d_b : in  unsigned(M-1 downto 0)) is
    variable d : unsigned(M downto 0);
  begin
    d := f(M+N-1 downto N-1) - ('0' & d_b);
    if d(M) = '0' then                     -- kein Unterlauf: d_b passt hinein
      f := d(M-1 downto 0) & f(N-2 downto 0) & '1';
    else
      f := f(M+N-2 downto 0) & '0';
    end if;
  end procedure divstep;

  signal f_reg : unsigned(M+N-1 downto 0);
  signal b_reg : unsigned(M-1 downto 0);
  signal sr    : std_logic_vector(0 to N-1);   -- Schieberegister fuer valid
begin
  process(clk, res_n) is
    variable f : unsigned(M+N-1 downto 0);
  begin
    if res_n = '0' then
      f_reg <= (others => '0');
      b_reg <= (others => '0');
      sr    <= (others => '0');
      valid <= '0';
    else
      if clk'event and clk = '1' then
        if init = '1' then
          f_reg <= unsigned(std_logic_vector'((M-1 downto 0 => '0') & a));
          b_reg <= unsigned(b);
        else
          f := f_reg;
          divstep(f, b_reg);
          f_reg <= f;
        end if;
        sr    <= init & sr(0 to N-2);
        valid <= sr(N-1);                    -- genau N Takte nach init
      end if;
    end if;
  end process;
  q <= std_logic_vector(f_reg(N-1 downto 0));
  r <= std_logic_vector(f_reg(M+N-1 downto N));
end architecture behav;

-- ===== Projekt 6: Oszillator und Perioden-ROM (nach F23 A2) =====
library ieee; use ieee.std_logic_1164.all;
entity osc is
  generic(N : positive);
  port(
    clk, res_n : in  std_logic;
    period     : in  std_logic_vector(N-1 downto 0);   -- Periodendauer in Takten
    wave       : out std_logic
    );
end entity osc;

library ieee; use ieee.numeric_std.all;
architecture behav of osc is
  signal period_reg : unsigned(N-1 downto 0);   -- gilt fuer eine ganze Periode
  signal counter    : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      period_reg <= (others => '0');
      counter <= (others => '0');
      wave <= '0';
    else
      if clk'event and clk = '1' then
        if counter + 1 >= period_reg then      -- Periode vorbei
          counter <= (others => '0');
          period_reg <= unsigned(period);      -- neuen Wert erst jetzt uebernehmen
          wave <= '0';                         -- erste Haelfte '0'
        else
          counter <= counter + 1;
          if counter + 1 >= period_reg / 2 then
            wave <= '1';                       -- zweite Haelfte '1'
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
entity period_rom is
  port(
    key_num : in  std_logic_vector(3 downto 0);    -- 1 = C ... 12 = H, sonst Stille
    period  : out std_logic_vector(17 downto 0)
    );
end entity period_rom;

library ieee; use ieee.numeric_std.all;
architecture behav of period_rom is
  type rom_type is array (0 to 15) of natural range 0 to 2**18 - 1;
  -- Periode in Takten bei 50 MHz: 50e6 / f
  constant ROM : rom_type := (
    0, 191131, 180375, 170242, 160720, 151699, 143184,
    135135, 127551, 120395, 113636, 107250, 101235, 0, 0, 0);
begin
  period <= std_logic_vector(to_unsigned(ROM(to_integer(unsigned(key_num))), 18));
end architecture behav;

-- ===== Projekt 7: Kellerautomat fuer Klammerausdruecke (nach F24 A2) =====
package keller_types is
  type input_type is ('x', '-', '(', ')', '[', ']', '!');
  type output_type is ('0', '1', '*');
  type stack_character_type is (epsilon, '[', '(', eos);
  subtype stack_input_type   is stack_character_type range epsilon to '(';
  subtype stack_output_type  is stack_character_type range '[' to eos;
  subtype stack_element_type is stack_character_type range '[' to '(';
end package keller_types;

library ieee; use ieee.std_logic_1164.all;
use work.keller_types.all;
entity stack is
  generic(N : positive := 8);
  port(
    clk, res_n : in  std_logic;
    push       : in  stack_input_type;     -- epsilon: nichts ablegen
    pop, clr   : in  boolean;
    tos        : out stack_output_type     -- eos: Stapel leer
    );
end entity stack;

architecture behav of stack is
  type mem_type is array (1 to N) of stack_element_type;
  signal mem : mem_type;
  signal sp  : integer range 0 to N;       -- Anzahl Elemente
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      sp <= 0;
    else
      if clk'event and clk = '1' then
        -- hier stehen die Pruefungen: nur zur Taktflanke zaehlt die Anfrage
        assert not ((push /= epsilon and pop) or (push /= epsilon and clr) or (pop and clr))
          report "stack: mehr als eine Operation im selben Takt" severity error;
        assert not (push /= epsilon and sp = N)
          report "stack: Ueberlauf" severity error;
        if clr then
          sp <= 0;
        elsif push /= epsilon and sp < N then
          mem(sp + 1) <= push;
          sp <= sp + 1;
        elsif pop and sp > 0 then
          sp <= sp - 1;
        end if;
      end if;
    end if;
  end process;
  tos <= mem(sp) when sp > 0 else eos;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
use work.keller_types.all;
entity fsm is
  port(
    clk, res_n : in  std_logic;
    x          : in  input_type;
    tos        : in  stack_output_type;
    y          : out output_type;
    push       : out stack_input_type;
    pop, clr   : out boolean
    );
end entity fsm;

architecture behav of fsm is
  -- operand: ein Operand wird erwartet; operator: nach einem fertigen Operanden
  type state_type is (operand, operator, fehler);
  signal current_state, next_state : state_type;
begin
  transition_function: process(current_state, x, tos) is
  begin
    next_state <= current_state;
    y <= '*'; push <= epsilon; pop <= false; clr <= false;
    if x = '!' then
      clr <= true;
      next_state <= operand;
      if current_state = operator and tos = eos then
        y <= '1';
      else
        y <= '0';
      end if;
    else
      case current_state is
        when operand =>
          case x is
            when 'x'    => next_state <= operator;
            when '('    => push <= '(';
            when '['    => push <= '[';
            when others => next_state <= fehler;
          end case;
        when operator =>
          case x is
            when '-' =>                       -- in [ ] steht nur ein Operand
              if tos = '[' then next_state <= fehler; else next_state <= operand; end if;
            when ')' =>
              if tos = '(' then pop <= true; else next_state <= fehler; end if;
            when ']' =>
              if tos = '[' then pop <= true; else next_state <= fehler; end if;
            when others =>
              next_state <= fehler;
          end case;
        when fehler =>
          null;                               -- warten auf '!'
      end case;
    end if;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= operand;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
use work.keller_types.all;
entity kellerautomat is
  port(
    clk, res_n : in  std_logic;
    x          : in  input_type;
    y          : out output_type
    );
end entity kellerautomat;

architecture struct of kellerautomat is
  signal push : stack_input_type;
  signal pop, clr : boolean;
  signal tos : stack_output_type;
begin
  f: entity work.fsm port map(clk => clk, res_n => res_n, x => x, tos => tos,
                              y => y, push => push, pop => pop, clr => clr);
  s: entity work.stack generic map(N => 8)
     port map(clk => clk, res_n => res_n, push => push, pop => pop, clr => clr, tos => tos);
end architecture struct;

-- Synthesizer fuer einen Ton: ROM und Oszillator verbunden (P16)
library ieee; use ieee.std_logic_1164.all;
entity tongenerator is
  port(
    clk, res_n : in  std_logic;
    key_num    : in  std_logic_vector(3 downto 0);
    wave       : out std_logic
    );
end entity tongenerator;

architecture struct of tongenerator is
  signal period : std_logic_vector(17 downto 0);
begin
  rom: entity work.period_rom
    port map(key_num => key_num, period => period);
  o: entity work.osc
    generic map(N => 18)
    port map(clk => clk, res_n => res_n, period => period, wave => wave);
end architecture struct;
