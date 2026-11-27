# J04 · Funktionale vs. Timing-Simulation

3 min · zurück: [J03](J03_aufwand.md) · weiter: [J05](J05_namen_fallen.md)

## Ziel
Eine kurze Theoriefrage sicher beantworten.

## Erklärung
| | funktional | Timing |
|---|---|---|
| Modell | dein VHDL-Code (RTL) | Netzliste **nach** Synthese/Place&Route |
| Verzögerungen | **keine** (nur Deltas) | echte Gatter- und Leitungszeiten |
| Zweck | Funktion prüfen | Zeitverhalten prüfen |

Auf RT-Ebene wird **fast nur funktional** simuliert:
- Taktfrequenz und Verzögerungen werden erst bei der
  Synthese als **Constraints** vorgegeben; das Tool
  versucht, sie einzuhalten (**statische
  Timing-Analyse**).
- Eine Timing-Simulation müsste **alle** Fälle
  durchspielen, um die maximale Verzögerung zu
  finden – praktisch nutzlos.

## Aufgabe
Beantworte in je einem Satz:
1. Worin unterscheiden sich funktionale und Timing-
   Simulation?
2. Welche wird auf RT-Ebene fast ausschließlich
   verwendet, und warum?

<details><summary>Lösung</summary>

1. Die funktionale Simulation berücksichtigt **keine
   Verzögerungszeiten**.
2. Die **funktionale**: Zeitanforderungen werden erst
   bei der Synthese über Constraints vorgegeben und
   vom Tool eingehalten; eine Timing-Simulation
   müsste alle Fälle abdecken.
</details>

## Klausur
**H19 A2 F1a–c** (5 Punkte).
