# I05 · Stimuli nicht auf die Flanke legen

5 min · zurück: [I04](I04_simulationszeit.md) · weiter: [I06](I06_event_transaction.md)

## Ziel
Eine typische Testbench-Falle erkennen: Eingang und
Takt ändern sich gleichzeitig.

## Erklärung
```vhdl
-- in der Testbench
ser_in <= '1';
clk    <= '1';             -- gleiches Delta!
wait for 5 ns;
-- im Design
z(N) <= ser_in;            -- 1 Delta später
-- Flipflop liest z(N) bei clk'event
```
Ablauf:
- Delta 1: `ser_in` und `clk` werden gleichzeitig
  `'1'`. Das FF sieht die Flanke und liest `z(N)` –
  das hat aber noch den **alten** Wert.
- Delta 2: erst jetzt bekommt `z(N)` den neuen Wert.

→ Das FF speichert den **falschen** Wert. In echter
Hardware wäre das eine Setup-Zeit-Verletzung.

**Regel:** Eingänge immer **mit Abstand** zur aktiven
Flanke ändern, z.B. bei der **fallenden** Flanke
oder ein paar ns vorher:
```vhdl
wait until clk = '0';   -- fallende Flanke
ser_in <= '1';          -- sicher
```

## Aufgabe
Warum funktioniert diese Testbench, obwohl auch hier
`d` und `clk` im selben Prozess gesetzt werden?
```vhdl
d   <= '1';
wait for 2 ns;
clk <= '1';
```

<details><summary>Lösung</summary>

Zwischen den beiden Zuweisungen vergehen **2 ns**.
Bis dahin sind alle Delta-Zyklen abgearbeitet und
jedes von `d` abhängige Signal hat seinen neuen Wert.
Die Flanke kommt danach.
</details>

## Klausur
Hintergrund für alle Fragen „Welchen Wert hat … nach
der Flanke?“ und für Metastabilität (D05, Skript
Kap. 6.1).
