# A03 · Die Architecture: Schaltbild → Code

5 min · zurück: [A02](A02_entity.md) · weiter: [A04](A04_std_logic.md)

## Ziel
Ein kombinatorisches Schaltbild direkt als
nebenläufige Zuweisungen hinschreiben.

## Erklärung
```vhdl
architecture behav of halbaddierer is
begin
  s <= a xor b;
  c <= a and b;
end architecture behav;
```
- `architecture <name> of <entity> is`
- zwischen `is` und `begin`: **Deklarationen**
  (interne Signale, Konstanten, Typen)
- zwischen `begin` und `end`: **Anweisungen**
- übliche Namen: `behav` (Verhalten), `struct`
  (nur Instanzen), `mixed` (beides)

Operatoren für `std_logic`: `not and or nand nor
xor xnor`. Achtung: `and`/`or` haben **gleichen Rang**
→ immer klammern: `(a and b) or c`.

Mehrere Bits auf einmal geht mit Slices:
`d(4 downto 3) <= q(3 downto 2);`

## Aufgabe
Entity `single_step`: Eingänge `q(4 downto 0)`, `s`;
Ausgang `d(4 downto 0)`. Das Schaltbild sagt:
- d4 = q3, d3 = q2
- d2 = q4 ⊕ s ⊕ q1
- d1 = q0
- d0 = q4 ⊕ s

Schreibe `architecture behav` (d4/d3 in **einer** Zeile).

<details><summary>Lösung</summary>

```vhdl
architecture behav of single_step is
begin
  d(4 downto 3) <= q(3 downto 2);
  d(2)          <= q(4) xor s xor q(1);
  d(1)          <= q(0);
  d(0)          <= q(4) xor s;
end architecture behav;
```
Das ist ein Schritt einer CRC-Berechnung
(Schieberegister mit XOR-Rückkopplung).
</details>

## Klausur
**Frühjahr 2024, A1 F1b** – genau diese Aufgabe.
