# I03 · assert und erschöpfender Test

⏱️ 6 min · zurück: [I02](I02_wait.md) · weiter: [I04](I04_simulationszeit.md)

## 🎯 Ziel
Eine Komponente automatisch für **alle** Eingaben
prüfen.

## 📖 Erklärung
```vhdl
assert bedingung
  report "Text" severity error;
```
- Meldung kommt, wenn die Bedingung **falsch** ist.
- `severity`: `note`, `warning`, `error` (Default),
  `failure` (bricht Simulation ab).
- `report "Text";` allein gibt immer aus.
- Zahl als Text: `integer'image(i)`.

Erschöpfender Test eines N-Bit-Multiplizierers:
```vhdl
process is
begin
  for i in 0 to 2**N - 1 loop
    for j in 0 to 2**N - 1 loop
      a <= std_logic_vector(to_unsigned(i, N));
      b <= std_logic_vector(to_unsigned(j, N));
      wait for 10 ns;
      assert to_integer(unsigned(p)) = i * j
        report "Fehler bei " & integer'image(i)
             & " * " & integer'image(j);
    end loop;
  end loop;
  wait;
end process;
```
Das `wait for 10 ns;` **vor** dem `assert` ist
entscheidend: Erst dann haben `a`, `b` und alle davon
abhängigen Signale (`p`) ihre neuen Werte (C04).

## ✍️ Aufgabe
Schreibe den Testprozess für einen Volladdierer
(`a, b, cin` → `s, cout`), der alle 8 Kombinationen
prüft. Tipp: Zähle `i` von 0 bis 7 und nutze die
Bits von `to_unsigned(i, 3)`.

<details><summary>✅ Lösung</summary>

```vhdl
process is
  variable e : unsigned(2 downto 0);
begin
  for i in 0 to 7 loop
    e := to_unsigned(i, 3);
    a <= e(2); b <= e(1); cin <= e(0);
    wait for 10 ns;
    assert to_integer(unsigned'(cout & s))
         = to_integer(e(2 downto 2))
         + to_integer(e(1 downto 1))
         + to_integer(e(0 downto 0))
      report "Fehler bei " & integer'image(i);
  end loop;
  wait;
end process;
```
</details>

## 🎓 Klausur
**F20 A1 F5** (`mult_tester` für allgemeine N).

💻 Am Rechner: `am_rechner/L01/tb_volladdierer.vhd`
