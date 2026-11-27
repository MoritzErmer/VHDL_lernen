# I02 · Die vier wait-Formen

4 min · zurück: [I01](I01_takt_reset.md) · weiter: [I03](I03_assert_test.md)

## Ziel
Den Ablauf eines Testprozesses steuern.

## Erklärung
| Anweisung | wartet … |
|---|---|
| `wait for 10 ns;` | eine feste Zeit |
| `wait until clk = '1';` | bis die Bedingung **nach einem Event** wahr ist |
| `wait on a, b;` | auf ein Event von a oder b (= Sensitivitätsliste) |
| `wait;` | **für immer** (Prozess endet) |

- `wait until rising_edge(clk);` wartet auf die
  **nächste** steigende Flanke.
- `wait until` prüft nur, wenn sich ein Signal der
  Bedingung **ändert** – ist `x` schon `'1'`, wartet
  `wait until x = '1';` trotzdem auf die nächste
  Änderung!
- Ein Prozess ohne Sensitivitätsliste **muss** ein
  `wait` enthalten, sonst hängt die Simulation
  (Endlosschleife zur Zeit 0).

## Aufgabe
Ein Testprozess legt in zwei Schleifen alle
Kombinationen an und endet mit `wait;`.
1. Was passiert, wenn das abschließende `wait;`
   fehlt?
2. Was ist an `process(clk) is begin … wait for
   5 ns; … end process;` falsch?

<details><summary>Lösung</summary>

1. Der Prozess beginnt von vorn → der Test wird
   **unendlich oft wiederholt**.
2. Ein Prozess mit **Sensitivitätsliste** darf **kein
   `wait`** enthalten.
</details>

## Klausur
**F20 A1 F2b** (ohne Wait-Statement), Skript Kap.
3.3.
