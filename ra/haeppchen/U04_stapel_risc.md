# U04 · Unterprogramm ruft Unterprogramm

12 min · zurück: [U03](U03_streq.md) · weiter: [U05](U05_gol_zelle.md)

## Ziel
Den Stapel im IKR RISC II selbst verwalten: Rücksprungadresse und callee-save Register sichern.

## Erklärung
Beim IKR RISC II legt `bsr` die Rücksprungadresse in `r31`, nicht auf den Stapel. Ruft ein Unterprogramm selbst ein anderes auf, würde `r31` überschrieben. Also:

```ikr
up:  addi r30 := r30,#-2     ; Platz fuer 2 Woerter
     std  (r30,0) := r31     ; Ruecksprungadresse sichern
     std  (r30,1) := r10     ; callee-save Register sichern
     ...                     ; hier darf up andere aufrufen
     ldd  r31 := (r30,0)
     ldd  r10 := (r30,1)
     addi r30 := r30,#2
     jmp  r31
```
Calling Convention des IKR RISC II (wie in der praktischen Übung): `r1`–`r9` caller-save, `r10`–`r31` callee-save, Parameter in `r1`, `r2`, …, Rückgabe in `r1`, Stapelzeiger `r30` zeigt auf die zuletzt belegte Position (der Stapel wächst nach unten).

Aufgabe: `absum(r1 = Adresse, r2 = Länge)` liefert die Summe der Beträge eines Arrays. Für jedes Element ruft es `abs(r1)` auf, das den Betrag in `r1` zurückgibt.

## Aufgabe
Schreibe `absum` und `abs`. Zeiger, Zähler und Summe müssen den Aufruf von `abs` überleben, gehören also in `r10`, `r11`, `r12`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.reg r30 = $1000
.mem $100: 3, -4, 5, -6
```

<details><summary>Lösung</summary>

```ikr
; U04: absum(r1 = Adresse, r2 = Laenge) -> r1 = Summe der Betraege
; ruft fuer jedes Element das Unterprogramm abs auf (verschachtelter Aufruf)
.reg r30 = $1000
.mem $100: 3, -4, 5, -6

absum:    addi r30 := r30,#-4      ; Platz fuer 4 Woerter auf dem Stapel
          std  (r30,0) := r31      ; Ruecksprungadresse sichern
          std  (r30,1) := r10      ; callee-save Register sichern, die wir benutzen
          std  (r30,2) := r11
          std  (r30,3) := r12
          add  r10 := r1,r0        ; Zeiger    (ueberlebt den Aufruf von abs)
          add  r11 := r2,r0        ; Zaehler
          add  r12 := r0,r0        ; Summe
loop:     beq  r11,fertig
          ldd  r1 := (r10,0)       ; Parameter fuer abs
          bsr  abs
          add  r12 := r12,r1
          addi r10 := r10,#1
          addi r11 := r11,#-1
          bra  loop
fertig:   add  r1 := r12,r0
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          ldd  r12 := (r30,3)
          addi r30 := r30,#4
          jmp  r31

abs:      bge  r1,abs_ende         ; Blatt-Unterprogramm: braucht nichts zu sichern
          sub  r1 := r0,r1
abs_ende: jmp  r31
```
`abs` ist ein **Blatt-Unterprogramm** (ruft nichts auf) und nutzt nur `r1`. Es muss nichts sichern. Die Testfälle prüfen auch, dass `r10`–`r12` und `r30` nach dem Aufruf wieder ihre alten Werte haben.
</details>

## Klausur
Calling Convention und Stapel (C01, C02), verschachtelte Aufrufe.
