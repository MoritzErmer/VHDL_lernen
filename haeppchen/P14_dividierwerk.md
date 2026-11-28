# P14 · Klausur F22: N-schrittiges Dividierwerk mit valid

10 min · zurück: [P13](P13_divstep.md) · weiter: [P15](P15_oszillator.md)

## Ziel
Eine Prozedur in einem getakteten Prozess einsetzen und mit einem Schieberegister ein Fertig-Signal erzeugen.

## Erklärung
Nach **F22 A1 F9** (sinngemäß): Das Dividierwerk soll **einen** `divstep` pro Takt ausführen.
- `init = '1'` bei einer Taktflanke: `a` und `b` übernehmen (Rest = 0).
- Danach in jedem Takt ein `divstep`.
- Genau **N Takte** nach `init` liegen `q` und `r` an; `valid` ist dann einen Takt lang `'1'`.

`valid` per Schieberegister: `init` wandert durch `sr(0 to N-1)`, `valid` ist die letzte Stufe:
```vhdl
sr    <= init & sr(0 to N-2);
valid <= sr(N-1);
```
Nach der `init`-Flanke steht die `'1'` in `sr(0)`, nach N - 1 weiteren Flanken in `sr(N-1)`, nach der N-ten in `valid`.

Weil `divstep` einen `inout`-Parameter hat, braucht der Prozess eine **Variable** `f`: Register in die Variable kopieren, Prozedur aufrufen, zurückschreiben.

```vhdl
entity div_seq is
  generic(N : positive := 4; M : positive := 4);
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
```

## Aufgabe
Schreibe `architecture behav of div_seq`. `divstep` aus P13 steht im Deklarationsteil (darfst du abkürzen). Signale: `f_reg`, `b_reg`, `sr`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of div_seq is
  -- procedure divstep(...) aus P13

  signal f_reg : unsigned(M+N-1 downto 0);
  signal b_reg : unsigned(M-1 downto 0);
  signal sr    : std_logic_vector(0 to N-1);
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
          f_reg <= unsigned(std_logic_vector'(
                     (M-1 downto 0 => '0') & a));
          b_reg <= unsigned(b);
        else
          f := f_reg;
          divstep(f, b_reg);
          f_reg <= f;
        end if;
        sr    <= init & sr(0 to N-2);
        valid <= sr(N-1);
      end if;
    end if;
  end process;
  q <= std_logic_vector(f_reg(N-1 downto 0));
  r <= std_logic_vector(f_reg(M+N-1 downto N));
end architecture behav;
```
Das Werk rechnet nach dem Ergebnis einfach weiter – `q` und `r` sind nur gültig, solange `valid = '1'` ist. Wer das nicht will, hält das Register mit einem Schrittzähler an.

Hardware: M + N Flipflops für `f_reg`, M für `b_reg`, N + 1 für `sr` und `valid`, aber nur **ein** Subtrahierer – das ist der Vorteil gegenüber dem rein kombinatorischen Werk mit N Subtrahierern.
</details>

## Klausur
**F22 A1 F9/F10** (N- und K-schrittiges Dividierwerk). Simulierbar in `am_rechner/L12/projekte_klausur.vhd`.
