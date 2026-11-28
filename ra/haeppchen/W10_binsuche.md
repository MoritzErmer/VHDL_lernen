# W10 · Binäre Suche

12 min · zurück: [W09](W09_bubblesort.md) · weiter: [W11](W11_fib_rekursiv.md)

## Ziel
Ein Suchintervall halbieren, bis der Wert gefunden ist.

## Erklärung
`binsuche(r1 = Adresse, r2 = Länge, r3 = Wert)` sucht in einem **aufsteigend sortierten** Array und gibt den Index zurück, sonst −1.
- links = 0, rechts = Länge − 1
- solange links ≤ rechts: Mitte = (links + rechts) / 2, vergleichen, eine Hälfte verwerfen.

## Aufgabe
Schreibe `binsuche`. Durch 2 teilen = einmal nach rechts schieben.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: -5, 1, 4, 8, 13, 21, 34, 55
```

<details><summary>Lösung</summary>

```ikr
; V08: binsuche(r1 = Adresse, r2 = Laenge, r3 = Wert) -> r1 = Index oder -1
; das Array ist aufsteigend sortiert
.mem $100: -5, 1, 4, 8, 13, 21, 34, 55

binsuche: add  r4 := r0,r0         ; links
          addi r5 := r2,#-1        ; rechts
loop:     cmps r6 := r4,r5
          bgt  r6,nicht            ; links > rechts: leer
          add  r7 := r4,r5
          asr  r7 := r7            ; Mitte = (links + rechts) / 2
          ldr  r8 := (r1,r7)
          cmps r9 := r8,r3
          beq  r9,gefunden
          blt  r9,rechts_weiter
          addi r5 := r7,#-1        ; Wert liegt links
          bra  loop
rechts_weiter: addi r4 := r7,#1    ; Wert liegt rechts
          bra  loop
gefunden: add  r1 := r7,r0
          jmp  r31
nicht:    addi r1 := r0,#-1
          jmp  r31
```
`asr` teilt durch 2. Weil links und rechts nie negativ werden, ginge auch `lsr`.
</details>

## Klausur
Vergleichen (A06), Sprünge (B03).
