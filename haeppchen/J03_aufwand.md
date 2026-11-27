# J03 · Hardware-Aufwand von Operatoren

⏱️ 5 min · zurück: [J02](J02_kritischer_pfad.md) · weiter: [J04](J04_simulationsarten.md)

## 🎯 Ziel
Einschätzen, was ein Operator in Hardware kostet.

## 📖 Erklärung
| Operation | Hardware | Aufwand |
|---|---|---|
| `and`, `or`, `xor`, `not` | Gatter | sehr klein |
| Slice, `&`, Schieben um **konstante** Stellen | nur Verdrahtung | **null** |
| `+`, `-`, Vergleich `<` | Addierer | linear in Bitbreite |
| `=` | XNOR + UND-Baum | klein |
| `*` | Multiplizierer | ~ quadratisch |
| `/`, `mod` durch **Variable** | Dividierer | sehr groß, langer Pfad |
| `/ 2**k`, `* 2**k` | Schieben | **null** |
| Schieben um **variable** Stellen | Barrel-Shifter (Mux-Stufen) | mittel |

Merke: Multiplikation/Division mit **Zweierpotenzen**
ist gratis (nur Verdrahtung), mit beliebigen Werten
teuer.

## ✍️ Aufgabe
1. Warum ist `y / 2` (unsigned) bei der Synthese
   kein Problem?
2. Eine Architecture berechnet `y := (dy * x) / dx`
   kombinatorisch. Bewerte Aufwand und kritischen
   Pfad.

<details><summary>✅ Lösung</summary>

1. Durch 2 dividiert man durch einfaches
   **Rechtsschieben** um eine Stelle – reine
   Verdrahtung.
2. Multiplikation und Division durch Variablen
   ergeben eine **extrem aufwendige** kombinatorische
   Schaltung mit **sehr langem kritischen Pfad**.
   (Abhilfe: iterativ rechnen, z.B. Bresenham-
   Algorithmus nur mit Addition.)
</details>

## 🎓 Klausur
**F21 A2 F6/F7** (Bresenham), F22 A1 (Dividierwerke).
