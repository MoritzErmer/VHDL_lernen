# U14 · 2048: Steine aufrücken

12 min · zurück: [U13](U13_2048_lfsr.md) · weiter: [U15](U15_2048_zug.md)

## Ziel
Ein Unterprogramm mit Startadresse und Schrittweite so schreiben, dass es für alle vier Zugrichtungen passt.

## Erklärung
Bei einem Zug rücken alle Steine in Zugrichtung so weit wie möglich auf. `compact` bearbeitet **eine Zeile oder Spalte**:
- `r1` = Adresse des Feldes, das in Zugrichtung am Rand liegt,
- `r2` = Schrittweite zum Nachbarfeld **entgegen** der Zugrichtung.

Beispiele: Zug nach oben, linke Spalte: Start = `board`, Schritt = 4. Zug nach rechts, unterste Zeile: Start = `board + 15`, Schritt = −1.

Idee: zwei Zeiger. `Ziel` zeigt auf die nächste freie Stelle, `Quelle` läuft über alle 4 Felder. Jeder Stein an der Quelle wird zum Ziel geschoben, dann rückt das Ziel weiter.

Rückgabe in `r1`: 1, wenn sich etwas bewegt hat (dann darf ein neuer Stein erscheinen), sonst 0.

## Aufgabe
Schreibe `compact`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0
```

<details><summary>Lösung</summary>

```ikr
; U14: compact(r1 = Startadresse, r2 = Schrittweite) -> r1 = 1, wenn sich etwas bewegt hat
; linke Spalte des Beispiels, Zug nach oben: Start = board, Schrittweite = 4
.mem $100: 0, 3, 2, 0,  4, 0, 0, 0,  4, 0, 0, 2,  1, 2, 0, 0

compact:  add  r3 := r1,r0         ; Ziel: naechste freie Stelle
          add  r4 := r1,r0         ; Quelle
          addi r5 := r0,#4         ; 4 Felder
          add  r9 := r0,r0         ; bewegt = false
loop:     beq  r5,fertig
          ldd  r6 := (r4,0)
          beq  r6,weiter           ; leeres Feld: nur Quelle weiter
          sub  r7 := r4,r3
          beq  r7,passt            ; Stein steht schon richtig
          std  (r3,0) := r6        ; aufruecken
          std  (r4,0) := r0
          addi r9 := r0,#1
passt:    add  r3 := r3,r2         ; naechste freie Stelle
weiter:   add  r4 := r4,r2
          addi r5 := r5,#-1
          bra  loop
fertig:   add  r1 := r9,r0
          jmp  r31
```
Steht ein Stein schon am Ziel (`Quelle = Ziel`), wird nichts geschrieben und nichts als bewegt gezählt. Durch die Schrittweite funktioniert dasselbe Unterprogramm für alle vier Richtungen.
</details>

## Klausur
**PÜ1 F6.** Zeiger und Schrittweite als Parameter.
