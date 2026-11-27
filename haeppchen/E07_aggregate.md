# E07 · Positional vs. named association

⏱️ 4 min · zurück: [E06](E06_records.md) · weiter: [E08](E08_attribute.md)

## 🎯 Ziel
Die zwei Arten der Zuordnung erkennen und
begründen – betrifft Aggregate **und** Port Maps.

## 📖 Erklärung
**Positional**: Zuordnung über die **Reihenfolge**.
```vhdl
constant T : rom_type := (x"12", x"34");
u1: entity work.and_2 port map(a, b, y);
```
**Named**: Zuordnung über den **Namen/Index** mit `=>`.
```vhdl
constant T : rom_type := (0 => x"12",
                          1 => x"34");
u1: entity work.and_2
  port map(x0 => a, x1 => b, y => y);
```
- Named ist robuster (Reihenfolge egal, lesbarer).
- Mischen: erst positional, dann named.
- `others =>` ist immer named und steht am Ende.
- Bei positional kann man aus dem Code **nicht**
  ablesen, welcher Index/Name zu welchem Wert gehört.

## ✍️ Aufgabe
```vhdl
constant transition_table : table_type := (
  ( (q1,'*'), (q8,'*'), (q0,'0') ),
  ( (q5,'*'), (q2,'*'), (q0,'1') ),
  ...);
```
1. Positional oder named? Begründe.
2. Warum kann man aus diesem Code die **Werte** von
   `input_type` nicht angeben, nur ihre Anzahl?

<details><summary>✅ Lösung</summary>

1. **Positional**: Es gibt kein `=>`, der Index jedes
   Elements ergibt sich aus seiner Position.
2. Die Eingabewerte werden nirgends **benannt**. Man
   sieht nur, dass jede Zeile **3** Einträge hat →
   `input_type` hat 3 Werte.
</details>

## 🎓 Klausur
**F24 A2 F1b und F1e** – fast wörtlich.
