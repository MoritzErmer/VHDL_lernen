# G04 · Generics

⏱️ 6 min · zurück: [G03](G03_testbench_struct.md) · weiter: [G05](G05_for_generate.md)

## 🎯 Ziel
Bausteine mit einstellbarer Breite schreiben und
benutzen.

## 📖 Erklärung
Ein **Generic** ist eine Konstante, die erst beim
**Instanziieren** festgelegt wird:
```vhdl
entity counter is
  generic(
    N : positive
    );
  port(
    clk, res_n : in  std_logic;
    q          : out std_logic_vector(N-1 downto 0)
    );
end entity counter;
```
- `generic(...)` steht **vor** `port(...)`.
- N darf in Port-Breiten und überall in der
  Architecture verwendet werden.
- Default möglich: `N : positive := 8`.
- Beim Instanziieren:
  ```vhdl
  c8: entity work.counter
    generic map(N => 8)
    port map(clk => clk, res_n => res_n, q => q);
  ```
  (Kein `;` zwischen `generic map` und `port map`!)
- Generic vs. Eingang: Ein Generic ist **fest** nach
  der Synthese (nur so viel Hardware wie nötig), ein
  Eingang kann sich zur Laufzeit ändern.

## ✍️ Aufgabe
Schreibe die generische Entity `m_step`: Generic `M`
(Anzahl Bits pro Schritt), Eingänge
`q(4 downto 0)` und `s` mit **M Bit**, Ausgang
`d(4 downto 0)`.

<details><summary>✅ Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;

entity m_step is
  generic(
    M : positive
    );
  port(
    q : in  std_logic_vector(4 downto 0);
    s : in  std_logic_vector(M-1 downto 0);
    d : out std_logic_vector(4 downto 0)
    );
end entity m_step;
```
</details>

## 🎓 Klausur
**F24 A1 F6a**, F21 A1 F4 (Generics statt
Eingänge – was ändert sich?), F21 A2 F1, F23 A1 F6a.
