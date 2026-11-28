# U11 · init und test_lru

12 min · zurück: [U10](U10_lru_asm.md) · weiter: [U12](U12_2048_draw.md)

## Ziel
Eine Testroutine schreiben, die andere Unterprogramme nach Konvention aufruft.

## Erklärung
- `init(r1 = LIST, r2 = N)` schreibt `LIST[i] = i` für alle i.
- `test_lru` legt eine Liste mit 8 Elementen ab `$100` an, ruft `init` auf und meldet danach Zugriffe auf 4, 2 und 7 per `lru`.

Achtung Konvention: Nach jedem `bsr` sind `r1`–`r9` möglicherweise zerstört. Die Parameter für den nächsten Aufruf müssen also neu geladen werden. `test_lru` ruft andere auf und muss deshalb `r31` sichern.

## Aufgabe
Schreibe `test_lru` und `init`. `lru` aus U10 hängst du unten an.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.reg r30 = $1000
```

<details><summary>Lösung</summary>

```ikr
; U11: test_lru: Liste mit 8 Elementen anlegen, dann Zugriffe auf 4, 2, 7 melden
.reg r30 = $1000

test_lru: addi r30 := r30,#-1
          std  (r30,0) := r31
          addi r1 := r0,#$100      ; LIST
          addi r2 := r0,#8         ; N
          bsr  init
          addi r1 := r0,#$100
          addi r2 := r0,#8
          addi r3 := r0,#4
          bsr  lru
          addi r1 := r0,#$100      ; r1 - r9 sind caller-save: neu laden
          addi r2 := r0,#8
          addi r3 := r0,#2
          bsr  lru
          addi r1 := r0,#$100
          addi r2 := r0,#8
          addi r3 := r0,#7
          bsr  lru
          ldd  r31 := (r30,0)
          addi r30 := r30,#1
          jmp  r31

; init(r1 = LIST, r2 = N): LIST[i] = i
init:     add  r4 := r0,r0
init_l:   sub  r5 := r4,r2
          bge  r5,init_e
          str  (r1,r4) := r4
          addi r4 := r4,#1
          bra  init_l
init_e:   jmp  r31

lru:      add  r4 := r0,r0
          addi r5 := r2,#-1
suche:    blt  r5,ende
          ldr  r6 := (r1,r5)
          sub  r7 := r6,r3
          beq  r7,gefunden
          addi r5 := r5,#-1
          bra  suche
gefunden: addi r8 := r5,#-1
schieben: blt  r8,vorne
          ldr  r6 := (r1,r8)
          add  r9 := r1,r8
          std  (r9,1) := r6
          addi r8 := r8,#-1
          bra  schieben
vorne:    std  (r1,0) := r3
          add  r9 := r1,r2
          ldd  r4 := (r9,-1)
ende:     add  r1 := r4,r0
          jmp  r31
```
Am Ende steht in der Liste (7, 2, 4, 0, 1, 3, 5, 6), und `r1` ist 6 – genau wie in U09 von Hand gerechnet.
</details>

## Klausur
**Ü1 A1.2 F3/F4.**
