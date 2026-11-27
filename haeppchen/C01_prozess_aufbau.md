# C01 · Aufbau eines Prozesses

5 min · zurück: [B04](B04_mehrfachtreiber.md) · weiter: [C02](C02_signal_im_prozess.md)

## Ziel
Wissen, wie ein Prozess aufgebaut ist und **wann**
er ausgeführt wird.

## Erklärung
```vhdl
alu: process(a, b, op) is   -- Sensitivitätsliste
  variable tmp : std_logic; -- Deklarationen
begin
  ...                       -- sequenzielle
  ...                       -- Anweisungen
end process alu;
```
- Der Prozess als Ganzes ist **eine** nebenläufige
  Anweisung. **Innen** laufen die Anweisungen
  **sequenziell** (von oben nach unten).
- Ein Prozess ist eine **Endlosschleife**. Die
  Sensitivitätsliste ist eine Abkürzung für ein
  `wait on` am Ende:
  ```vhdl
  process is
  begin
    ...
    wait on a, b, op;
  end process;
  ```
- **Simulationsstart:** *Jeder* Prozess wird
  **einmal ausgeführt** (bis zum ersten `wait`) –
  unabhängig von der Sensitivitätsliste!
- Danach läuft er nur bei einem **Event** (Wertänderung)
  eines Signals der Liste.
- Ein Prozess hat **entweder** eine Sensitivitäts-
  liste **oder** `wait`-Anweisungen – nie beides.
- Das Label (`alu:`) ist optional, hilft aber.

## Aufgabe
Ein Prozess `tp` mit Sensitivitätsliste `(x)` soll
ein Zeichen `x` verarbeiten. Die Testbench legt als
erstes `x <= 'a'` an. Warum würde ohne eine
Freigabe-Bedingung (`if ena then …`) ein `'a'`
**zu viel** verarbeitet?

<details><summary>Lösung</summary>

Zu Simulationsbeginn wird **jeder Prozess einmal
ausgeführt**. `tp` läuft also schon zur Zeit 0 einmal
mit dem Startwert von `x` (dem ersten Wert des
Aufzählungstyps, hier `'a'`) – noch bevor die
Testbench ihr erstes Zeichen anlegt. Damit wird ein
`'a'` zusätzlich verarbeitet.
</details>

## Klausur
**Frühjahr 2024, A2 F8b** – fast wörtlich.
