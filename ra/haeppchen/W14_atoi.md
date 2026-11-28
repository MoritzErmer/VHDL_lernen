# W14 · Text in Zahl umwandeln

12 min · zurück: [W13](W13_add64.md) · weiter: [W15](W15_sieb.md)

## Ziel
Ziffern eines Strings in eine Zahl umrechnen, ohne Multiplizierbefehl.

## Erklärung
`atoi(r1 = Adresse)` wandelt einen String aus Ziffern in eine Zahl um, optional mit „-“ davor.
- ASCII: '0' = 48 … '9' = 57, '-' = 45.
- Für jede Ziffer: Ergebnis = Ergebnis · 10 + Ziffernwert.
- Mal 10 ohne Multiplikation: x · 10 = x · 8 + x · 2.

## Aufgabe
Schreibe `atoi`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 49, 50, 51, 0           ; "123"
.mem $110: 45, 52, 48, 55, 0       ; "-407"
.mem $120: 48, 0                   ; "0"
```

<details><summary>Lösung</summary>

```ikr
; V12: atoi(r1 = Adresse) -> r1 = Zahl aus einem String mit Ziffern, optional mit '-' davor
; ASCII: '0' = 48 ... '9' = 57, '-' = 45; mal 10 = mal 8 plus mal 2
.mem $100: 49, 50, 51, 0           ; "123"
.mem $110: 45, 52, 48, 55, 0       ; "-407"
.mem $120: 48, 0                   ; "0"

atoi:     add  r2 := r0,r0         ; Ergebnis
          add  r6 := r0,r0         ; negativ?
          ldd  r3 := (r1,0)
          cmpsi r4 := r3,#45
          bne  r4,ziffern
          addi r6 := r0,#1
          addi r1 := r1,#1
ziffern:  ldd  r3 := (r1,0)
          beq  r3,fertig
          lsl  r4 := r2            ; 2 * x
          lsl  r5 := r4
          lsl  r5 := r5            ; 8 * x
          add  r2 := r4,r5         ; 10 * x
          addi r3 := r3,#-48       ; Ziffernwert
          add  r2 := r2,r3
          addi r1 := r1,#1
          bra  ziffern
fertig:   beq  r6,positiv
          sub  r2 := r0,r2
positiv:  add  r1 := r2,r0
          jmp  r31
```
Das Vorzeichen wird erst am Ende angewendet. So rechnet die Schleife nur mit positiven Zahlen.
</details>

## Klausur
Schieben (A06), Konstanten (A05).
