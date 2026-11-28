-- Block S: das Spiel Senso, komplett (nach Uebung 2 "Senso", eigene Loesung)

-- Gemeinsame Typen
library ieee; use ieee.std_logic_1164.all;
package senso_pkg is
  subtype color_type is std_logic_vector(1 downto 0);   -- 00 rot, 01 blau, 10 gelb, 11 gruen
  type segment_type is (a, b, c, d, e, f, g);
  type seg7_type is array (segment_type) of std_logic;  -- low-aktiv: '0' = Segment leuchtet
end package senso_pkg;

-- ===== Zeitgeber =====
library ieee; use ieee.std_logic_1164.all;
entity timer is
  generic(
    D_INIT : positive := 25_000_000;   -- 500 ms bei 50 MHz
    D_STEP : positive := 2_500_000;    -- pro Level 50 ms schneller
    D_MIN  : positive := 5_000_000     -- nie kuerzer als 100 ms
    );
  port(
    clk, res_n    : in  std_logic;
    start_timer   : in  std_logic;
    dec_duration  : in  std_logic;
    res_duration  : in  std_logic;
    timer_expired : out std_logic
    );
end entity timer;

architecture behav of timer is
  signal duration : integer range 1 to D_INIT;
  signal count    : integer range 0 to D_INIT - 1;
  signal running  : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      duration <= D_INIT;
      count <= 0;
      running <= '0';
      timer_expired <= '0';
    else
      if clk'event and clk = '1' then
        timer_expired <= '0';
        -- Dauer einstellen
        if res_duration = '1' then
          duration <= D_INIT;
        elsif dec_duration = '1' and duration - D_STEP >= D_MIN then
          duration <= duration - D_STEP;
        end if;
        -- Zeit messen
        if running = '0' then
          if start_timer = '1' then
            running <= '1';
            count <= 0;
          end if;
        elsif count = duration - 1 then
          running <= '0';
          timer_expired <= '1';
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;
end architecture behav;

-- ===== Taster: Synchronisierer und Impulsverkuerzer =====
library ieee; use ieee.std_logic_1164.all;
entity button is
  port(
    clk, res_n : in  std_logic;
    tx_n       : in  std_logic;     -- low-aktiv, asynchron
    key        : out std_logic      -- ein Takt '1' pro Tastendruck
    );
end entity button;

architecture behav of button is
  signal tx_1st, tx_sync : std_logic;
  type state_type is (idle, pulse, hold);
  signal current_state, next_state : state_type;
begin
  -- Dual Rank Synchronizer (zwei Flipflops hintereinander)
  drs: process(clk, res_n) is
  begin
    if res_n = '0' then
      tx_1st  <= '0';
      tx_sync <= '0';
    else
      if clk'event and clk = '1' then
        tx_1st  <= not tx_n;
        tx_sync <= tx_1st;
      end if;
    end if;
  end process drs;

  -- Impulsverkuerzer als Moore-Automat
  transition_function: process(current_state, tx_sync) is
  begin
    case current_state is
      when idle =>
        if tx_sync = '1' then next_state <= pulse; else next_state <= idle; end if;
      when pulse =>
        if tx_sync = '1' then next_state <= hold; else next_state <= idle; end if;
      when hold =>
        if tx_sync = '1' then next_state <= hold; else next_state <= idle; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= idle;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  key <= '1' when current_state = pulse else '0';
end architecture behav;

-- ===== Eingabeeinheit: vier Taster =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity input is
  port(
    clk, res_n : in  std_logic;
    key_in_n   : in  std_logic_vector(3 downto 0);
    key_valid  : out std_logic;
    key_color  : out color_type
    );
end entity input;

architecture mixed of input is
  signal keys : std_logic_vector(3 downto 0);
begin
  buttons: for i in 0 to 3 generate
    b: entity work.button port map(clk => clk, res_n => res_n, tx_n => key_in_n(i), key => keys(i));
  end generate buttons;

  key_valid <= keys(0) or keys(1) or keys(2) or keys(3);

  -- Farbe = Nummer der Taste (bei gleichzeitigem Druck gewinnt die hoechste)
  key_color <= "11" when keys(3) = '1' else
               "10" when keys(2) = '1' else
               "01" when keys(1) = '1' else
               "00";
end architecture mixed;

-- ===== Rueckgekoppeltes Schieberegister (Galois-LFSR) =====
library ieee; use ieee.std_logic_1164.all;
entity galois_lfsr is
  port(
    clk, res_n : in  std_logic;
    reset      : in  std_logic;                       -- synchron, high-aktiv
    fb         : in  std_logic_vector(7 downto 1);    -- '1' = XOR vor q(i)
    q          : out std_logic_vector(7 downto 0)
    );
end entity galois_lfsr;

architecture behav of galois_lfsr is
begin
  process(clk, res_n) is
    variable q_int : std_logic_vector(7 downto 0);
  begin
    if res_n = '0' then
      q_int := "00000001";
    else
      if clk'event and clk = '1' then
        if reset = '1' then
          q_int := "00000001";
        elsif q_int(7) = '1' then
          q_int := (q_int(6 downto 0) xor fb) & q_int(7);
        else
          q_int := q_int(6 downto 0) & q_int(7);
        end if;
      end if;
    end if;
    q <= q_int;
  end process;
