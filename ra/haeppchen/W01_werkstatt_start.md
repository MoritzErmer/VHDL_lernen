# W01 · Werkstatt: Programme komplett selbst schreiben

5 min · zurück: [U16](U16_2048_spawn.md) · weiter: [W02](W02_maximum.md)

## Ziel
Wissen, wie du in Block W arbeitest: Aus einer Beschreibung wird ein vollständiges, lauffähiges Unterprogramm.

## Erklärung
In Block W bekommst du nur eine **Schnittstelle** (welche Register rein, was raus) und eine Beschreibung. Das Programm schreibst du komplett selbst.

So gehst du vor:
1. **Erst in C oder Pseudocode** hinschreiben, was passieren soll.
2. **Register festlegen**: Welcher Wert liegt wo? Schreib es als Kommentar oben hin.
3. **Schleifen** nach Muster: Kopf mit Abbruchtest (`beq`/`blt`/…), Rumpf, Zähler/Zeiger weiter, `bra` zurück.
4. **Aufrufe anderer Unterprogramme**: `r31` und benutzte callee-save Register sichern (U04).
5. **Testen**: Im Editor stehen schon Testdaten (`.reg`, `.mem`). Am Rechner läuft der Simulator: `./sim.sh datei.s` im Repo Rechnerarchtektur_Lernen. Alle Musterlösungen liegen mit Testfällen in `ra/am_rechner` im Repo VHDL_lernen.

Calling Convention des IKR RISC II (wie in der praktischen Übung): `r1`–`r9` caller-save, `r10`–`r31` callee-save, Parameter in `r1`, `r2`, …, Rückgabe in `r1`, Stapelzeiger `r30` zeigt auf die zuletzt belegte Position (der Stapel wächst nach unten).

## Aufgabe
Schreibe für `maximum(r1 = Adresse, r2 = Länge)` (W02) zuerst nur den C-Code.

<details><summary>Lösung</summary>

```c
int maximum(int *a, int n) {
    int max = a[0];
    for (int i = 1; i < n; i++)
        if (a[i] > max) max = a[i];
    return max;
}
```
Daraus wird in W02 eine Schleife mit `cmps` und `ble`.
</details>

## Klausur
In der Klausur werden fast immer kleine Unterprogramme verlangt (B06, C03).
