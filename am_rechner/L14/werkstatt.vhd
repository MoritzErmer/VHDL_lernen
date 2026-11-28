-- Block W: Werkstatt, komplette Programmieraufgaben (eigene Aufgaben)

-- ===== W02 Lauflicht hin und her =====
library ieee; use ieee.std_logic_1164.all;
entity lauflicht is
  generic(N : positive := 8; T_SCHRITT : positive := 5_000_000);
  port(
    clk, res_n : in  std_logic;
    en         : in  std_logic;
    leds       : out std_logic_vector(N-1 downto 0)
    );
end entity lauflicht;

architecture behav of lauflicht is
  signal teiler : integer range 0 to T_SCHRITT - 1;
  signal pos    : integer range 0 to N - 1;
  signal hoch   : boolean;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      teiler <= 0;
      pos <= 0;
      hoch <= true;
    else
      if clk'event and clk = '1' then
        if en = '1' then
          if teiler = T_SCHRITT - 1 then
            teiler <= 0;
            if hoch then
              if pos = N - 1 then
                hoch <= false;
                pos <= pos - 1;
              else
                pos <= pos + 1;
              end if;
            else
              if pos = 0 then
                hoch <= true;
                pos <= pos + 1;
              else
                pos <= pos - 1;
              end if;
            end if;
          else
            teiler <= teiler + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(pos) is
  begin
    leds <= (others => '0');
    leds(pos) <= '1';
  end process;
end architecture behav;

-- ===== W03 Parkhaus mit zwei Lichtschranken =====
library ieee; use ieee.std_logic_1164.all;
entity parkhaus is
  generic(PLAETZE : positive := 50);
  port(
    clk, res_n : in  std_logic;
    a, b       : in  std_logic;     -- a aussen, b innen, '1' = unterbrochen
    belegt     : out natural range 0 to PLAETZE;
    voll       : out std_logic
    );
end entity parkhaus;

architecture behav of parkhaus is
  type state_type is (frei, e1, e2, e3, a1, a2, a3);
  signal current_state, next_state : state_type;
  signal rein, raus : std_logic;
  signal anzahl : natural range 0 to PLAETZE;
begin
  transition_function: process(current_state, a, b) is
  begin
    next_state <= current_state;
    rein <= '0';
    raus <= '0';
    case current_state is
      when frei =>
        if a = '1' and b = '0' then next_state <= e1;
        elsif a = '0' and b = '1' then next_state <= a1;
        end if;
      when e1 =>
        if a = '1' and b = '1' then next_state <= e2;
        elsif a = '0' and b = '0' then next_state <= frei;
        end if;
      when e2 =>
        if a = '0' and b = '1' then next_state <= e3;
        elsif a = '1' and b = '0' then next_state <= e1;
        end if;
      when e3 =>
        if a = '0' and b = '0' then next_state <= frei; rein <= '1';
        elsif a = '1' and b = '1' then next_state <= e2;
        end if;
      when a1 =>
        if a = '1' and b = '1' then next_state <= a2;
        elsif a = '0' and b = '0' then next_state <= frei;
        end if;
      when a2 =>
        if a = '1' and b = '0' then next_state <= a3;
        elsif a = '0' and b = '1' then next_state <= a1;
        end if;
      when a3 =>
        if a = '0' and b = '0' then next_state <= frei; raus <= '1';
        elsif a = '1' and b = '1' then next_state <= a2;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= frei;
      anzahl <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if rein = '1' and anzahl < PLAETZE then
          anzahl <= anzahl + 1;
        elsif raus = '1' and anzahl > 0 then
          anzahl <= anzahl - 1;
        end if;
      end if;
    end if;
  end process state;

  belegt <= anzahl;
  voll <= '1' when anzahl = PLAETZE else '0';
end architecture behav;

