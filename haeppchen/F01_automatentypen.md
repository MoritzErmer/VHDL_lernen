# F01 · Mealy, Moore, Medwedew

5 min · zurück: [E08](E08_attribute.md) · weiter: [F02](F02_moore_template.md)

## Ziel
Den Automatentyp an einer Schaltung oder an Code
erkennen und **begründen**.

## Erklärung
Alle drei haben: Zustandsregister + Übergangsfunktion
`next_state = f(x, state)`. Der Unterschied ist der
**Ausgang y**:

| Typ | Ausgang | Merkmal im Code |
|---|---|---|
| **Mealy** | y = g(**x**, state) | Ausgangsprozess liest **x** |
| **Moore** | y = g(state) | Ausgangsprozess liest **nur** den Zustand |
| **Medwedew** | y = Zustand (bzw. Teil davon) | y wird **direkt von Flipflops** getrieben |

Folgen:
- **Mealy** reagiert im selben Takt auf den Eingang,
  braucht oft **weniger Zustände**, kann aber
  Glitches am Ausgang haben.
- **Moore** reagiert einen Takt später, braucht meist
  mehr Zustände.
- **Medwedew**: Ausgänge sind glitchfrei (direkt aus
  FFs) – deshalb oft „am geeignetsten“ für Register
  wie CRC-Rechner oder Zähler.

## Aufgabe
Welcher Typ? Begründe in einem Satz.
1. Ein Register `q`, Ausgang `crc <= q;`
2. `output_function: process(current_state)` mit
   `case current_state is …`
3. Ein Prozess `process(current_state, start)`
   setzt `clr <= '1'`, wenn `start /= '1'`.

<details><summary>Lösung</summary>

1. **Medwedew** – der Ausgang wird direkt von den
   Flipflops (dem Zustand) getrieben.
2. **Moore** – der Ausgang hängt nur vom Zustand ab.
3. **Mealy** – der Ausgang `clr` hängt auch direkt
   vom Eingang `start` ab.
</details>

## Klausur
**F24 A1 F2** (calc_crc → Medwedew), F23 A2 F1,
F21 A2 F3, Skript Kap. 3.4.
