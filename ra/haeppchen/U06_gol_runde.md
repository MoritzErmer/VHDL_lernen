# U06 · Game of Life: ganze Runden

15 min · zurück: [U05](U05_gol_zelle.md) · weiter: [U07](U07_pipeline_abh.md)

## Ziel
Zwei verschachtelte Schleifen, Unterprogrammaufrufe und Zeigertausch zu einem vollständigen Programm verbinden.

## Erklärung
`step(r1 = Istfeld, r2 = Folgefeld)` rechnet alle **inneren** Zellen: Zeilen und Spalten 1 bis 4 bei 6 × 6. Nach jeder Zeile springt der Index um 2 weiter, um die beiden Randzellen zu überspringen.

Statt den Folgezustand nach jeder Runde ins Istfeld zu **kopieren** (16 × 16 = 256 Kopien), werden einfach die **Zeiger getauscht**: Runde 1 rechnet von Feld 1 nach Feld 2, Runde 2 von Feld 2 nach Feld 1.

Das Hauptprogramm `start` rechnet vier Generationen. Ein Gleiter ist danach eine Zeile tiefer und eine Spalte weiter rechts.

## Aufgabe
Schreibe `start` und `step`. `zelle` aus U05 darfst du übernehmen. `step` muss `r31` und alle benutzten callee-save Register sichern.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.reg r30 = $1000
.mem $100: 0,0,0,0,0,0, 0,0,1,0,0,0, 0,0,0,1,0,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
.mem $200: 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
```

<details><summary>Lösung</summary>

```ikr
; U06: vier Generationen Game of Life, Ist- und Folgefeld werden abwechselnd vertauscht
; step(r1 = Istfeld, r2 = Folgefeld) rechnet alle inneren Zellen (SIZE = 6, innen 4 x 4)
.reg r30 = $1000
.mem $100: 0,0,0,0,0,0, 0,0,1,0,0,0, 0,0,0,1,0,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
.mem $200: 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0
; nach 4 Generationen ist der Gleiter eine Zeile tiefer und eine Spalte weiter rechts

start:    addi r30 := r30,#-2
          std  (r30,0) := r31
          std  (r30,1) := r15
          addi r15 := r0,#2        ; 2 x (hin und zurueck) = 4 Generationen
runde:    beq  r15,ende
          addi r1 := r0,#$100
          addi r2 := r0,#$200
          bsr  step
          addi r1 := r0,#$200      ; Zeiger tauschen statt kopieren
          addi r2 := r0,#$100
          bsr  step
          addi r15 := r15,#-1
          bra  runde
ende:     ldd  r31 := (r30,0)
          ldd  r15 := (r30,1)
          addi r30 := r30,#2
          jmp  r31

step:     addi r30 := r30,#-6
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          std  (r30,3) := r12
          std  (r30,4) := r13
          std  (r30,5) := r14
          add  r10 := r1,r0        ; Istfeld
          add  r11 := r2,r0        ; Folgefeld
          addi r12 := r0,#7        ; Index der ersten inneren Zelle (SIZE + 1)
          addi r13 := r0,#4        ; Zeilen (SIZE - 2)
zeile:    beq  r13,step_ende
          addi r14 := r0,#4        ; Spalten (SIZE - 2)
spalte:   beq  r14,zeile_ende
          add  r1 := r10,r0
          add  r2 := r11,r0
          add  r3 := r12,r0
          bsr  zelle
          addi r12 := r12,#1
          addi r14 := r14,#-1
          bra  spalte
zeile_ende: addi r12 := r12,#2     ; Randzellen ueberspringen
          addi r13 := r13,#-1
          bra  zeile
step_ende: ldd r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          ldd  r13 := (r30,4)
          ldd  r14 := (r30,5)
          addi r30 := r30,#6
          jmp  r31

zelle:    add  r5 := r1,r3
          ldd  r6 := (r5,-7)
          ldd  r7 := (r5,-6)
          add  r6 := r6,r7
          ldd  r7 := (r5,-5)
          add  r6 := r6,r7
          ldd  r7 := (r5,-1)
          add  r6 := r6,r7
          ldd  r7 := (r5,1)
          add  r6 := r6,r7
          ldd  r7 := (r5,5)
          add  r6 := r6,r7
          ldd  r7 := (r5,6)
          add  r6 := r6,r7
          ldd  r7 := (r5,7)
          add  r6 := r6,r7
          add  r8 := r2,r3
          cmpsi r9 := r6,#3
          beq  r9,lebt
          cmpsi r9 := r6,#2
          beq  r9,bleibt
          std  (r8,0) := r0
          jmp  r31
lebt:     addi r9 := r0,#1
          std  (r8,0) := r9
          jmp  r31
bleibt:   ldd  r9 := (r5,0)
          std  (r8,0) := r9
          jmp  r31
```
Index, Zeilen- und Spaltenzähler stehen in `r12`–`r14`, weil `zelle` die Register `r1`–`r9` verändert. Am Ende prüft der Test, dass der Gleiter an der richtigen Stelle steht.
</details>

## Klausur
Schleifen (B05, B06), Unterprogramme (C01, C02).