-- ===== W04 Stoppuhr =====
library ieee; use ieee.std_logic_1164.all;
entity stoppuhr is
  generic(TAKTE_PRO_ZEHNTEL : positive := 5_000_000);
  port(
    clk, res_n  : in  std_logic;
    start_stop  : in  std_logic;     -- Impuls: startet bzw. haelt an
    nullen      : in  std_logic;     -- Impuls: Zeit auf 0, Uhr steht
    zehntel     : out natural range 0 to 9;
    sekunden    : out natural range 0 to 59;
    minuten     : out natural range 0 to 9
    );
end entity stoppuhr;

architecture behav of stoppuhr is
  signal teiler : natural range 0 to TAKTE_PRO_ZEHNTEL - 1;
  signal laeuft : std_logic;
  signal z : natural range 0 to 9;
  signal s : natural range 0 to 59;
  signal m : natural range 0 to 9;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      teiler <= 0; laeuft <= '0'; z <= 0; s <= 0; m <= 0;
    else
      if clk'event and clk = '1' then
        if nullen = '1' then
          teiler <= 0; laeuft <= '0'; z <= 0; s <= 0; m <= 0;
        else
          if start_stop = '1' then
            laeuft <= not laeuft;
          end if;
          if laeuft = '1' then
            if teiler = TAKTE_PRO_ZEHNTEL - 1 then
              teiler <= 0;
              if z = 9 then
                z <= 0;
                if s = 59 then
                  s <= 0;
                  if m = 9 then m <= 0; else m <= m + 1; end if;
                else
                  s <= s + 1;
                end if;
              else
                z <= z + 1;
              end if;
            else
              teiler <= teiler + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
  zehntel <= z;
  sekunden <= s;
  minuten <= m;
end architecture behav;

-- ===== W05 Ampel mit Fussgaengeranforderung =====
library ieee; use ieee.std_logic_1164.all;
entity fussgaengerampel is
  generic(
    T_GRUEN_MIN : positive := 20;
    T_GELB      : positive := 3;
    T_FUSS      : positive := 10;
    T_RAEUMEN   : positive := 4;
    T_ROTGELB   : positive := 2
    );
  port(
    clk, res_n                     : in  std_logic;
    taste                          : in  std_logic;   -- Impuls
    auto_rot, auto_gelb, auto_gruen : out std_logic;
    fuss_rot, fuss_gruen           : out std_logic;
    signal_kommt                   : out std_logic
    );
end entity fussgaengerampel;

architecture behav of fussgaengerampel is
  type state_type is (gruen, gelb, fuss_geht, raeumen, rotgelb);
  signal current_state, next_state : state_type;
  signal zeit   : natural range 0 to 255;
  signal wunsch : std_logic;
begin
  transition_function: process(current_state, zeit, wunsch) is
  begin
    next_state <= current_state;
    case current_state is
      when gruen =>
        if zeit >= T_GRUEN_MIN - 1 and wunsch = '1' then next_state <= gelb; end if;
      when gelb =>
        if zeit = T_GELB - 1 then next_state <= fuss_geht; end if;
      when fuss_geht =>
        if zeit = T_FUSS - 1 then next_state <= raeumen; end if;
      when raeumen =>
        if zeit = T_RAEUMEN - 1 then next_state <= rotgelb; end if;
      when rotgelb =>
        if zeit = T_ROTGELB - 1 then next_state <= gruen; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= gruen;
      zeit <= 0;
      wunsch <= '0';
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;
        elsif zeit < 255 then
          zeit <= zeit + 1;
        end if;
        if current_state = fuss_geht then
          wunsch <= '0';
        elsif taste = '1' then
          wunsch <= '1';
        end if;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    auto_rot <= '0'; auto_gelb <= '0'; auto_gruen <= '0';
    fuss_rot <= '1'; fuss_gruen <= '0';
    case current_state is
      when gruen     => auto_gruen <= '1';
      when gelb      => auto_gelb <= '1';
      when fuss_geht => auto_rot <= '1'; fuss_rot <= '0'; fuss_gruen <= '1';
      when raeumen   => auto_rot <= '1';
      when rotgelb   => auto_rot <= '1'; auto_gelb <= '1';
    end case;
  end process output_function;

  signal_kommt <= wunsch;
end architecture behav;

