# W11 · Rekursion: Fibonacci

15 min · zurück: [W10](W10_binsuche.md) · weiter: [W12](W12_kgv.md)

## Ziel
Ein rekursives Unterprogramm mit Stapel schreiben.

## Erklärung
`fib(r1 = n)` mit fib(0) = 0, fib(1) = 1, fib(n) = fib(n − 1) + fib(n − 2).

Bei jedem rekursiven Aufruf muss gesichert werden:
- `r31` (wird durch `bsr` überschrieben),
- `n` (braucht man nach dem ersten Aufruf noch),
- das Zwischenergebnis fib(n − 1) (braucht man nach dem zweiten Aufruf).

Diese Werte gehören in callee-save Register (`r10`, `r11`), deren alte Werte auf den Stapel.

## Aufgabe
Schreibe `fib` rekursiv.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.reg r30 = $1000
```

<details><summary>Lösung</summary>

```ikr
; V09: fib(r1 = n) -> r1 = Fibonacci-Zahl, rekursiv mit Stapel (r30)
.reg r30 = $1000

fib:      addi r2 := r1,#-2
          bge  r2,rekursion        ; n >= 2
          jmp  r31                 ; fib(0) = 0, fib(1) = 1: r1 ist schon richtig
rekursion: addi r30 := r30,#-3
          std  (r30,0) := r31
          std  (r30,1) := r10
          std  (r30,2) := r11
          add  r10 := r1,r0        ; n merken
          addi r1 := r10,#-1
          bsr  fib                 ; fib(n - 1)
          add  r11 := r1,r0
          addi r1 := r10,#-2
          bsr  fib                 ; fib(n - 2)
          add  r1 := r1,r11
          ldd  r31 := (r30,0)
          ldd  r10 := (r30,1)
          ldd  r11 := (r30,2)
          addi r30 := r30,#3
          jmp  r31
```
Für n < 2 ist `r1` schon das Ergebnis: sofort zurück, ohne den Stapel anzufassen. fib(15) braucht fast 2000 Aufrufe, das zeigt, warum man Fibonacci besser iterativ rechnet.
</details>

## Klausur
Stapel (U01, U04), Calling Convention (C02).
