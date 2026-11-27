# A04 · std_logic: mehr als 0 und 1

⏱️ 4 min · zurück: [A03](A03_architecture.md) · weiter: [A05](A05_vektoren.md)

## 🎯 Ziel
Die 9 Werte von `std_logic` kennen und wissen,
wofür `'U'`, `'Z'` und `'-'` gut sind.

## 📖 Erklärung
```vhdl
type std_logic is
  ('U','X','0','1','Z','W','L','H','-');
```
| Wert | Bedeutung |
|---|---|
| `'U'` | uninitialisiert (Startwert in Simulation!) |
| `'X'` | Konflikt / unbekannt (z.B. 0 und 1 gleichzeitig getrieben) |
| `'0'`,`'1'` | stark 0 / 1 |
| `'Z'` | hochohmig (Tristate, Bus) |
| `'W'`,`'L'`,`'H'` | schwach unbekannt/0/1 (Pull-up …) |
| `'-'` | **don't care** – „egal“ |

- Einzelbit: `'1'` (einfache Hochkommas),
  Vektor: `"0101"` (doppelte).
- `std_logic` ist ein *aufgelöster* Typ: mehrere
  Treiber werden zu einem Wert verrechnet
  (`'0'` + `'1'` → `'X'`).
- `'-'` ist **kein Joker beim Vergleichen**:
  `x = "1-"` ist nur wahr, wenn x wirklich `"1-"` ist.

## ✍️ Aufgabe
1. Welchen Wert hat ein `std_logic`-Signal zu
   Simulationsbeginn, wenn es keinen Startwert hat?
2. Ein Prioritätsencoder gibt bei `v = '0'` den
   Ausgang `a <= "--"` aus. Welchen Vorteil hat
   `'-'` hier gegenüber `"00"`?

<details><summary>✅ Lösung</summary>

1. `'U'` (der erste Wert der Aufzählung ist immer der
   Default).
2. (a) **Dokumentation**: man sieht, dass der Wert
   nicht ausgewertet werden darf / der Fall
   irrelevant ist. (b) Das **Synthese-Tool hat mehr
   Freiheit** zur Optimierung (kann 0 oder 1 wählen,
   was weniger Gatter ergibt).
</details>

## 🎓 Klausur
Frage 2 ist **Herbst 2019, A1 F3** (3 Punkte).
