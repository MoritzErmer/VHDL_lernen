# C02 · Signale im Prozess: vorgemerkt, nicht sofort

5 min · zurück: [C01](C01_prozess_aufbau.md) · weiter: [C03](C03_variablen.md)

## Ziel
**Die** wichtigste Regel in VHDL verstehen.

## Erklärung
Eine Signalzuweisung `s <= wert;` im Prozess
**ändert `s` nicht sofort**. Der neue Wert wird nur
**vorgemerkt** (Transaktion). Erst wenn der Prozess
anhält (Ende / `wait`), werden alle vorgemerkten
Werte übernommen.

Daraus folgen 3 Regeln:
1. **Lesen liefert den alten Wert** – im ganzen
   Prozessdurchlauf.
2. **Die letzte Zuweisung gewinnt.**
3. Darum funktionieren **Default-Zuweisungen** am
   Prozessanfang:
   ```vhdl
   y <= '0';           -- Default
   if a = '1' then
     y <= '1';         -- überschreibt ggf.
   end if;
   ```

Klassiker – Tauschen ohne Hilfssignal:
```vhdl
a <= b;
b <= a;   -- liest altes a → Tausch klappt!
```

## Aufgabe
Vor dem Prozessdurchlauf gilt `s = 5` (integer).
```vhdl
s <= 1;
s <= s + 1;
if s = 1 then
  s <= 10;
end if;
```
Welchen Wert hat `s` **nach** dem Durchlauf?

<details><summary>Lösung</summary>

**`s = 6`**.
- `s <= 1;` merkt 1 vor.
- `s <= s + 1;` liest das **alte** s = 5 → merkt 6
  vor (überschreibt die 1).
- `if s = 1` liest ebenfalls 5 → falsch, kein
  Überschreiben.
- Letzte Vormerkung: 6.
</details>

## Klausur
**Frühjahr 2024, A2 F3**: „Spielt die Reihenfolge
der Zuweisungen eine Rolle?“ – Dort ist `state`
eine **Variable**: `y` liest den alten Zustand, also
muss `y` **vor** `state := …` stehen → **ja**.
Bei reinen Signalzuweisungen an *verschiedene*
Signale wäre die Reihenfolge egal.
