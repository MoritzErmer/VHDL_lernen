-- Block M: Standardbausteine (Loesungen), Stil wie im Skript: res_n low-aktiv, clk'event and clk = '1'

-- M01: Register mit Enable und synchronem Loeschen
library ieee; use ieee.std_logic_1164.all;
entity register_n is
  generic(N : positive := 8);
  port(
    clk, res_n : in  std_logic;
    en, clr    : in  std_logic;
    d          : in  std_logic_vector(N-1 downto 0);
    q          : out std_logic_vector(N-1 downto 0)
    );
end entity register_n;

architecture behav of register_n is
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      q <= (others => '0');
    else
      if clk'event and clk = '1' then
        if clr = '1' then
          q <= (others => '0');
        elsif en = '1' then
          q <= d;
        end if;
      end if;
    end if;
  end process;
end architecture behav;

-- M02: Universal-Schieberegister: parallel laden oder seriell nach links schieben
library ieee; use ieee.std_logic_1164.all;
entity schiebe_reg is
  generic(N : positive := 8);
  port(
    clk, res_n    : in  std_logic;
    load, shift   : in  std_logic;
    din           : in  std_logic_vector(N-1 downto 0);
    ser_in        : in  std_logic;
    q             : out std_logic_vector(N-1 downto 0);
    ser_out       : out std_logic
    );
end entity schiebe_reg;

