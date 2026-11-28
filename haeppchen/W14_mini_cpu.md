# W14 · Mini-Prozessor

30 min · zurück: [W13](W13_arbiter.md) · weiter: [W15](W15_testbench_ggt.md)

## Ziel
Einen kleinen Prozessor mit Akkumulator, Datenspeicher und Sprungbefehlen komplett selbst bauen.

## Erklärung
Ein 8-Bit-Akkumulator-Prozessor. Das Programm steht in einem externen ROM: Der Prozessor gibt die Adresse `pc` aus und bekommt den Befehl `befehl` zurück. Jeder Befehl dauert **einen Takt**.

Befehlsformat: `befehl(7 downto 4)` = Opcode, `befehl(3 downto 0)` = Operand `k`.

| Opcode | Name | Wirkung |
|---|---|---|
| 0000 | LDI k | akku := k |
| 0001 | ADDI k | akku := akku + k |
| 0010 | SUBI k | akku := akku - k |
| 0011 | LD k | akku := ram(k) |
| 0100 | ST k | ram(k) := akku |
| 0101 | ADD k | akku := akku + ram(k) |
| 0110 | JMP k | pc := k |
| 0111 | JZ k | wenn akku = 0: pc := k |
| 1000 | OUT | ausgabe := akku, ein Takt aus_gueltig |
| 1111 | HLT | anhalten |

Sonst: `pc := pc + 1`. Der Datenspeicher `ram` hat 16 Wörter à 8 Bit.

Ports: `clk`, `res_n`, `pc : out std_logic_vector(3 downto 0)`, `befehl : in std_logic_vector(7 downto 0)`, `ausgabe : out std_logic_vector(7 downto 0)`, `aus_gueltig`, `halt : out std_logic`.

## Aufgabe
Schreibe Entity `mini_cpu` und Architecture `behav`. Die Opcodes als Konstanten, die Ausführung als `case` in einem getakteten Prozess.

<details><summary>Lösung</summary>

```vhdl
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
```
Trick: Zuerst `pc_i <= pc_i + 1;` als Default, Sprünge überschreiben ihn (letzte Zuweisung gewinnt, C02). Das Testprogramm in `am_rechner/L14/tb_werkstatt.vhd` zählt von 5 auf 1 herunter, gibt jede Zahl aus und am Ende die Summe 15.
</details>

## Klausur
ROM und RAM (E05, M08), großer `case` (C05), Rechnerarchitektur: Akkumulator-Maschine.