-- ===== W06 Aufzug mit drei Etagen =====
library ieee; use ieee.std_logic_1164.all;
entity aufzug is
  generic(T_FAHRT : positive := 10; T_TUER : positive := 8);
  port(
    clk, res_n    : in  std_logic;
    ruf           : in  std_logic_vector(2 downto 0);   -- Impulse, eine Taste pro Etage
    motor_hoch    : out std_logic;
    motor_runter  : out std_logic;
    tuer_auf      : out std_logic;
    etage         : out natural range 0 to 2
    );
end entity aufzug;

architecture behav of aufzug is
  type state_type is (steht, hoch, runter, tuer);
  signal current_state, next_state : state_type;
  signal e       : natural range 0 to 2;
  signal auftrag : std_logic_vector(2 downto 0);
  signal zeit    : natural range 0 to 255;
  signal oben, unten : std_logic;     -- Auftraege ueber / unter der aktuellen Etage
begin
  process(e, auftrag) is
  begin
    oben <= '0';
    unten <= '0';
    for i in 0 to 2 loop
      if auftrag(i) = '1' and i > e then oben <= '1'; end if;
      if auftrag(i) = '1' and i < e then unten <= '1'; end if;
    end loop;
  end process;

  transition_function: process(current_state, auftrag, e, oben, unten, zeit) is
  begin
    next_state <= current_state;
    case current_state is
      when steht =>
        if auftrag(e) = '1' then next_state <= tuer;
        elsif oben = '1' then next_state <= hoch;
        elsif unten = '1' then next_state <= runter;
        end if;
      when hoch | runter =>
        if zeit = T_FAHRT - 1 then next_state <= steht; end if;
      when tuer =>
        if zeit = T_TUER - 1 then next_state <= steht; end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= steht;
      e <= 0;
      auftrag <= (others => '0');
      zeit <= 0;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
        if next_state /= current_state then
          zeit <= 0;
        elsif zeit < 255 then
          zeit <= zeit + 1;
        end if;
        -- angekommen: eine Etage weiter
        if current_state = hoch and next_state = steht then
          e <= e + 1;
        elsif current_state = runter and next_state = steht then
          e <= e - 1;
        end if;
        -- Auftraege merken, erledigt, sobald die Tuer aufgeht
        for i in 0 to 2 loop
          if current_state = tuer and i = e then
            auftrag(i) <= '0';
          elsif ruf(i) = '1' then
            auftrag(i) <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process state;

  motor_hoch   <= '1' when current_state = hoch else '0';
  motor_runter <= '1' when current_state = runter else '0';
  tuer_auf     <= '1' when current_state = tuer else '0';
  etage <= e;
end architecture behav;

-- ===== W07 Reaktionstester =====
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity reaktionstester is
  generic(
    TAKTE_PRO_MS : positive := 50_000;
    WARTE_MIN_MS : positive := 1000;   -- mindestens so lange warten
    WARTE_SCHRITT_MS : positive := 200 -- plus zufaellig 0..15 Schritte
    );
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;        -- Impuls
    taste      : in  std_logic;        -- Impuls
    led        : out std_logic;        -- jetzt druecken!
    fruehstart : out std_logic;
    ergebnis   : out natural range 0 to 999;   -- Reaktionszeit in ms
    gueltig    : out std_logic
    );
end entity reaktionstester;

architecture behav of reaktionstester is
  type state_type is (bereit, warten, messen, fertig, zu_frueh);
  signal state : state_type;
  signal lfsr  : std_logic_vector(7 downto 0);
  signal ms_teiler : natural range 0 to TAKTE_PRO_MS - 1;
  signal ms_tick   : std_logic;
  signal rest  : natural range 0 to WARTE_MIN_MS + 15 * WARTE_SCHRITT_MS;
  signal zeit  : natural range 0 to 999;
