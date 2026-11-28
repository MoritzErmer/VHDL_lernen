# S05 · Senso: Synchronisierer – vier Schreibweisen

8 min · zurück: [S04](S04_timer_variabel.md) · weiter: [S06](S06_impulsverkuerzer.md)

## Ziel
Bei Signalen und Variablen im getakteten Prozess sicher sagen, welche Hardware entsteht.

## Erklärung
Taster ändern sich unabhängig vom Takt (asynchron). Direkt in ein getaktetes System geführt, droht **Metastabilität**: Setup- und Hold-Zeit eines Flipflops werden verletzt. Abhilfe ist der **Dual Rank Synchronizer**: zwei Flipflops hintereinander (D05). Der Taster ist low-aktiv (`tx_n`), deshalb wird er beim ersten Flipflop invertiert.

```
tx_n -> not -> FF -> tx_1st -> FF -> tx_sync
```

Vier Versuche, das zu beschreiben (nur der Teil in der Taktflanke):
```vhdl
-- a) Signale, Reihenfolge 1st, sync
tx_1st  <= not tx_n;
tx_sync <= tx_1st;
-- b) Signale, Reihenfolge sync, 1st
tx_sync <= tx_1st;
tx_1st  <= not tx_n;
-- c) Variable, Reihenfolge 1st, sync
tx_1st  := not tx_n;
tx_sync <= tx_1st;
-- d) Variable, Reihenfolge sync, 1st
tx_sync <= tx_1st;
tx_1st  := not tx_n;
```

## Aufgabe
Welche Varianten ergeben wirklich **zwei** Flipflops? Welche würdest du nehmen?

<details><summary>Lösung</summary>

- **a) und b)**: richtig. Signale bekommen ihren neuen Wert erst am Ende des Prozesslaufs (C03). `tx_sync` übernimmt also immer den **alten** Wert von `tx_1st`, die Reihenfolge ist egal.
- **c)**: falsch. Die Variable hat sofort den neuen Wert, `tx_sync` bekommt `not tx_n` direkt. Es bleibt **ein** Flipflop, die Variable wird zu einem Draht.
- **d)**: richtig. `tx_sync` liest die Variable, bevor sie neu beschrieben wird, also den Wert vom letzten Takt. Die Variable muss sich das merken und wird zum Flipflop.

Am besten **a)**: Signale, Reihenfolge wie der Datenfluss. Die Funktion hängt nicht von der Reihenfolge ab, und man sieht sofort zwei Register. d) funktioniert nur wegen der Reihenfolge und geht bei einer Änderung leicht kaputt.
</details>

## Klausur
Signal vs. Variable im getakteten Prozess (C03, D04): typische Klausurfrage, z.B. „Wie viele Flipflops?“.
