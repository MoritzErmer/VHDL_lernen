# B02 · Selektive Zuweisung: with … select

⏱️ 5 min · zurück: [B01](B01_when_else.md) · weiter: [B03](B03_versteckter_prozess.md)

## 🎯 Ziel
Multiplexer und Decoder kompakt beschreiben.

## 📖 Erklärung
```vhdl
with sel select
  y <= d0 when "00",
       d1 when "01",
       d2 when "10",
       d3 when others;
```
- Alle Fälle sind **gleichberechtigt** (keine
  Priorität) → Hardware: ein großer Multiplexer.
- Die Auswahl muss **vollständig** sein. Bei
  `std_logic_vector` gibt es auch `'U'`, `'X'`, … →
  **`when others` ist praktisch immer nötig!**
- Mehrere Werte in einem Zweig: `when "00" | "11",`
- Trennzeichen zwischen Zweigen ist `,` (Komma),
  am Ende `;`.

| | `when … else` | `with … select` |
|---|---|---|
| Bedingungen | beliebig, verschiedene Signale | Werte *eines* Ausdrucks |
| Priorität | ja | nein |

## ✍️ Aufgabe
3-zu-8-Decoder: Eingang `x(2 downto 0)`, Ausgang
`y(7 downto 0)`. Genau das Bit `y(x)` ist `'1'`.
Schreibe die Zuweisung mit `with … select`.

<details><summary>✅ Lösung</summary>

```vhdl
with x select
  y <= "00000001" when "000",
       "00000010" when "001",
       "00000100" when "010",
       "00001000" when "011",
       "00010000" when "100",
       "00100000" when "101",
       "01000000" when "110",
       "10000000" when "111",
       "--------" when others;
```
Eleganter (kommt in C07) mit einer Schleife oder:
`y <= (to_integer(unsigned(x)) => '1', others => '0');`
geht leider **nicht** (Aggregat braucht konstante
Indizes) – gute Klausurfalle!
</details>

## 🎓 Klausur
Decoder: **Frühjahr 2020, A2 F1/F2**,
Multiplexer: **F20 A2 F3/F4**.

💻 Am Rechner: `am_rechner/L03/mux4.vhd`, `siebenseg.vhd`
