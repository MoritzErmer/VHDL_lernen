# W07 · Division mit Rest

14 min · zurück: [W06](W06_mulu.md) · weiter: [W08](W08_popcount.md)

## Ziel
Die Schulmethode der Division Bit für Bit umsetzen.

## Erklärung
`divu(r1 = a, r2 = b > 0)` liefert `r1 = a / b` und `r2 = a mod b`, vorzeichenlos. 32 Schritte:
1. Rest eine Stelle nach links, oberstes Bit von `a` hinein (`a` dann nach links).
2. Quotient nach links.
3. Ist Rest ≥ b (`cmpu`!), dann Rest − b und Quotientenbit 1.

## Aufgabe
Schreibe `divu`. Das oberste Bit von `a` testest du mit `bge r1,…` (Vorzeichenbit).

<details><summary>Lösung</summary>

```ikr
; V05: divu(r1 = a, r2 = b > 0) -> r1 = a / b, r2 = a mod b (vorzeichenlos, 32 Schritte)

divu:     add  r3 := r0,r0         ; Rest
          add  r4 := r0,r0         ; Quotient
          addi r5 := r0,#32
loop:     beq  r5,fertig
          lsl  r3 := r3            ; Rest nach links ...
          bge  r1,null             ; ... und oberstes Bit von a hinein
          ori  r3 := r3,#1
null:     lsl  r1 := r1
          lsl  r4 := r4
          cmpu r6 := r3,r2
          blt  r6,kleiner          ; Rest < b: Quotientenbit 0
          sub  r3 := r3,r2
          ori  r4 := r4,#1
kleiner:  addi r5 := r5,#-1
          bra  loop
fertig:   add  r1 := r4,r0
          add  r2 := r3,r0
          jmp  r31
```
`cmpu` statt `cmps`: Rest und b sind vorzeichenlos. Mit `cmps` wäre $FFFFFFFF / 16 falsch.
</details>

## Klausur
Gleiche Idee wie das Dividierwerk aus F22 im VHDL-Teil (P13).
