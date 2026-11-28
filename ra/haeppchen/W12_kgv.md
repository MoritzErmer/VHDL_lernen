# W12 · kgV aus drei Unterprogrammen

18 min · zurück: [W11](W11_fib_rekursiv.md) · weiter: [W13](W13_add64.md)

## Ziel
Mehrere eigene Unterprogramme zu einem neuen kombinieren.

## Erklärung
`kgv(r1 = a, r2 = b)` liefert das kleinste gemeinsame Vielfache: kgV(a, b) = a / ggT(a, b) · b.

Unterprogramme:
- `ggt(r1, r2)` mit dem Subtraktionsverfahren (wie W10 im VHDL-Teil),
- `divu` aus W07,
- `mulu` aus W06.

`a` und `b` müssen die Aufrufe überleben.

## Aufgabe
Schreibe `kgv` und `ggt`. `divu` und `mulu` hängst du an.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.reg r30 = $1000
```

<details><summary>Lösung</summary>

```ikr
; V10: kgv(r1 = a, r2 = b) -> r1 = kleinstes gemeinsames Vielfaches = a / ggt(a, b) * b
; nutzt ggt, divu und mulu als Unterprogramme
.reg r30 = $1000

kgv:      addi r30 := r30,#-3
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          add  r10 := r1,r0        ; a
          add  r11 := r2,r0        ; b
          bsr  ggt                 ; r1 = ggt(a, b)
          add  r2 := r1,r0
          add  r1 := r10,r0
          bsr  divu                ; r1 = a / ggt
          add  r2 := r11,r0
          bsr  mulu                ; r1 = (a / ggt) * b
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          addi r30 := r30,#3
          jmp  r31

; ggt(r1, r2 > 0) -> r1, Subtraktionsverfahren
ggt:      sub  r3 := r1,r2
          beq  r3,ggt_ende
          blt  r3,ggt_b
          add  r1 := r3,r0         ; a := a - b
          bra  ggt
ggt_b:    sub  r2 := r2,r1         ; b := b - a
          bra  ggt
ggt_ende: jmp  r31

divu:     add  r3 := r0,r0
          add  r4 := r0,r0
          addi r5 := r0,#32
d_loop:   beq  r5,d_fertig
          lsl  r3 := r3
          bge  r1,d_null
          ori  r3 := r3,#1
d_null:   lsl  r1 := r1
          lsl  r4 := r4
          cmpu r6 := r3,r2
          blt  r6,d_klein
          sub  r3 := r3,r2
          ori  r4 := r4,#1
d_klein:  addi r5 := r5,#-1
          bra  d_loop
d_fertig: add  r1 := r4,r0
          add  r2 := r3,r0
          jmp  r31

mulu:     add  r3 := r0,r0
m_loop:   beq  r2,m_fertig
          and0i r4 := r2,#1
          beq  r4,m_schieben
          add  r3 := r3,r1
m_schieben: lsl r1 := r1
          lsr  r2 := r2
          bra  m_loop
m_fertig: add  r1 := r3,r0
          jmp  r31
```
Erst teilen, dann multiplizieren: So bleibt das Zwischenergebnis klein und läuft nicht so schnell über.
</details>

## Klausur
Unterprogramme und Konvention (C01, C02).
