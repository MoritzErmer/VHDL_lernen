# I04 · Simulationszeiten berechnen

⏱️ 4 min · zurück: [I03](I03_assert_test.md) · weiter: [I05](I05_flanken_race.md)

## 🎯 Ziel
Ausrechnen, **wann** ein Testprozess eine bestimmte
Stelle erreicht.

## 📖 Erklärung
Nur `wait for` lässt Zeit vergehen. Alles andere
(Zuweisungen, Schleifen, `report`) dauert **0 ns**
(höchstens Delta-Zyklen).

Rezept:
1. Zähle, wie oft jedes `wait for` ausgeführt wird.
2. Multipliziere mit der Wartezeit, summiere.

Beispiel: zwei Schleifen je 0 … 7, im Rumpf
`wait for 10 ns;` → 8 · 8 · 10 ns = **640 ns**.
Das abschließende `wait;` wird bei 640 ns
ausgeführt.

## ✍️ Aufgabe
```vhdl
process is
begin
  res_n <= '0'; wait for 15 ns;
  res_n <= '1';
  for i in 0 to 15 loop
    x <= std_logic_vector(to_unsigned(i, 4));
    wait for 20 ns;
  end loop;
  wait for 5 ns;
  report "fertig";
  wait;
end process;
```
Zu welcher Simulationszeit erscheint „fertig“?

<details><summary>✅ Lösung</summary>

15 ns + 16 · 20 ns + 5 ns = 15 + 320 + 5 =
**340 ns**.
</details>

## 🎓 Klausur
**F20 A1 F2a** (640 ns).
