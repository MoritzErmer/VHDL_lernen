# W05 · Array umdrehen

10 min · zurück: [W04](W04_zaehle.md) · weiter: [W06](W06_mulu.md)

## Ziel
Mit zwei Zeigern von außen nach innen arbeiten.

## Erklärung
`umdrehen(r1 = Adresse, r2 = Länge)` kehrt die Reihenfolge an Ort und Stelle um. Ein Zeiger startet vorne, einer hinten. Tauschen, dann aufeinander zu, bis sie sich treffen.

## Aufgabe
Schreibe `umdrehen`. Zeiger vergleichst du mit `cmpu` (Adressen sind vorzeichenlos).

Startdaten zum Testen (im Editor schon eingetragen, dein Code kommt darunter):
```ikr
.mem $100: 1, 2, 3, 4, 5
.mem $110: 10, 20, 30, 40
```

<details><summary>Lösung</summary>

```ikr
; V03: umdrehen(r1 = Adresse, r2 = Laenge): Array an Ort und Stelle umkehren
.mem $100: 1, 2, 3, 4, 5
.mem $110: 10, 20, 30, 40

umdrehen: add  r3 := r1,r2
          addi r3 := r3,#-1        ; Zeiger auf das letzte Element
loop:     cmpu r4 := r1,r3
          bge  r4,fertig           ; Zeiger haben sich getroffen
          ldd  r5 := (r1,0)
          ldd  r6 := (r3,0)
          std  (r1,0) := r6
          std  (r3,0) := r5
          addi r1 := r1,#1
          addi r3 := r3,#-1
          bra  loop
fertig:   jmp  r31
```
Länge 0: Der hintere Zeiger steht vor dem vorderen, die Schleife endet sofort.
</details>

## Klausur
Speicherzugriffe (B02).
