# W09 · Bubble Sort

15 min · zurück: [W08](W08_popcount.md) · weiter: [W10](W10_binsuche.md)

## Ziel
Zwei verschachtelte Schleifen mit Tausch und vorzeitigem Abbruch.

## Erklärung
`bubblesort(r1 = Adresse, r2 = Länge)` sortiert aufsteigend (mit Vorzeichen):
- Ein Durchlauf vergleicht benachbarte Elemente und tauscht, wenn das linke größer ist. Danach steht das größte ganz hinten.
- Jeder weitere Durchlauf braucht einen Vergleich weniger.
- Wurde in einem Durchlauf nichts getauscht, ist das Array sortiert: abbrechen.

## Aufgabe
Schreibe `bubblesort`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 5, -3, 9, 0, 9, 2, -8
```

<details><summary>Lösung</summary>

```ikr
; V07: bubblesort(r1 = Adresse, r2 = Laenge): aufsteigend sortieren (mit Vorzeichen)
.mem $100: 5, -3, 9, 0, 9, 2, -8

bubblesort: addi r3 := r2,#-1      ; Anzahl Vergleiche im aktuellen Durchlauf
aussen:   ble  r3,fertig
          add  r4 := r1,r0         ; Zeiger
          add  r5 := r3,r0         ; Zaehler innen
          add  r9 := r0,r0         ; getauscht?
innen:    beq  r5,innen_ende
          ldd  r6 := (r4,0)
          ldd  r7 := (r4,1)
          cmps r8 := r6,r7
          ble  r8,kein_tausch
          std  (r4,0) := r7
          std  (r4,1) := r6
          addi r9 := r0,#1
kein_tausch: addi r4 := r4,#1
          addi r5 := r5,#-1
          bra  innen
innen_ende: beq r9,fertig          ; nichts getauscht: schon sortiert
          addi r3 := r3,#-1        ; das Groesste steht jetzt hinten
          bra  aussen
fertig:   jmp  r31
```
`ldd r7 := (r4,1)` lädt den rechten Nachbarn mit Offset 1. Kein zweiter Zeiger nötig.
</details>

## Klausur
Schleifen und Speicherzugriffe (B02, B05).
