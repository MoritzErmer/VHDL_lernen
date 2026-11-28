# W02 · Maximum eines Arrays

8 min · zurück: [W01](W01_werkstatt_start.md) · weiter: [W03](W03_strlen.md)

## Ziel
Eine Schleife mit Vergleich und bedingter Übernahme schreiben.

## Erklärung
`maximum(r1 = Adresse, r2 = Länge > 0)` gibt das größte Element zurück (Zahlen mit Vorzeichen). `cmps` liefert +1, 0 oder −1.

## Aufgabe
Schreibe `maximum`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 3, -7, 12, 5, 12, -1
```

<details><summary>Lösung</summary>

```ikr
; V01: maximum(r1 = Adresse, r2 = Laenge > 0) -> r1 = groesstes Element (mit Vorzeichen)
.mem $100: 3, -7, 12, 5, 12, -1

maximum:  ldd  r3 := (r1,0)        ; max = erstes Element
          addi r1 := r1,#1
          addi r2 := r2,#-1
loop:     beq  r2,fertig
          ldd  r4 := (r1,0)
          cmps r5 := r4,r3
          ble  r5,kleiner          ; nicht groesser
          add  r3 := r4,r0
kleiner:  addi r1 := r1,#1
          addi r2 := r2,#-1
          bra  loop
fertig:   add  r1 := r3,r0
          jmp  r31
```
`ble r5,kleiner` überspringt die Übernahme, wenn das neue Element nicht größer ist. Gleiche Werte ändern nichts.
</details>

## Klausur
Vergleichen (A06), Schleifen (B06).
