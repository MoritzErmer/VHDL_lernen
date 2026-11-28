# U10 · LRU in Assembler

15 min · zurück: [U09](U09_lru_hand.md) · weiter: [U11](U11_lru_test.md)

## Ziel
Zwei verschachtelte Schleifen mit indizierten Speicherzugriffen übersetzen.

## Erklärung
Übersetze `lru` aus U09. In der Übung ist das Ziel RISC-V, hier der IKR RISC II.

Schnittstelle: `r1` = LIST, `r2` = N, `r3` = element, Rückgabe in `r1`.

Hilfreich:
- `ldr r6 := (r1,r5)` lädt `LIST[i]` mit `i` in `r5`. Indizierter Zugriff, ohne vorher eine Adresse auszurechnen.
- `LIST[j + 1] = tmp`: Adresse `r9 = r1 + j` ausrechnen, dann `std (r9,1) := r6`.
- `for (i = N-1; i >= 0; i--)` wird zu `blt r5,ende` am Schleifenkopf.

Unterschiede zu RISC-V: dort `lw`/`sw` mit Byte-Adressen (char: `lb`/`sb`), Parameter in `a0`–`a2`, Sprünge vergleichen zwei Register direkt (`beq a1,a2,ziel`). Der IKR RISC II vergleicht immer ein Register mit 0.

## Aufgabe
Schreibe `lru` in IKR-RISC-II-Assembler.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 0, 1, 2, 3, 4, 5, 6, 7
```

<details><summary>Lösung</summary>

```ikr
; U10: lru(r1 = LIST, r2 = N, r3 = element) -> r1 = am laengsten nicht benutztes Element
.mem $100: 0, 1, 2, 3, 4, 5, 6, 7

lru:      add  r4 := r0,r0         ; ret_val = 0
          addi r5 := r2,#-1        ; i = N - 1
suche:    blt  r5,ende             ; i < 0: nicht gefunden
          ldr  r6 := (r1,r5)       ; LIST[i]
          sub  r7 := r6,r3
          beq  r7,gefunden
          addi r5 := r5,#-1
          bra  suche
gefunden: addi r8 := r5,#-1        ; j = i - 1
schieben: blt  r8,vorne
          ldr  r6 := (r1,r8)       ; tmp = LIST[j]
          add  r9 := r1,r8
          std  (r9,1) := r6        ; LIST[j + 1] = tmp
          addi r8 := r8,#-1
          bra  schieben
vorne:    std  (r1,0) := r3        ; LIST[0] = element
          add  r9 := r1,r2
          ldd  r4 := (r9,-1)       ; ret_val = LIST[N - 1]
ende:     add  r1 := r4,r0
          jmp  r31
```
Die Testfälle prüfen die Beispiele aus U09 (5 und 7) und den Fall, dass schon das erste Element gesucht ist (dann wird nichts verschoben).
</details>

## Klausur
**Ü1 A1.2 F2.** Schleifen mit indiziertem Zugriff (B01, B06).