begin
  -- Zufall: laeuft immer, der Zeitpunkt des Starts bestimmt den Wert
  zufall: process(clk, res_n) is
  begin
    if res_n = '0' then
      lfsr <= "00000001";
    else
      if clk'event and clk = '1' then
        if lfsr(7) = '1' then
          lfsr <= (lfsr(6 downto 0) xor "0001110") & lfsr(7);
        else
          lfsr <= lfsr(6 downto 0) & lfsr(7);
        end if;
      end if;
    end if;
  end process zufall;

  -- Millisekunden-Takt
  teiler: process(clk, res_n) is
  begin
    if res_n = '0' then
      ms_teiler <= 0;
      ms_tick <= '0';
    else
      if clk'event and clk = '1' then
        ms_tick <= '0';
        if state = bereit then
          ms_teiler <= 0;
        elsif ms_teiler = TAKTE_PRO_MS - 1 then
          ms_teiler <= 0;
          ms_tick <= '1';
        else
          ms_teiler <= ms_teiler + 1;
        end if;
      end if;
    end if;
  end process teiler;

  ablauf: process(clk, res_n) is
  begin
    if res_n = '0' then
      state <= bereit;
      rest <= 0;
      zeit <= 0;
    else
      if clk'event and clk = '1' then
        case state is
          when bereit | fertig | zu_frueh =>
            if start = '1' then
              state <= warten;
              rest <= WARTE_MIN_MS + to_integer(unsigned(lfsr(3 downto 0))) * WARTE_SCHRITT_MS;
              zeit <= 0;
            end if;
          when warten =>
            if taste = '1' then
              state <= zu_frueh;
            elsif ms_tick = '1' then
              if rest = 0 then
                state <= messen;
              else
                rest <= rest - 1;
              end if;
            end if;
          when messen =>
            if taste = '1' then
              state <= fertig;
            elsif ms_tick = '1' and zeit < 999 then
              zeit <= zeit + 1;
            end if;
        end case;
      end if;
    end if;
  end process ablauf;

  led        <= '1' when state = messen else '0';
  fruehstart <= '1' when state = zu_frueh else '0';
  gueltig    <= '1' when state = fertig else '0';
  ergebnis   <= zeit;
end architecture behav;

-- ===== W08 UART-Empfaenger mit Paritaet =====
library ieee; use ieee.std_logic_1164.all;
entity uart_rx is
  generic(TAKTE_PRO_BIT : positive := 434);    -- 50 MHz / 115200 Baud
  port(
    clk, res_n : in  std_logic;
    rx         : in  std_logic;    -- Ruhe '1', Start '0', 8 Daten LSB zuerst, gerade Paritaet, Stopp '1'
    daten      : out std_logic_vector(7 downto 0);
    gueltig    : out std_logic;    -- ein Takt, wenn ein Byte fertig ist
    par_fehler : out std_logic;    -- gilt zusammen mit gueltig
    rahmen_fehler : out std_logic
    );
end entity uart_rx;

architecture behav of uart_rx is
  type state_type is (ruhe, start, empfang);
  signal state : state_type;
  signal rx_d, rx_dd : std_logic;
  signal teiler : natural range 0 to TAKTE_PRO_BIT - 1;
  signal bitnr  : natural range 0 to 9;            -- 0..7 Daten, 8 Paritaet, 9 Stopp
  signal sr     : std_logic_vector(8 downto 0);    -- Paritaet & Daten
begin
  process(clk, res_n) is
    variable p : std_logic;
  begin
    if res_n = '0' then
      state <= ruhe; rx_d <= '1'; rx_dd <= '1';
      teiler <= 0; bitnr <= 0; sr <= (others => '0');
      gueltig <= '0'; par_fehler <= '0'; rahmen_fehler <= '0';
      daten <= (others => '0');
    else
      if clk'event and clk = '1' then
        rx_d <= rx;
        rx_dd <= rx_d;
        gueltig <= '0';
        case state is
          when ruhe =>
            if rx_dd = '0' then
              state <= start;
              teiler <= 0;
            end if;
          when start =>                         -- bis zur Mitte des Startbits
            if teiler = TAKTE_PRO_BIT / 2 - 1 then
              teiler <= 0;
              if rx_dd = '0' then
                state <= empfang;
                bitnr <= 0;
              else
                state <= ruhe;                  -- nur ein Stoerimpuls
              end if;
            else
              teiler <= teiler + 1;
            end if;
          when empfang =>
            if teiler = TAKTE_PRO_BIT - 1 then
              teiler <= 0;
              if bitnr = 9 then                 -- Stoppbit
                state <= ruhe;
                daten <= sr(7 downto 0);
                p := '0';
                for i in 0 to 8 loop
                  p := p xor sr(i);
                end loop;
                par_fehler <= p;                -- gerade Paritaet: xor ueber alles = 0
                rahmen_fehler <= not rx_dd;
                gueltig <= '1';
              else
                sr <= rx_dd & sr(8 downto 1);
                bitnr <= bitnr + 1;
              end if;
            else
              teiler <= teiler + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture behav;

