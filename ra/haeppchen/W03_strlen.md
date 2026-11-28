# W03 · Länge eines Strings

6 min · zurück: [W02](W02_maximum.md) · weiter: [W04](W04_zaehle.md)

## Ziel
Mit einem Zeiger bis zur Endmarke laufen.

## Erklärung
`strlen(r1 = Adresse)` liefert die Anzahl der Zeichen vor der abschließenden 0. Tipp: Statt mitzuzählen, Zeiger am Ende minus Zeiger am Anfang.

## Aufgabe
Schreibe `strlen`.

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 72, 97, 108, 108, 111, 0      ; "Hallo"
.mem $110: 0
```

<details><summary>Lösung</summary>

```ikr
; V02: strlen(r1 = Adresse) -> r1 = Anzahl Zeichen vor der 0
.mem $100: 72, 97, 108, 108, 111, 0      ; "Hallo"
.mem $110: 0

strlen:   add  r2 := r1,r0         ; Zeiger merken
loop:     ldd  r3 := (r2,0)
          beq  r3,fertig
          addi r2 := r2,#1
          bra  loop
fertig:   sub  r1 := r2,r1         ; Ende - Anfang
          jmp  r31
```
Ein Befehl weniger pro Durchlauf als mit eigenem Zähler.
</details>

## Klausur
Zeiger (B01).
