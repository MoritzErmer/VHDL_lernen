# U05 · Game of Life: eine Zelle

12 min · zurück: [U04](U04_stapel_risc.md) · weiter: [U06](U06_gol_runde.md)

## Ziel
Ein zweidimensionales Feld im Speicher ablegen und Nachbarn über feste Abstände adressieren.

## Erklärung
Nach **Praktischer Übung 0** (sinngemäß, dort IKR CISC und 16 × 16): Conway's Game of Life. Jede Zelle ist tot (0) oder lebendig (1). Für den Folgezustand zählen die acht Nachbarn:
- genau **3** lebende Nachbarn: lebt,
- genau **2**: behält ihren Zustand,
- sonst: tot.

Das Feld liegt zeilenweise im Speicher (row-major), hier 6 × 6 Felder, ein Wort pro Zelle. Zelle (Zeile z, Spalte s) liegt bei `Feld + 6·z + s`. Die acht Nachbarn haben deshalb feste Abstände:

| | links | Mitte | rechts |
|---|---|---|---|
| oben | −7 | −6 | −5 |
| gleiche Zeile | −1 | | +1 |
| unten | +5 | +6 | +7 |

Ist- und Folgezustand liegen in **zwei** Feldern. So sieht jede Zelle die alten Werte ihrer Nachbarn, alle Zellen werden „gleichzeitig“ aktualisiert. Randzellen werden nie berechnet.

Schnittstelle: `zelle(r1 = Istfeld, r2 = Folgefeld, r3 = Index)`.

## Aufgabe
Schreibe `zelle`. Tipp: Erst die Adresse der Zelle ausrechnen (`r5 = r1 + r3`), dann alle Nachbarn mit `ldd` und festem Offset laden.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 0,0,0,0,0,0, 0,0,1,0,0,0, 0,0,0,1,0,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
.mem $200: 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9
```

<details><summary>Lösung</summary>

```ikr
; U05: zelle(r1 = Istfeld, r2 = Folgefeld, r3 = Index) - ein Schritt fuer eine Zelle
; Spielfeld 6 x 6 (SIZE = 6), ein Wort pro Zelle, Nachbarn bei -7 -6 -5 -1 +1 +5 +6 +7
; Gleiter: Zeile 1 Spalte 2, Zeile 2 Spalte 3, Zeile 3 Spalten 1-3
.mem $100: 0,0,0,0,0,0, 0,0,1,0,0,0, 0,0,0,1,0,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
.mem $200: 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9, 9,9,9,9,9,9

zelle:    add  r5 := r1,r3         ; Adresse der Zelle im Istfeld
          ldd  r6 := (r5,-7)       ; links oben
          ldd  r7 := (r5,-6)       ; oben
          add  r6 := r6,r7
          ldd  r7 := (r5,-5)       ; rechts oben
          add  r6 := r6,r7
          ldd  r7 := (r5,-1)       ; links
          add  r6 := r6,r7
          ldd  r7 := (r5,1)        ; rechts
          add  r6 := r6,r7
          ldd  r7 := (r5,5)        ; links unten
          add  r6 := r6,r7
          ldd  r7 := (r5,6)        ; unten
          add  r6 := r6,r7
          ldd  r7 := (r5,7)        ; rechts unten
          add  r6 := r6,r7
          add  r8 := r2,r3         ; Adresse der Zelle im Folgefeld
          cmpsi r9 := r6,#3
          beq  r9,lebt             ; genau 3 Nachbarn
          cmpsi r9 := r6,#2
          beq  r9,bleibt           ; genau 2 Nachbarn
          std  (r8,0) := r0        ; sonst tot
          jmp  r31
lebt:     addi r9 := r0,#1
          std  (r8,0) := r9
          jmp  r31
bleibt:   ldd  r9 := (r5,0)
          std  (r8,0) := r9
          jmp  r31
```
`ldd r7 := (r5,-7)` nutzt den 16-Bit-Offset des Ladebefehls: kein eigener Additionsbefehl pro Nachbar nötig. Das ist das Gegenstück zur Adressierungsart „Register indirekt mit Index und Offset“ beim IKR CISC.
</details>

## Klausur
Speicherzugriffe auflisten (B02), Adressrechnung im wortadressierten Speicher (A03).