-- ===== W09 SPI-Master =====
library ieee; use ieee.std_logic_1164.all;
entity spi_master is
  generic(TEILER : positive := 25);        -- Takte pro halber SCLK-Periode
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    tx_daten   : in  std_logic_vector(7 downto 0);
    rx_daten   : out std_logic_vector(7 downto 0);
    busy       : out std_logic;
    sclk, mosi, cs_n : out std_logic;
    miso       : in  std_logic
    );
end entity spi_master;

architecture behav of spi_master is
  signal aktiv : std_logic;
  signal zaehler : natural range 0 to TEILER - 1;
  signal sclk_i : std_logic;
  signal bitnr : natural range 0 to 7;
  signal sr_tx, sr_rx : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      aktiv <= '0'; zaehler <= 0; sclk_i <= '0'; bitnr <= 0;
      sr_tx <= (others => '0'); sr_rx <= (others => '0');
      rx_daten <= (others => '0');
    else
      if clk'event and clk = '1' then
        if aktiv = '0' then
          if start = '1' then
            aktiv <= '1';
            sr_tx <= tx_daten;
            zaehler <= 0;
            bitnr <= 0;
            sclk_i <= '0';
          end if;
        elsif zaehler = TEILER - 1 then
          zaehler <= 0;
          if sclk_i = '0' then                 -- steigende Flanke: einlesen
            sclk_i <= '1';
            sr_rx <= sr_rx(6 downto 0) & miso;
          else                                  -- fallende Flanke: naechstes Bit
            sclk_i <= '0';
            if bitnr = 7 then
              aktiv <= '0';
              rx_daten <= sr_rx;
            else
              bitnr <= bitnr + 1;
              sr_tx <= sr_tx(6 downto 0) & '0';
            end if;
          end if;
        else
          zaehler <= zaehler + 1;
        end if;
      end if;
    end if;
  end process;
  sclk <= sclk_i;
  mosi <= sr_tx(7);                             -- MSB zuerst
  cs_n <= not aktiv;
  busy <= aktiv;
end architecture behav;

-- ===== W10 ggT als Steuer- und Rechenwerk =====
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity ggt is
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    a, b       : in  std_logic_vector(7 downto 0);   -- beide > 0
    ergebnis   : out std_logic_vector(7 downto 0);
    fertig     : out std_logic
    );
end entity ggt;

architecture behav of ggt is
  type state_type is (idle, rechnen, done);
  signal current_state, next_state : state_type;
  signal x, y : unsigned(7 downto 0);
  signal laden, x_minus_y, y_minus_x : std_logic;   -- Steuersignale
  signal gleich, x_groesser : std_logic;            -- Statussignale
