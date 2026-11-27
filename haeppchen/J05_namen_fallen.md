# J05 · Namen und Schreibweise

⏱️ 3 min · zurück: [J04](J04_simulationsarten.md) · weiter: [K01](K01_crc_register.md)

## 🎯 Ziel
Fehler durch Bezeichner vermeiden, die beim
Abschreiben unter Zeitdruck passieren.

## 📖 Erklärung
- VHDL ist **nicht** case-sensitiv: `N` und `n`
  sind **derselbe** Name. Eine Variable `n` in
  einer Funktion verdeckt eine Konstante `N`!
- Bezeichner: Buchstabe am Anfang, dann Buchstaben,
  Ziffern, einzelne `_`. Kein `__`, kein `_` am Ende.
- **Kein Bezeichner darf mit einer Ziffer
  beginnen**: `4_to_1_mux` oder `3_to_8_decoder`
  sind in VHDL **ungültig** (in der Klausur trotzdem
  so benannt – dann als `\4_to_1_mux\` (extended
  identifier) oder umbenennen, z.B. `mux_4_to_1`).
- Reservierte Wörter nicht als Namen: `in`, `out`,
  `signal`, `range`, `next`, `select`, `register`,
  `buffer`, `bus`, `label`, `units` …
- `end architecture behav;` – der Name am Ende muss
  der **Architecture**-Name sein (nicht der der
  Entity).

## ✍️ Aufgabe
Welche Namen sind **ungültig**?
`clk_2`, `2clk`, `next_state`, `next`, `res__n`,
`Q_int`, `register`, `data_`

<details><summary>✅ Lösung</summary>

Ungültig: **`2clk`** (Ziffer am Anfang), **`next`**
(reserviert), **`res__n`** (doppelter Unterstrich),
**`register`** (reserviert), **`data_`** (Unterstrich
am Ende).
Gültig: `clk_2`, `next_state`, `Q_int`.
</details>

## 🎓 Klausur
F20 A2 F1/F3 (Entity-Namen `3_to_8_decoder`,
`4_to_1_mux`). Kleine Fehler, die Punkte kosten.
