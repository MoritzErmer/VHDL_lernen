# W06 · Multiplizieren ohne Multiplizierbefehl

10 min · zurück: [W05](W05_umdrehen.md) · weiter: [W07](W07_divu.md)

## Ziel
Die Schulmethode mit Schieben und Addieren schreiben.

## Erklärung
Der IKR RISC II hat keinen Multiplizierbefehl. `mulu(r1, r2)` rechnet `r1 · r2` (untere 32 Bit):
- Ist das unterste Bit von `r2` gesetzt, `r1` zum Ergebnis addieren.
- `r1` nach links, `r2` nach rechts schieben.
- Fertig, sobald `r2` = 0 ist.

## Aufgabe
Schreibe `mulu`.

<details><summary>Lösung</summary>

```ikr
; V04: mulu(r1, r2) -> r1 = r1 * r2 (untere 32 Bit), nur mit Schieben und Addieren

mulu:     add  r3 := r0,r0         ; Produkt
loop:     beq  r2,fertig           ; keine Bits mehr im Multiplikator
          and0i r4 := r2,#1
          beq  r4,schieben
          add  r3 := r3,r1         ; Bit gesetzt: Multiplikand addieren
schieben: lsl  r1 := r1            ; Multiplikand mal 2
          lsr  r2 := r2            ; naechstes Bit
          bra  loop
fertig:   add  r1 := r3,r0
          jmp  r31
```
Die Schleife läuft nur so oft, wie `r2` Bits hat. Bei kleinem Multiplikator also schnell. 65535 · 65537 = 2³² − 1 zeigt, dass nur die unteren 32 Bit übrig bleiben.
</details>

## Klausur
Schieben (A06), Multiplizierer im VHDL-Teil (W11).
