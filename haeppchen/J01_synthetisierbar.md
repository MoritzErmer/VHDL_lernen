# J01 · Synthetisierbar oder nicht?

⏱️ 5 min · zurück: [I06](I06_event_transaction.md) · weiter: [J02](J02_kritischer_pfad.md)

## 🎯 Ziel
Schnell erkennen, welcher Code nur für die
Simulation taugt.

## 📖 Erklärung
**Nicht synthetisierbar** (nur Simulation):
- `wait for …` und `after …` (Zeitangaben)
- `'transaction`, `now`
- Dateizugriffe (`textio`), `report`/`assert`
  (werden ignoriert)
- Schleifen mit **variablen** Grenzen
- Prozesse, die auf **beide** Flanken oder auf
  mehrere Takte reagieren
- Rekursion **ohne** konstanten Abbruch

**Synthetisierbar** (Auswahl):
- Kombinatorische Prozesse, nebenläufige Zuweisungen
- Getaktete Prozesse (eine Flanke, optional
  asynchroner Reset)
- `for`-Schleifen mit **konstanten** Grenzen
- `generate`, Generics, Funktionen, Konstanten-
  Arrays (ROM)
- Initialwerte von Signalen: nur teilweise
  (FPGA ja, ASIC nein) → besser Reset benutzen

## ✍️ Aufgabe
Synthetisierbar? Ja/Nein + Grund.
1. `y <= a and b after 2 ns;`
2. `for i in 0 to n loop` (`n` ist ein Signal)
3. `process(x'transaction)`
4. `for i in 0 to N-1 loop` (`N` ist ein Generic)
5. Ein Prozess mit `wait until rising_edge(clk);`
   als **einzigem** wait am Anfang

<details><summary>✅ Lösung</summary>

1. **Teilweise**: Das `after 2 ns` wird ignoriert
   (Warnung), das UND wird synthetisiert.
   Verzögerungen kann man nicht vorgeben.
2. **Nein** – variable Grenze, die Hardware müsste
   ihre Größe zur Laufzeit ändern.
3. **Nein** – Transactions sind in Hardware nicht
   erkennbar.
4. **Ja** – Generic ist eine Konstante.
5. **Ja** – entspricht einem getakteten Prozess
   (ohne asynchronen Reset).
</details>

## 🎓 Klausur
**F24 A2 F4**, **F19 A1 F3c** (`wait for`),
F24 A2 F9 („synthetisierbar angeben“).
