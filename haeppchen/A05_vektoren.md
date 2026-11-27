# A05 · Vektoren: Index, Slice, &, others

⏱️ 5 min · zurück: [A04](A04_std_logic.md) · weiter: [A06](A06_fallen_library.md)

## 🎯 Ziel
Mit `std_logic_vector` sicher rechnen – im Kopf.

## 📖 Erklärung
Sei `a : std_logic_vector(7 downto 0)` und
`a = "10110001"`. Links steht **a(7)**, rechts **a(0)**.

| Ausdruck | Name | Ergebnis |
|---|---|---|
| `a(7)` | Index | `'1'` |
| `a(7 downto 4)` | Slice | `"1011"` |
| `a(3 downto 0) & a(7 downto 4)` | Konkatenation | `"00011011"` |
| `a(6 downto 0) & '0'` | links schieben | `"01100010"` |
| `a(0) & a(7 downto 1)` | rechts rotieren | `"11011000"` |
| `not a` | bitweise | `"01001110"` |
| `(others => '0')` | Aggregat | `"00000000"` |
| `x"B1"` | Hex-Literal | `"10110001"` |

- Slice-Richtung muss passen: `a(7 downto 4)` ✔,
  `a(4 to 7)` ✘ bei einem `downto`-Vektor.
- Beide Seiten einer Zuweisung brauchen **gleiche
  Länge**, sonst Fehler.
- `(others => '0')` passt sich automatisch an die
  Länge an → ideal für Resets.
- Aggregat mit Namen: `(7 => '1', others => '0')`
  = `"10000000"`.

## ✍️ Aufgabe
`x = "11111010"` (8 Bit). Was ergibt…
1. `x(7) & x(7 downto 1)`
2. `x & "00"` (Länge?)
3. `x(3 downto 0) & x(3 downto 0)`
4. `(0 => '1', others => '0')` als 4-Bit-Vektor

<details><summary>✅ Lösung</summary>

1. `"11111101"` – **arithmetisch** rechts schieben
   (MSB wird kopiert): −6 / 2 = −3 im Zweierkomplement.
2. `"1111101000"` – 10 Bit, = x · 4.
3. `"10101010"`
4. `"0001"`
</details>

## 🎓 Klausur
Slices und `&` brauchst du in fast jeder
Architecture (z.B. F24 A1 F1b, F20 A1 F6
`ac := ac(ac'left-1 downto 0) & '0';`).

💻 Am Rechner: `am_rechner/L02/vektor_spiele.vhd`
