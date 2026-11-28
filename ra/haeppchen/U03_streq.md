# U03 · streq: zwei Strings vergleichen

10 min · zurück: [U02](U02_caller_callee.md) · weiter: [U04](U04_stapel_risc.md)

## Ziel
Ein kleines Unterprogramm von C nach IKR-RISC-II-Assembler übersetzen.

## Erklärung
Nach **Übung 0, Aufgabe 0.2** (dort für den IKR CISC, hier für den IKR RISC II): `streq` prüft zwei nullterminierte Strings auf Gleichheit.

In C:
```c
bool streq(const char *s0, const char *s1) {
    while (1) {
        if (*s0 != *s1) return false;
        if (*s0 == '\0') return true;
        s0++;
        s1++;
    }
}
```
Besonderheit des IKR RISC II: Der Speicher ist **wortadressiert**. Hier steht deshalb ein Zeichen pro Wort (ASCII-Code), das Ende ist 0.

Schnittstelle: `r1` = Adresse von s0, `r2` = Adresse von s1, Rückgabe `r1` = 1 (gleich) oder 0.

## Aufgabe
Schreibe `streq` in IKR-RISC-II-Assembler. Beide Zeichen laden, vergleichen, bei Ungleichheit sofort 0 zurückgeben, bei Stringende 1.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 65, 66, 67, 0          ; "ABC"
.mem $110: 65, 66, 67, 0          ; "ABC"
.mem $120: 65, 66, 68, 0          ; "ABD"
.mem $130: 65, 66, 0              ; "AB"
```

<details><summary>Lösung</summary>

```ikr
; U03: streq(r1 = Adresse s0, r2 = Adresse s1) -> r1 = 1 bei Gleichheit, sonst 0
; Strings: ein Zeichen pro Wort (ASCII-Code), Ende = 0
.mem $100: 65, 66, 67, 0          ; "ABC"
.mem $110: 65, 66, 67, 0          ; "ABC"
.mem $120: 65, 66, 68, 0          ; "ABD"
.mem $130: 65, 66, 0              ; "AB"

streq:    ldd  r3 := (r1,0)        ; Zeichen aus s0
          ldd  r4 := (r2,0)        ; Zeichen aus s1
          sub  r5 := r3,r4
          bne  r5,ungleich         ; verschieden -> false
          beq  r3,gleich           ; beide 0 -> Ende erreicht, true
          addi r1 := r1,#1
          addi r2 := r2,#1
          bra  streq
ungleich: add  r1 := r0,r0
          jmp  r31
gleich:   addi r1 := r0,#1
          jmp  r31
```
Die Reihenfolge der Abfragen zählt: Erst auf Ungleichheit prüfen, dann aufs Ende. Ist s0 zu Ende, s1 aber nicht, sind die Zeichen verschieden, und das Ergebnis ist richtig 0.
</details>

## Klausur
Übersetzen C → Assembler (B06, C03). Als Unterprogramm ohne weitere Aufrufe braucht `streq` nichts zu sichern.
