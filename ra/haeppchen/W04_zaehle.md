# W04 · Zeichen in einem String zählen

7 min · zurück: [W03](W03_strlen.md) · weiter: [W05](W05_umdrehen.md)

## Ziel
Schleife mit Vergleich und Zähler kombinieren.

## Erklärung
`zaehle(r1 = Adresse, r2 = Zeichen)` zählt, wie oft das Zeichen im String vorkommt (z.B. „a“ = 97 in „banana“ → 3).

## Aufgabe
Schreibe `zaehle`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 98, 97, 110, 97, 110, 97, 0   ; "banana"
```

<details><summary>Lösung</summary>

```ikr
; V02 b: zaehle(r1 = Adresse, r2 = Zeichen) -> r1 = wie oft das Zeichen im String vorkommt
.mem $100: 98, 97, 110, 97, 110, 97, 0   ; "banana"

zaehle:   add  r4 := r0,r0
loop:     ldd  r3 := (r1,0)
          beq  r3,fertig
          sub  r5 := r3,r2
          bne  r5,weiter
          addi r4 := r4,#1
weiter:   addi r1 := r1,#1
          bra  loop
fertig:   add  r1 := r4,r0
          jmp  r31
```
Vergleich auf Gleichheit: `sub` und `bne`. Beim IKR RISC II vergleicht ein Sprung immer mit 0.
</details>

## Klausur
Bedingte Sprünge (B03).
