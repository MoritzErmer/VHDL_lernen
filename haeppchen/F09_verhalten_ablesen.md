# F09 · Verhalten aus Code ablesen

6 min · zurück: [F08](F08_entwurf_garagentor.md) · weiter: [G01](G01_instanziierung.md)

## Ziel
Eine Eingabefolge durch einen gegebenen Automaten
„durchspielen“ und die Ausgabefolge angeben.

## Erklärung
Vorgehen:
1. Tabelle anlegen: Takt | Zustand | Eingabe |
   Ausgabe | Folgezustand
2. Mit dem **Reset-Zustand** starten.
3. **Mealy**: Ausgabe aus (Zustand, Eingabe).
   **Moore**: Ausgabe nur aus Zustand.
4. Folgezustand wird Zustand der nächsten Zeile.

## Aufgabe
Mealy-Detektor aus F03 (Zustände start, s1, s10;
`y = 1` bei s10 und x = 1). Start in `start`.
Eingabefolge x: `1 0 1 0 1 1 0 1`
Gib die Ausgabefolge y an.

<details><summary>Lösung</summary>

| Takt | Zustand | x | y | nächster |
|---|---|---|---|---|
| 1 | start | 1 | 0 | s1 |
| 2 | s1 | 0 | 0 | s10 |
| 3 | s10 | 1 | **1** | s1 |
| 4 | s1 | 0 | 0 | s10 |
| 5 | s10 | 1 | **1** | s1 |
| 6 | s1 | 1 | 0 | s1 |
| 7 | s1 | 0 | 0 | s10 |
| 8 | s10 | 1 | **1** | s1 |

**y = 0 0 1 0 1 0 0 1** (überlappend erkannt).
</details>

## Klausur
**F24 A2 F6** (Ausgabefolge zu Tester-Sequenz),
F24 A2 F5 (Diagramm aus Tabelle zeichnen), F24 A2 F7.