architecture behav of schiebe_reg is
  signal sr : std_logic_vector(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      sr <= (others => '0');
    else
      if clk'event and clk = '1' then
        if load = '1' then
          sr <= din;
        elsif shift = '1' then
          sr <= sr(N-2 downto 0) & ser_in;
        end if;
      end if;
    end if;
  end process;
  q       <= sr;
  ser_out <= sr(N-1);
end architecture behav;

-- M03: Modulo-Zaehler mit Enable und Uebertrag (zaehlt 0 .. MAX)
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity zaehler_mod is
  generic(MAX : positive := 9);
  port(
    clk, res_n : in  std_logic;
    en         : in  std_logic;
    q          : out integer range 0 to MAX;
    ueberlauf  : out std_logic
    );
end entity zaehler_mod;

architecture behav of zaehler_mod is
  signal cnt : integer range 0 to MAX;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= 0;
    else
      if clk'event and clk = '1' then
        if en = '1' then
          if cnt = MAX then
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
  q <= cnt;
  ueberlauf <= '1' when en = '1' and cnt = MAX else '0';
end architecture behav;

-- M04: Taktteiler als Enable-Puls: tick ist alle N Takte fuer einen Takt '1'
library ieee; use ieee.std_logic_1164.all;
entity taktteiler is
  generic(N : positive := 4);
  port(
    clk, res_n : in  std_logic;
    tick       : out std_logic
    );
end entity taktteiler;

architecture behav of taktteiler is
  signal cnt : integer range 0 to N-1;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= 0;
    else
      if clk'event and clk = '1' then
        if cnt = N-1 then
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  tick <= '1' when cnt = N-1 else '0';
end architecture behav;

-- M05: Entpreller: Ausgang folgt dem Eingang erst, wenn er N Takte stabil anders war
library ieee; use ieee.std_logic_1164.all;
entity entpreller is
  generic(N : positive := 4);
  port(
    clk, res_n : in  std_logic;
    roh        : in  std_logic;   -- schon synchronisiert (D05)
    sauber     : out std_logic
    );
end entity entpreller;

architecture behav of entpreller is
  signal zustand : std_logic;
  signal cnt     : integer range 0 to N;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      zustand <= '0';
      cnt     <= 0;
    else
      if clk'event and clk = '1' then
        if roh = zustand then
          cnt <= 0;                 -- nichts zu tun, Zaehler zuruecksetzen
        elsif cnt = N-1 then
          zustand <= roh;           -- lange genug stabil: uebernehmen
          cnt     <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  sauber <= zustand;
end architecture behav;

-- M06: PWM: pwm ist '1', solange der freilaufende Zaehler kleiner als duty ist
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity pwm is
  generic(N : positive := 4);
  port(
    clk, res_n : in  std_logic;
    duty       : in  std_logic_vector(N-1 downto 0);
    pwm_out    : out std_logic
    );
end entity pwm;

architecture behav of pwm is
  signal cnt : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= (others => '0');
    else
      if clk'event and clk = '1' then
        cnt <= cnt + 1;             -- laeuft modulo 2^N ueber
      end if;
    end if;
  end process;
  pwm_out <= '1' when cnt < unsigned(duty) else '0';
end architecture behav;

-- M07: synchroner FIFO (Ringpuffer) mit DEPTH Woertern
library ieee; use ieee.std_logic_1164.all;
entity fifo is
  generic(DEPTH : positive := 4; W : positive := 8);
  port(
    clk, res_n    : in  std_logic;
    wr_en, rd_en  : in  std_logic;
    din           : in  std_logic_vector(W-1 downto 0);
    dout          : out std_logic_vector(W-1 downto 0);
    empty, full   : out std_logic
    );
end entity fifo;

architecture behav of fifo is
  type memory_type is array (0 to DEPTH-1) of std_logic_vector(W-1 downto 0);
  signal memory : memory_type;
  signal windex, rindex : integer range 0 to DEPTH-1;
  signal count : integer range 0 to DEPTH;
begin
  process(clk, res_n) is
    variable do_wr, do_rd : boolean;
  begin
    if res_n = '0' then
      windex <= 0;
      rindex <= 0;
      count  <= 0;
    else
      if clk'event and clk = '1' then
        do_wr := wr_en = '1' and count < DEPTH;
        do_rd := rd_en = '1' and count > 0;
        if do_wr then
          memory(windex) <= din;
          windex <= (windex + 1) mod DEPTH;
        end if;
        if do_rd then
          rindex <= (rindex + 1) mod DEPTH;
        end if;
        if do_wr and not do_rd then
          count <= count + 1;
        elsif do_rd and not do_wr then
          count <= count - 1;
        end if;
      end if;
    end if;
  end process;
  dout  <= memory(rindex);             -- vorderstes Element liegt immer an
  empty <= '1' when count = 0 else '0';
  full  <= '1' when count = DEPTH else '0';
end architecture behav;

-- M08: Registerbank / RAM: synchron schreiben, asynchron lesen
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity ram is
  generic(ADDR_WIDTH : natural := 3; DATA_WIDTH : positive := 8);
  port(
    clk   : in  std_logic;
    we    : in  std_logic;
    addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    din   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    dout  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity ram;

architecture behav of ram is
  type memory_type is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal memory : memory_type;
begin
  process(clk) is
  begin
    if clk'event and clk = '1' then
      if we = '1' then
        memory(to_integer(unsigned(addr))) <= din;
      end if;
    end if;
  end process;
  dout <= memory(to_integer(unsigned(addr)));
end architecture behav;

-- M09: Ampel mit Timer: Automat + Zaehler (Moore)
library ieee; use ieee.std_logic_1164.all;
entity ampel is
  generic(T_ROT : positive := 5; T_ROTGELB : positive := 1; T_GRUEN : positive := 4; T_GELB : positive := 2);
  port(
    clk, res_n       : in  std_logic;
    rot, gelb, gruen : out std_logic
    );
end entity ampel;

architecture behav of ampel is
  type state_type is (s_rot, s_rotgelb, s_gruen, s_gelb);
  signal current_state, next_state : state_type;
  signal zeit : integer range 0 to 31;
begin
  transition_function: process(current_state, zeit) is
  begin
    next_state <= current_state;
    case current_state is
      when s_rot     => if zeit = T_ROT - 1     then next_state <= s_rotgelb; end if;
      when s_rotgelb => if zeit = T_ROTGELB - 1 then next_state <= s_gruen;   end if;
      when s_gruen   => if zeit = T_GRUEN - 1   then next_state <= s_gelb;    end if;
      when s_gelb    => if zeit = T_GELB - 1    then next_state <= s_rot;     end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= s_rot;
      zeit <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;                       -- neuer Zustand: Zeit von vorn
        else
          zeit <= zeit + 1;
        end if;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    rot <= '0'; gelb <= '0'; gruen <= '0';
    case current_state is
      when s_rot     => rot <= '1';
      when s_rotgelb => rot <= '1'; gelb <= '1';
      when s_gruen   => gruen <= '1';
      when s_gelb    => gelb <= '1';
    end case;
  end process output_function;
end architecture behav;

-- M10: serieller Sender (wie UART): Ruhepegel 1, Startbit 0, 8 Datenbits LSB zuerst, Stoppbit 1
library ieee; use ieee.std_logic_1164.all;
entity sender is
  generic(BIT_TAKTE : positive := 4);
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    data       : in  std_logic_vector(7 downto 0);
    tx         : out std_logic;
    busy       : out std_logic
    );
end entity sender;

architecture behav of sender is
  signal sr      : std_logic_vector(9 downto 0);   -- Stoppbit & Daten & Startbit
  signal bitnr   : integer range 0 to 9;
  signal takt    : integer range 0 to BIT_TAKTE - 1;
  signal aktiv   : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      aktiv <= '0';
      sr    <= (others => '1');
      bitnr <= 0;
      takt  <= 0;
    else
      if clk'event and clk = '1' then
        if aktiv = '0' then
          if start = '1' then
            sr    <= '1' & data & '0';
            aktiv <= '1';
            bitnr <= 0;
            takt  <= 0;
          end if;
        elsif takt = BIT_TAKTE - 1 then      -- ein Bit fertig gesendet
          takt <= 0;
          sr   <= '1' & sr(9 downto 1);        -- naechstes Bit nach vorn schieben
          if bitnr = 9 then
            aktiv <= '0';
          else
            bitnr <= bitnr + 1;
          end if;
        else
          takt <= takt + 1;
        end if;
      end if;
    end if;
  end process;
  tx   <= sr(0) when aktiv = '1' else '1';
  busy <= aktiv;
end architecture behav;
