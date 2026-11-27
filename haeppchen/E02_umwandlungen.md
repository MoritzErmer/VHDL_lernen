# E02 · Umwandlungen mit numeric_std

⏱️ 6 min · zurück: [E01](E01_integer_subtypes.md) · weiter: [E03](E03_aufzaehlungstypen.md)

## 🎯 Ziel
Zwischen `std_logic_vector`, `unsigned`/`signed` und
`integer` sicher umwandeln.

## 📖 Erklärung
```
                 unsigned(v)
std_logic_vector ───────────▶ unsigned
                 ◀───────────
           std_logic_vector(u)

         to_integer(u)
unsigned ────────────▶ integer
         ◀────────────
      to_unsigned(i, N)
```
(genauso mit `signed` / `to_signed(i, N)`)

- `unsigned(...)`, `std_logic_vector(...)` sind
  **Typumwandlungen** (gleiche Bits, andere Deutung).
- `to_integer`, `to_unsigned` sind **Funktionen**;
  `to_unsigned` braucht die **Bitbreite** N.
- Direkt `slv → integer` gibt es **nicht**:
  `to_integer(unsigned(v))`.
- Rechnen nur mit `unsigned`/`signed`/`integer`,
  nicht mit `std_logic_vector`.
- `resize(u, N)` verlängert/kürzt (bei `signed`
  mit Vorzeichenerweiterung).
- Typqualifikation (bei Mehrdeutigkeit):
  `unsigned'('0' & a)` – mit Hochkomma!

Gleiche Bits, verschiedene Werte:
`"11110000"` → unsigned 240, signed −16.

## ✍️ Aufgabe
`a`, `b`: `std_logic_vector(7 downto 0)`,
`i`: `integer range 0 to 255`. Schreibe:
1. `i` = Wert von `a` (vorzeichenlos)
2. `a` = Wert von `i`
3. `s : std_logic_vector(8 downto 0)` = a + b mit
   Übertrag
4. Ist `a + 1` mit `a : std_logic_vector` erlaubt?

<details><summary>✅ Lösung</summary>

```vhdl
i <= to_integer(unsigned(a));
a <= std_logic_vector(to_unsigned(i, 8));
s <= std_logic_vector(resize(unsigned(a), 9)
                    + resize(unsigned(b), 9));
```
4. **Nein** (mit `numeric_std`): für
   `std_logic_vector` ist kein `+` definiert. Erst
   `unsigned(a) + 1`.
</details>

## 🎓 Klausur
In fast jeder Architecture nötig, z.B. **H19 A1 F8**
(`to_unsigned(i, 3)`), **F24 A1 F12**
(`r(to_integer(unsigned(s)))`), F20 A1 F5.

💻 Am Rechner: `am_rechner/L02/rechner_8bit.vhd`
