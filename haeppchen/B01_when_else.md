# B01 · Bedingte Zuweisung: when … else

⏱️ 5 min · zurück: [A06](A06_fallen_library.md) · weiter: [B02](B02_with_select.md)

## 🎯 Ziel
Logik mit Bedingungen ohne Prozess beschreiben.

## 📖 Erklärung
```vhdl
code <= "11" when req(3) = '1' else
        "10" when req(2) = '1' else
        "01" when req(1) = '1' else
        "00";
```
- Bedingungen werden **von oben nach unten**
  geprüft → die erste wahre gewinnt.
  → ideal für **Prioritäten**.
- Der letzte Zweig **ohne** `when` ist Pflicht-Ersatz
  (sonst entsteht Speicherverhalten).
- Eine Bedingung muss vom Typ `boolean` sein:
  `req(3) = '1'` ✔, nur `req(3)` ✘ (in VHDL-93).
- Typischer Trick, um aus `boolean` ein
  `std_logic` zu machen:
  ```vhdl
  gleich <= '1' when a = b else '0';
  ```
- Hardware: eine Kette von 2:1-Multiplexern.

## ✍️ Aufgabe
Zwei 4-Bit-Prioritätsencoder liefern `v_l, a_l`
(untere Hälfte) und `v_h, a_h` (obere Hälfte).
Baue daraus einen 8-Bit-Encoder (`v`, `a(2 downto 0)`),
untere Hälfte hat Vorrang:
- `v` = 1, wenn eine Hälfte gültig ist
- `a(2)` = `not v_l`, wenn v = 1, sonst `'-'`
- `a(1 downto 0)` = `a_l` falls `v_l = '1'`, sonst `a_h`

(3 Zeilen)

<details><summary>✅ Lösung</summary>

```vhdl
v <= v_l or v_h;
a(2) <= not v_l when (v_l or v_h) = '1'
        else '-';
a(1 downto 0) <= a_l when v_l = '1' else a_h;
```
Beachte: `v` ist `out` → nicht lesen! Deshalb wird
`(v_l or v_h)` in Zeile 2 neu berechnet.
</details>

## 🎓 Klausur
**Herbst 2019, A1 F10** (6 Punkte), Grundlage für
den rekursiven Encoder in F11.
