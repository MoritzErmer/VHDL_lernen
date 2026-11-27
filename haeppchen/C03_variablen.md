# C03 · Variablen: sofort gültig

⏱️ 5 min · zurück: [C02](C02_signal_im_prozess.md) · weiter: [C04](C04_delta_zyklen.md)

## 🎯 Ziel
Signal vs. Variable sicher unterscheiden.

## 📖 Erklärung
```vhdl
process(a, b) is
  variable v : integer;   -- nur hier sichtbar
begin
  v := a + b;             -- := statt <=
  y <= v * 2;             -- liest NEUEN Wert
end process;
```

| | Signal | Variable |
|---|---|---|
| Zuweisung | `<=` | `:=` |
| wird gültig | nach Prozess-Pause | **sofort** |
| deklariert in | Architecture (vor `begin`) | Prozess (vor `begin`) |
| sichtbar | überall in der Architecture | nur im Prozess |
| Hardware | Leitung oder Flipflop | Zwischenergebnis (oder FF, s. D04) |

Variablen **behalten ihren Wert** zwischen zwei
Prozessdurchläufen! Deshalb bei Zwischenergebnissen
immer am Anfang neu setzen.

## ✍️ Aufgabe
Vorher: `s = 0`, `v = 0`.
```vhdl
v := 1;
s <= 1;
v := v + 1;
s <= s + 1;
report "A: v=" & integer'image(v) &
       " s=" & integer'image(s);
wait for 0 ns;
report "B: v=" & integer'image(v) &
       " s=" & integer'image(s);
```
Was wird bei A und B ausgegeben?

<details><summary>✅ Lösung</summary>

- **A: v=2 s=0** – v sofort 1, dann 2. s hat noch den
  alten Wert 0.
- **B: v=2 s=1** – durch `wait` wird s aktualisiert.
  Vorgemerkt war zuletzt `s + 1` mit altem s = 0 → 1.

💻 Genau diese Testbench zum Ausprobieren:
`am_rechner/L04/tb_signal_vs_variable.vhd`
</details>

## 🎓 Klausur
Werte von Variablen/Signalen in Tabellen eintragen
kommt sehr oft: F19 A1 F7, F23 A2 F3, F22 A1 F7.
