# W11 · Multiplizierer mit Schieben und Addieren

15 min · zurück: [W10](W10_ggt.md) · weiter: [W12](W12_frequenzzaehler.md)

## Ziel
Die Schulmethode der Multiplikation als sequentielle Schaltung schreiben.

## Erklärung
Multiplikation wie auf Papier, Bit für Bit von `b`:
- Ist das unterste Bit von `b` gleich `'1'`, wird `a` zum Akku addiert.
- Dann `a` eine Stelle nach links, `b` eine nach rechts schieben.
- Nach N Schritten steht das Produkt im Akku.

Ports und Generics:
- Generic `N : positive := 8`
- `clk`, `res_n`, `start : in std_logic`, `a`, `b : in std_logic_vector(N-1 downto 0)`
- `p : out std_logic_vector(2*N-1 downto 0)`, `fertig : out std_logic` (ein Takt)

Register: `akku` (2N Bit), `mand` (a auf 2N Bit erweitert), `mult` (b), Schrittzähler, `aktiv`.

## Aufgabe
Schreibe Entity `mult_seq` und Architecture `behav` mit einem getakteten Prozess.

<details><summary>Lösung</summary>

```vhdl
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
```
`resize(unsigned(a), 2*N)` erweitert `a` mit Nullen auf die volle Breite. Ein Addierer und N Takte statt N Addierer in einem Takt – das ist der Tausch Fläche gegen Zeit (J03).
</details>

## Klausur
Multiplizierer (F20, K04), Hardware-Aufwand (J03).
