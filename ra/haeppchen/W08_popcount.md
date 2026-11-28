# W08 · Bits zählen und Parität

7 min · zurück: [W07](W07_divu.md) · weiter: [W09](W09_bubblesort.md)

## Ziel
Ein Wort Bit für Bit auswerten.

## Erklärung
`popcount(r1)` liefert in `r1` die Anzahl der gesetzten Bits und in `r2` die Parität (1, wenn die Anzahl ungerade ist).

## Aufgabe
Schreibe `popcount`. Abbrechen, sobald keine Einsen mehr übrig sind.

<details><summary>Lösung</summary>

```ikr
; V06: popcount(r1) -> r1 = Anzahl gesetzter Bits, r2 = Paritaet (1 bei ungerader Anzahl)

popcount: add  r3 := r0,r0
loop:     beq  r1,fertig           ; keine Einsen mehr: fertig (spart Durchlaeufe)
          and0i r4 := r1,#1
          add  r3 := r3,r4
          lsr  r1 := r1            ; logisch: von links kommt 0
          bra  loop
fertig:   add  r1 := r3,r0
          and0i r2 := r3,#1
          jmp  r31
```
`lsr` (logisch) ist wichtig: Mit `asr` würde bei negativen Zahlen von links immer wieder eine 1 nachkommen, die Schleife endet nie.
</details>

## Klausur
Schieben (A06).
