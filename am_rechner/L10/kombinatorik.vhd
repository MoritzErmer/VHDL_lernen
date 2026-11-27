-- Block L: kombinatorische Schaltplaene, jeweils behav und struct

-- L02: Halbaddierer als Strukturbeschreibung
library ieee; use ieee.std_logic_1164.all;
entity halbaddierer is
  port(
    a, b : in  std_logic;
    s, c : out std_logic
    );
end entity halbaddierer;

architecture behav of halbaddierer is
begin
  s <= a xor b;
  c <= a and b;
end architecture behav;

architecture struct of halbaddierer is
begin
  g1: entity work.xor_2 port map(x0 => a, x1 => b, y => s);
  g2: entity work.and_2 port map(x0 => a, x1 => b, y => c);
end architecture struct;

-- L03/L04: kleines Netz
library ieee; use ieee.std_logic_1164.all;
entity netz is
  port(
    a, b, c : in  std_logic;
    y, z    : out std_logic
    );
end entity netz;

architecture behav of netz is
begin
  y <= (a and b) or (not c);
  z <= b nor c;
end architecture behav;

architecture struct of netz is
  signal h1, h2 : std_logic;
begin
  g1: entity work.and_2 port map(x0 => a, x1 => b, y => h1);
  g2: entity work.not_1 port map(x => c, y => h2);
  g3: entity work.or_2  port map(x0 => h1, x1 => h2, y => y);
  g4: entity work.nor_2 port map(x0 => b, x1 => c, y => z);
end architecture struct;

-- L06: Mehrheitsentscheider 2 aus 3
library ieee; use ieee.std_logic_1164.all;
entity mehrheit is
  port(
    a, b, c : in  std_logic;
    y       : out std_logic
    );
end entity mehrheit;

architecture behav of mehrheit is
begin
  y <= (a and b) or (a and c) or (b and c);
end architecture behav;

architecture struct of mehrheit is
  signal ab, ac, bc : std_logic;
begin
  g1: entity work.and_2 port map(x0 => a, x1 => b, y => ab);
  g2: entity work.and_2 port map(x0 => a, x1 => c, y => ac);
  g3: entity work.and_2 port map(x0 => b, x1 => c, y => bc);
  g4: entity work.or_3  port map(x0 => ab, x1 => ac, x2 => bc, y => y);
end architecture struct;

-- L07: Volladdierer aus zwei Halbaddierern (reine Strukturbeschreibung)
library ieee; use ieee.std_logic_1164.all;
entity volladdierer is
  port(
    a, b, cin : in  std_logic;
    s, cout   : out std_logic
    );
end entity volladdierer;

architecture struct of volladdierer is
  signal s1, c1, c2 : std_logic;
begin
  ha1: entity work.halbaddierer(struct) port map(a => a,  b => b,   s => s1, c => c1);
  ha2: entity work.halbaddierer(struct) port map(a => s1, b => cin, s => s,  c => c2);
  g1:  entity work.or_2 port map(x0 => c1, x1 => c2, y => cout);
end architecture struct;

-- L07 (Szenario 2): 2-Bit-Addierer aus zwei Volladdierern
library ieee; use ieee.std_logic_1164.all;
entity addierer_2bit is
  port(
    a, b : in  std_logic_vector(1 downto 0);
    s    : out std_logic_vector(1 downto 0);
    cout : out std_logic
    );
end entity addierer_2bit;

architecture struct of addierer_2bit is
  signal c1 : std_logic;
begin
  va0: entity work.volladdierer port map(a => a(0), b => b(0), cin => '0', s => s(0), cout => c1);
  va1: entity work.volladdierer port map(a => a(1), b => b(1), cin => c1,  s => s(1), cout => cout);
end architecture struct;

-- L08: 2:1-Multiplexer aus Gattern
library ieee; use ieee.std_logic_1164.all;
entity mux2 is
  port(
    a, b, sel : in  std_logic;
    y         : out std_logic
    );
end entity mux2;

architecture behav of mux2 is
begin
  y <= a when sel = '0' else b;
end architecture behav;

architecture struct of mux2 is
  signal sel_n, ha, hb : std_logic;
begin
  g1: entity work.not_1 port map(x => sel, y => sel_n);
  g2: entity work.and_2 port map(x0 => a, x1 => sel_n, y => ha);
  g3: entity work.and_2 port map(x0 => b, x1 => sel,   y => hb);
  g4: entity work.or_2  port map(x0 => ha, x1 => hb,   y => y);
end architecture struct;

-- L08 (Szenario 2): 4:1-Multiplexer aus drei 2:1-Multiplexern
library ieee; use ieee.std_logic_1164.all;
entity mux4 is
  port(
    d   : in  std_logic_vector(3 downto 0);
    sel : in  std_logic_vector(1 downto 0);
    y   : out std_logic
    );
end entity mux4;

architecture struct of mux4 is
  signal y_lo, y_hi : std_logic;
begin
  m_lo: entity work.mux2(struct) port map(a => d(0), b => d(1), sel => sel(0), y => y_lo);
  m_hi: entity work.mux2(struct) port map(a => d(2), b => d(3), sel => sel(0), y => y_hi);
  m_out: entity work.mux2(struct) port map(a => y_lo, b => y_hi, sel => sel(1), y => y);
end architecture struct;

architecture behav of mux4 is
begin
  with sel select
    y <= d(0) when "00",
         d(1) when "01",
         d(2) when "10",
         d(3) when others;
end architecture behav;

-- L05: Ausgang wird intern weiterverwendet -> internes Signal y_int
library ieee; use ieee.std_logic_1164.all;
entity netz2 is
  port(
    a, b, c : in  std_logic;
    y, z    : out std_logic
    );
end entity netz2;

architecture struct of netz2 is
  signal y_int : std_logic;
begin
  g1: entity work.and_2 port map(x0 => a, x1 => b, y => y_int);
  g2: entity work.or_2  port map(x0 => y_int, x1 => c, y => z);
  y <= y_int;
end architecture struct;
