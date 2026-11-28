# W15 · Sieb des Eratosthenes

15 min · zurück: [W14](W14_atoi.md) · weiter: [W16](W16_matmul.md)

## Ziel
Ein Feld im Speicher als Markierungstabelle nutzen.

## Erklärung
`sieb(r1 = Adresse, r2 = N)`: Danach gilt Mem[Adresse + i] = 1 genau dann, wenn i eine Primzahl ist (i < N).
1. Alle Einträge ab 2 auf 1 setzen, 0 und 1 auf 0.
2. Für jedes p, das noch 1 ist: alle Vielfachen 2p, 3p, … auf 0 setzen.

Vielfache ohne Multiplikation: immer wieder p addieren.

## Aufgabe
Schreibe `sieb`.

<details><summary>Lösung</summary>

```ikr
; V13: sieb(r1 = Adresse, r2 = N): Sieb des Eratosthenes, danach Mem[Adresse + i] = 1 genau fuer Primzahlen i < N
; ohne Multiplikation: Vielfache durch fortgesetztes Addieren

sieb:     addi r3 := r0,#2         ; zuerst alle ab 2 als "prim" markieren
          std  (r1,0) := r0
          std  (r1,1) := r0
          addi r9 := r0,#1
init:     sub  r4 := r3,r2
          bge  r4,init_ende
          str  (r1,r3) := r9
          addi r3 := r3,#1
          bra  init
init_ende: addi r3 := r0,#2        ; p = 2
aussen:   sub  r4 := r3,r2
          bge  r4,fertig
          ldr  r5 := (r1,r3)
          beq  r5,naechstes        ; schon gestrichen: keine Primzahl
          add  r6 := r3,r3         ; erstes Vielfaches 2p
streichen: sub r4 := r6,r2
          bge  r4,naechstes
          str  (r1,r6) := r0
          add  r6 := r6,r3         ; naechstes Vielfaches
          bra  streichen
naechstes: addi r3 := r3,#1
          bra  aussen
fertig:   jmp  r31
```
`str (r1,r6) := r0` schreibt die 0 aus `r0` direkt in den Speicher.
</details>

## Klausur
Schleifen und indizierte Zugriffe (B01, B06).
