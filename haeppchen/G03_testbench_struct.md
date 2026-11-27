# G03 · Testbench als Strukturbeschreibung

⏱️ 6 min · zurück: [G02](G02_component.md) · weiter: [G04](G04_generics.md)

## 🎯 Ziel
Die Klausur-Standardaufgabe „Entity und Architecture
struct der Testbench“ sicher lösen.

## 📖 Erklärung
Eine Testbench hat **keine Ports** – sie ist die
oberste Ebene:
```vhdl
library ieee; use ieee.std_logic_1164.all;

entity counter_tb is
end entity counter_tb;
```
Die Architecture verbindet Takt-/Reset-Generator,
Tester und das zu testende Bauteil (DUT):
```vhdl
use work.all;
architecture struct of counter_tb is
  signal clk, res_n : std_logic;
  signal q          : std_logic_vector(2 downto 0);
begin
  gen: entity clk_res_gen
    port map(clk => clk, res_n => res_n);
  dut: entity counter
    port map(clk => clk, res_n => res_n, q => q);
end architecture struct;
```
Checkliste:
1. Für **jede Verbindungsleitung** ein Signal
   (Name = Portname, wenn in der Aufgabe so gesagt).
2. Jede Komponente aus dem Bild genau **eine** Instanz.
3. Ports einer Komponente, die im Bild nicht
   verbunden sind → weglassen (Eingänge brauchen
   aber einen Wert!).

## ✍️ Aufgabe
Bild: `tester` (Ausgänge `a`, `b`, Eingang `p`),
`mult` (Eingänge `a`, `b`, Ausgang `p`). Beide haben
das Generic `N`. `a`, `b` sind N Bit, `p` ist 2N Bit.
Schreibe die Architecture `struct` zu `mult_tb` mit
einer Konstanten `N = 3` geeigneten Typs.

<details><summary>✅ Lösung</summary>

```vhdl
use work.all;
architecture struct of mult_tb is
  constant N : positive := 3;
  signal a, b : std_logic_vector(N-1 downto 0);
  signal p    : std_logic_vector(2*N-1 downto 0);
begin
  tester: entity mult_tester
    generic map(N => N)
    port map(a => a, b => b, p => p);
  dut: entity mult
    generic map(N => N)
    port map(a => a, b => b, p => p);
end architecture struct;
```
Woran erkennt man eine Testbench? **Die Entity hat
keine Ports.**
</details>

## 🎓 Klausur
**F20 A1 F1**, **F19 A1 F1/F2**, F23 A1 F2,
F21 A2 F2 – praktisch jedes Jahr!
