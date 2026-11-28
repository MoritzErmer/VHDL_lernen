# A05 · Vektoren: Index, Slice, &, and, others

7 min · zurück: [A04](A04_std_logic.md) · weiter: [A06](A06_fallen_library.md)

## Ziel
Mit `std_logic_vector` sicher rechnen – im Kopf.

## Erklärung
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

Was jede Zeile macht:
- **Index** `a(7)`: holt **ein** Bit heraus. Ergebnis ist ein `std_logic`, deshalb mit einfachen Hochkommas `'1'`.
- **Slice** `a(7 downto 4)`: schneidet einen Teilvektor heraus, hier die oberen 4 Bits. Ergebnis ist wieder ein Vektor (doppelte Anführungszeichen).
- **`&` (Konkatenation)**: hängt Vektoren oder Bits **aneinander**, links das, was links steht. `"0001" & "1011"` = `"00011011"`. Das Ergebnis ist so lang wie beide Teile zusammen.
- **Achtung:** `&` ist **nicht** das logische UND. Das logische UND heißt in VHDL `and` (siehe unten).
- **Links schieben** `a(6 downto 0) & '0'`: das oberste Bit fällt weg, rechts kommt eine `'0'` dazu. Bei Zahlen ist das „mal 2“.
- **Rechts rotieren** `a(0) & a(7 downto 1)`: das unterste Bit wandert nach ganz links, nichts geht verloren.
- **`not a`**: dreht **jedes** Bit um (aus `1` wird `0` und umgekehrt).
- **Aggregat** `(others => '0')`: setzt alle Bits auf `'0'`, egal wie lang der Vektor ist.
- **Hex-Literal** `x"B1"`: Kurzschreibweise, jede Hex-Ziffer steht für 4 Bit (`B` = `1011`, `1` = `0001`).

Logische Operatoren arbeiten **Bit für Bit** und brauchen zwei gleich lange Vektoren:

| Operator | Bedeutung | `"1100" op "1010"` |
|---|---|---|
| `and` | beide `1` | `"1000"` |
| `or` | mindestens eine `1` | `"1110"` |
| `xor` | genau eine `1` | `"0110"` |
| `nand` | not and | `"0111"` |
| `nor` | not or | `"0001"` |
| `xnor` | gleich | `"1001"` |

- Slice-Richtung muss passen: `a(7 downto 4)` (richtig),
  `a(4 to 7)` (falsch) bei einem `downto`-Vektor.
- Beide Seiten einer Zuweisung brauchen **gleiche
  Länge**, sonst Fehler.
- `(others => '0')` passt sich automatisch an die
  Länge an → ideal für Resets.
- Aggregat mit Namen: `(7 => '1', others => '0')`
  = `"10000000"`.

## Aufgabe
`x = "11111010"` (8 Bit). Was ergibt…
1. `x(7) & x(7 downto 1)`
2. `x & "00"` (Länge?)
3. `x(3 downto 0) & x(3 downto 0)`
4. `(0 => '1', others => '0')` als 4-Bit-Vektor
5. `x(7 downto 4) and x(3 downto 0)`
6. Was ist der Unterschied zwischen `"11" & "01"` und `"11" and "01"`?

<details><summary>Lösung</summary>

1. `"11111101"` – **arithmetisch** rechts schieben
   (MSB wird kopiert): −6 / 2 = −3 im Zweierkomplement.
2. `"1111101000"` – 10 Bit, = x · 4.
3. `"10101010"`
4. `"0001"`
5. `"1111" and "1010"` = `"1010"`
6. `&` hängt an: `"1101"` (4 Bit). `and` verknüpft Bit für Bit: `"01"` (2 Bit).
</details>

## Klausur
Slices und `&` brauchst du in fast jeder
Architecture (z.B. F24 A1 F1b, F20 A1 F6
`ac := ac(ac'left-1 downto 0) & '0';`).

Am Rechner: `am_rechner/L02/vektor_spiele.vhd`