end architecture behav;

-- Variante mit for-Schleife: gleiche Hardware
architecture loop_version of galois_lfsr is
  signal q_int : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      q_int <= "00000001";
    else
      if clk'event and clk = '1' then
        if reset = '1' then
          q_int <= "00000001";
        else
          q_int(0) <= q_int(7);
          for i in 1 to 7 loop
            q_int(i) <= q_int(i-1) xor (fb(i) and q_int(7));
          end loop;
        end if;
      end if;
    end if;
  end process;
  q <= q_int;
end architecture loop_version;

-- ===== Zufallszahlen mit Startwert-Speicher =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity random is
  port(
    clk, res_n  : in  std_logic;
    next_rnd    : in  std_logic;
    store_rnd   : in  std_logic;
    restore_rnd : in  std_logic;
    rnd         : out color_type
    );
end entity random;

architecture behav of random is
  constant FB : std_logic_vector(7 downto 1) := "0001110";   -- maximale Zykluslaenge 255
  signal sr, mr : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      sr <= "00000001";
      mr <= "00000001";
    else
      if clk'event and clk = '1' then
        if store_rnd = '1' then
          mr <= sr;
        end if;
        if restore_rnd = '1' then
          sr <= mr;
        elsif next_rnd = '1' then
          if sr(7) = '1' then
            sr <= (sr(6 downto 0) xor FB) & sr(7);
          else
            sr <= sr(6 downto 0) & sr(7);
          end if;
        end if;
      end if;
    end if;
  end process;
  rnd <= sr(1 downto 0);
end architecture behav;

-- ===== Zaehlereinheit =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity seg7_decoder is
  port(
    digit : in  integer range 0 to 9;
    seg   : out seg7_type
    );
end entity seg7_decoder;

architecture behav of seg7_decoder is
begin
  with digit select seg <=    --  a    b    c    d    e    f    g
    ('0', '0', '0', '0', '0', '0', '1') when 0,
    ('1', '0', '0', '1', '1', '1', '1') when 1,
    ('0', '0', '1', '0', '0', '1', '0') when 2,
    ('0', '0', '0', '0', '1', '1', '0') when 3,
    ('1', '0', '0', '1', '1', '0', '0') when 4,
    ('0', '1', '0', '0', '1', '0', '0') when 5,
    ('0', '1', '0', '0', '0', '0', '0') when 6,
    ('0', '0', '0', '1', '1', '1', '1') when 7,
    ('0', '0', '0', '0', '0', '0', '0') when 8,
    ('0', '0', '0', '0', '1', '0', '0') when 9;
end architecture behav;

library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity counter is
  port(
    clk, res_n    : in  std_logic;
    res_step      : in  std_logic;
    inc_step      : in  std_logic;
    res_score     : in  std_logic;
    inc_score     : in  std_logic;
    step_eq_score : out std_logic;
    score_low     : out seg7_type;
    score_high    : out seg7_type
    );
end entity counter;

architecture mixed of counter is
  signal step, score : integer range 0 to 63;
  signal tens, ones  : integer range 0 to 9;
begin
  counters: process(clk, res_n) is
  begin
    if res_n = '0' then
      step <= 0;
      score <= 0;
    else
      if clk'event and clk = '1' then
        if res_step = '1' then
          step <= 0;
        elsif inc_step = '1' then
          step <= (step + 1) mod 64;
        end if;
        if res_score = '1' then
          score <= 0;
        elsif inc_score = '1' then
          score <= (score + 1) mod 64;
        end if;
      end if;
    end if;
  end process counters;

  step_eq_score <= '1' when step = score else '0';

  -- BIN2BCD
  tens <= score / 10;
  ones <= score mod 10;

  dec_high: entity work.seg7_decoder port map(digit => tens, seg => score_high);
  dec_low:  entity work.seg7_decoder port map(digit => ones, seg => score_low);
end architecture mixed;

-- ===== Ausgabeeinheit =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity output is
  port(
    led_on, all_on : in  std_logic;
    color          : in  color_type;
    leds           : out std_logic_vector(3 downto 0)
    );
end entity output;

library ieee; use ieee.numeric_std.all;
architecture behav of output is
begin
  process(led_on, all_on, color) is
  begin
    leds <= (others => all_on);
    if led_on = '1' then
      leds(to_integer(unsigned(color))) <= '1';
    end if;
  end process;
end architecture behav;

-- ===== Hauptsteuerung =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity control is
  port(
    clk, res_n    : in  std_logic;
    key_valid     : in  std_logic;
    key_color     : in  color_type;
    rnd           : in  color_type;
    timer_expired : in  std_logic;
    step_eq_score : in  std_logic;
    next_rnd, store_rnd, restore_rnd    : out std_logic;
    res_step, inc_step                  : out std_logic;
    res_score, inc_score                : out std_logic;
    start_timer, dec_duration, res_duration : out std_logic;
    led_on, all_on                      : out std_logic
    );
