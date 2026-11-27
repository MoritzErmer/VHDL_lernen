# E03 · Aufzählungstypen

⏱️ 5 min · zurück: [E02](E02_umwandlungen.md) · weiter: [E04](E04_arrays.md)

## 🎯 Ziel
Eigene Typen mit benannten Werten definieren –
Grundlage für Automaten und Zeichenketten-Aufgaben.

## 📖 Erklärung
```vhdl
type state_type  is (idle, q1, q2, q3);
type input_type  is (kurz, lang, pause);
type output_type is ('s', 'o', 'x', '-');
```
- Werte sind **Bezeichner** oder **Zeichenliterale**
  (`'x'`) – auch gemischt möglich.
- Auch die Standardtypen sind so definiert:
  `type bit is ('0', '1');`
  `type boolean is (false, true);`
- **Startwert** eines Signals ohne Initialwert =
  **erster** Wert der Liste (`idle`, `kurz`, `'s'`).
- Die Werte sind **geordnet**: `q1 < q3`, Bereiche
  in `case`: `when q1 to q3 =>`.
- Die Synthese wählt die Codierung (binär, one-hot)
  selbst.
- Für **Ports** muss der Typ in einem **Package**
  stehen (Block H), weil die Entity ihn kennen muss.

## ✍️ Aufgabe
In einem Code kommen nur diese Ausdrücke vor:
`y <= '*';` `y <= '0';` `y <= '1';` (`y` ist vom
Typ `output_type`).
1. Gib eine mögliche Definition von `output_type` an.
2. Welchen Wert hat `y` zu Simulationsbeginn mit
   deiner Definition?
3. Warum ist `type t is ('0', '1', '0');` falsch?

<details><summary>✅ Lösung</summary>

```vhdl
type output_type is ('*', '0', '1');
```
2. `'*'` – der erste Wert.
3. Jeder Wert darf nur **einmal** vorkommen.
</details>

## 🎓 Klausur
**F24 A2 F1c** (output_type angeben), F24 A2 F1d/e,
Morsedetektor im Skript (Kap. 3.4).