begin
  -- Rechenwerk
  rechenwerk: process(clk, res_n) is
  begin
    if res_n = '0' then
      x <= (others => '0');
      y <= (others => '0');
    else
      if clk'event and clk = '1' then
        if laden = '1' then
          x <= unsigned(a);
          y <= unsigned(b);
        elsif x_minus_y = '1' then
          x <= x - y;
        elsif y_minus_x = '1' then
          y <= y - x;
        end if;
      end if;
    end if;
  end process rechenwerk;
  gleich     <= '1' when x = y else '0';
  x_groesser <= '1' when x > y else '0';
  ergebnis   <= std_logic_vector(x);

  -- Steuerwerk
  transition_function: process(current_state, start, gleich) is
  begin
    next_state <= current_state;
    case current_state is
      when idle | done =>
        if start = '1' then next_state <= rechnen; end if;
      when rechnen =>
        if gleich = '1' then next_state <= done; end if;
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

  output_function: process(current_state, start, gleich, x_groesser) is
  begin
    laden <= '0'; x_minus_y <= '0'; y_minus_x <= '0';
    case current_state is
      when idle | done =>
        laden <= start;
      when rechnen =>
        if gleich = '0' then
          if x_groesser = '1' then x_minus_y <= '1'; else y_minus_x <= '1'; end if;
        end if;
    end case;
  end process output_function;
  fertig <= '1' when current_state = done else '0';
end architecture behav;

-- ===== W11 Sequentieller Multiplizierer =====
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity mult_seq is
  generic(N : positive := 8);
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    a, b       : in  std_logic_vector(N-1 downto 0);
    p          : out std_logic_vector(2*N-1 downto 0);
    fertig     : out std_logic
    );
end entity mult_seq;

architecture behav of mult_seq is
  signal akku   : unsigned(2*N-1 downto 0);
  signal mand   : unsigned(2*N-1 downto 0);   -- a, wird nach links geschoben
  signal mult   : unsigned(N-1 downto 0);     -- b, wird nach rechts geschoben
  signal schritt : natural range 0 to N;
  signal aktiv  : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      akku <= (others => '0'); mand <= (others => '0'); mult <= (others => '0');
      schritt <= 0; aktiv <= '0'; fertig <= '0';
    else
      if clk'event and clk = '1' then
        fertig <= '0';
        if aktiv = '0' then
          if start = '1' then
            akku <= (others => '0');
            mand <= resize(unsigned(a), 2*N);
            mult <= unsigned(b);
            schritt <= 0;
            aktiv <= '1';
          end if;
        else
          if mult(0) = '1' then
            akku <= akku + mand;
          end if;
          mand <= mand(2*N-2 downto 0) & '0';
          mult <= '0' & mult(N-1 downto 1);
          if schritt = N - 1 then
            aktiv <= '0';
            fertig <= '1';
          else
            schritt <= schritt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
  p <= std_logic_vector(akku);
end architecture behav;

-- ===== W12 Frequenzzaehler =====
library ieee; use ieee.std_logic_1164.all;
entity frequenzzaehler is
  generic(TORZEIT : positive := 50_000_000);   -- Takte pro Messung (1 s bei 50 MHz)
  port(
    clk, res_n : in  std_logic;
    sig        : in  std_logic;                -- asynchrones Messsignal
    frequenz   : out natural range 0 to 2**20 - 1;
    neu        : out std_logic                 -- ein Takt nach jeder Messung
    );
end entity frequenzzaehler;

architecture behav of frequenzzaehler is
  signal s1, s2, s3 : std_logic;
  signal tor : natural range 0 to TORZEIT - 1;
  signal anzahl : natural range 0 to 2**20 - 1;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      s1 <= '0'; s2 <= '0'; s3 <= '0';
      tor <= 0; anzahl <= 0; frequenz <= 0; neu <= '0';
    else
      if clk'event and clk = '1' then
        s1 <= sig;                      -- Synchronisierer
        s2 <= s1;
        s3 <= s2;                       -- alter Wert fuer die Flankenerkennung
        neu <= '0';
        if tor = TORZEIT - 1 then
          tor <= 0;
          if s2 = '1' and s3 = '0' then
            frequenz <= anzahl + 1;
          else
            frequenz <= anzahl;
          end if;
          anzahl <= 0;
          neu <= '1';
        else
          tor <= tor + 1;
          if s2 = '1' and s3 = '0' and anzahl < 2**20 - 1 then
            anzahl <= anzahl + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture behav;

-- ===== W13 Round-Robin-Arbiter =====
library ieee; use ieee.std_logic_1164.all;
entity arbiter is
  port(
    clk, res_n : in  std_logic;
    req        : in  std_logic_vector(3 downto 0);
    grant      : out std_logic_vector(3 downto 0)
    );