end entity control;

architecture behav of control is
  type state_type is (init, store, load, show, pause, show_next,
                      reload, wait_key, key_ok, won, lost);
  signal current_state, next_state : state_type;
begin
  transition_function: process(current_state, key_valid, key_color, rnd,
                               timer_expired, step_eq_score) is
  begin
    next_state <= current_state;
    case current_state is
      when init =>                                   -- 1. warten auf den Start
        if key_valid = '1' then next_state <= store; end if;
      when store =>                                  -- 2. Startwert merken
        next_state <= load;
      when load =>                                   -- 3. Startwert laden
        next_state <= show;
      when show =>                                   -- 4. eine Farbe zeigen
        if timer_expired = '1' then next_state <= pause; end if;
      when pause =>
        if timer_expired = '1' then
          if step_eq_score = '1' then
            next_state <= reload;
          else
            next_state <= show_next;
          end if;
        end if;
      when show_next =>
        next_state <= show;
      when reload =>                                 -- 5. Startwert wieder laden
        next_state <= wait_key;
      when wait_key =>                               -- 6. Spieler ist dran
        if key_valid = '1' then
          if key_color /= rnd then
            next_state <= lost;
          elsif step_eq_score = '1' then
            next_state <= won;
          else
            next_state <= key_ok;
          end if;
        end if;
      when key_ok =>
        next_state <= wait_key;
      when won =>
        next_state <= load;
      when lost =>
        if timer_expired = '1' then next_state <= init; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= init;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    next_rnd <= '0'; store_rnd <= '0'; restore_rnd <= '0';
    res_step <= '0'; inc_step <= '0'; res_score <= '0'; inc_score <= '0';
    start_timer <= '0'; dec_duration <= '0'; res_duration <= '0';
    led_on <= '0'; all_on <= '0';
    case current_state is
      when init      => next_rnd <= '1'; res_step <= '1'; res_score <= '1'; res_duration <= '1';
      when store     => store_rnd <= '1';
      when load      => restore_rnd <= '1'; res_step <= '1';
      when show      => led_on <= '1'; start_timer <= '1';
      when pause     => start_timer <= '1';
      when show_next => next_rnd <= '1'; inc_step <= '1';
      when reload    => restore_rnd <= '1'; res_step <= '1';
      when wait_key  => null;
      when key_ok    => next_rnd <= '1'; inc_step <= '1';
      when won       => inc_score <= '1'; dec_duration <= '1';
      when lost      => all_on <= '1'; start_timer <= '1';
    end case;
  end process output_function;
end architecture behav;

-- ===== Gesamtsystem =====
library ieee; use ieee.std_logic_1164.all;
use work.senso_pkg.all;
entity senso is
  generic(
    D_INIT : positive := 25_000_000;
    D_STEP : positive := 2_500_000;
    D_MIN  : positive := 5_000_000
    );
  port(
    clk, res_n : in  std_logic;
    key_in_n   : in  std_logic_vector(3 downto 0);
    leds       : out std_logic_vector(3 downto 0);
    score_low, score_high : out seg7_type
    );
end entity senso;

architecture struct of senso is
  signal key_valid, timer_expired, step_eq_score : std_logic;
  signal key_color, rnd : color_type;
  signal next_rnd, store_rnd, restore_rnd, res_step, inc_step, res_score, inc_score : std_logic;
  signal start_timer, dec_duration, res_duration, led_on, all_on : std_logic;
begin
  i_input: entity work.input
    port map(clk => clk, res_n => res_n, key_in_n => key_in_n,
             key_valid => key_valid, key_color => key_color);
  i_control: entity work.control
    port map(clk => clk, res_n => res_n, key_valid => key_valid, key_color => key_color,
             rnd => rnd, timer_expired => timer_expired, step_eq_score => step_eq_score,
             next_rnd => next_rnd, store_rnd => store_rnd, restore_rnd => restore_rnd,
             res_step => res_step, inc_step => inc_step,
             res_score => res_score, inc_score => inc_score,
             start_timer => start_timer, dec_duration => dec_duration,
             res_duration => res_duration, led_on => led_on, all_on => all_on);
  i_timer: entity work.timer
    generic map(D_INIT => D_INIT, D_STEP => D_STEP, D_MIN => D_MIN)
    port map(clk => clk, res_n => res_n, start_timer => start_timer,
             dec_duration => dec_duration, res_duration => res_duration,
             timer_expired => timer_expired);
  i_counter: entity work.counter
    port map(clk => clk, res_n => res_n, res_step => res_step, inc_step => inc_step,
             res_score => res_score, inc_score => inc_score,
             step_eq_score => step_eq_score, score_low => score_low, score_high => score_high);
  i_random: entity work.random
    port map(clk => clk, res_n => res_n, next_rnd => next_rnd, store_rnd => store_rnd,
             restore_rnd => restore_rnd, rnd => rnd);
  i_output: entity work.output
    port map(led_on => led_on, all_on => all_on, color => rnd, leds => leds);
end architecture struct;