end entity arbiter;

architecture behav of arbiter is
  signal g      : std_logic_vector(3 downto 0);
  signal letzter : natural range 0 to 3;
begin
  process(clk, res_n) is
    variable idx : natural range 0 to 3;
    variable gefunden : boolean;
  begin
    if res_n = '0' then
      g <= (others => '0');
      letzter <= 3;
    else
      if clk'event and clk = '1' then
        if (g and req) /= "0000" then
          null;                               -- Besitzer fragt noch: behalten
        else
          g <= (others => '0');
          gefunden := false;
          for i in 1 to 4 loop
            idx := (letzter + i) mod 4;
            if not gefunden and req(idx) = '1' then
              g(idx) <= '1';
              letzter <= idx;
              gefunden := true;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;
  grant <= g;
end architecture behav;

-- ===== W14 Mini-Prozessor =====
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity mini_cpu is
  port(
    clk, res_n : in  std_logic;
    pc         : out std_logic_vector(3 downto 0);   -- Adresse ins Programm-ROM
    befehl     : in  std_logic_vector(7 downto 0);   -- opcode(7..4), operand(3..0)
    ausgabe    : out std_logic_vector(7 downto 0);
    aus_gueltig : out std_logic;
    halt       : out std_logic
    );
end entity mini_cpu;

architecture behav of mini_cpu is
  type ram_type is array (0 to 15) of unsigned(7 downto 0);
  signal ram  : ram_type;
  signal akku : unsigned(7 downto 0);
  signal pc_i : unsigned(3 downto 0);
  signal gestoppt : std_logic;
  -- Befehlssatz
  constant LDI  : std_logic_vector(3 downto 0) := "0000";  -- akku := k
  constant ADDI : std_logic_vector(3 downto 0) := "0001";  -- akku := akku + k
  constant SUBI : std_logic_vector(3 downto 0) := "0010";  -- akku := akku - k
  constant LD   : std_logic_vector(3 downto 0) := "0011";  -- akku := ram(k)
  constant ST   : std_logic_vector(3 downto 0) := "0100";  -- ram(k) := akku
  constant ADD  : std_logic_vector(3 downto 0) := "0101";  -- akku := akku + ram(k)
  constant JMP  : std_logic_vector(3 downto 0) := "0110";  -- pc := k
  constant JZ   : std_logic_vector(3 downto 0) := "0111";  -- wenn akku = 0: pc := k
  constant OUTP : std_logic_vector(3 downto 0) := "1000";  -- ausgabe := akku
  constant HLT  : std_logic_vector(3 downto 0) := "1111";  -- anhalten
begin
  process(clk, res_n) is
    variable op : std_logic_vector(3 downto 0);
    variable k  : unsigned(3 downto 0);
  begin
    if res_n = '0' then
      akku <= (others => '0');
      pc_i <= (others => '0');
      gestoppt <= '0';
      aus_gueltig <= '0';
      ausgabe <= (others => '0');
      ram <= (others => (others => '0'));
    else
      if clk'event and clk = '1' then
        aus_gueltig <= '0';
        if gestoppt = '0' then
          op := befehl(7 downto 4);
          k  := unsigned(befehl(3 downto 0));
          pc_i <= pc_i + 1;                     -- Standard: naechster Befehl
          case op is
            when LDI  => akku <= resize(k, 8);
            when ADDI => akku <= akku + k;
            when SUBI => akku <= akku - k;
            when LD   => akku <= ram(to_integer(k));
            when ST   => ram(to_integer(k)) <= akku;
            when ADD  => akku <= akku + ram(to_integer(k));
            when JMP  => pc_i <= k;
            when JZ   => if akku = 0 then pc_i <= k; end if;
            when OUTP => ausgabe <= std_logic_vector(akku); aus_gueltig <= '1';
            when HLT  => gestoppt <= '1'; pc_i <= pc_i;
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;
  pc <= std_logic_vector(pc_i);
  halt <= gestoppt;
end architecture behav;
