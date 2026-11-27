# J02 · Kritischer Pfad

⏱️ 6 min · zurück: [J01](J01_synthetisierbar.md) · weiter: [J03](J03_aufwand.md)

## 🎯 Ziel
Die Länge des längsten kombinatorischen Pfades
abschätzen und begründen.

## 📖 Erklärung
**Kritischer Pfad** = längster Weg durch Kombinatorik
zwischen zwei Registern (oder Ein-/Ausgang). Er
bestimmt die **maximale Taktfrequenz**:
f_max ≈ 1 / (Verzögerung kritischer Pfad).

Bäume statt Ketten: n Signale mit einem
2-Eingangs-Gatter (XOR, AND, +, …) verknüpfen:

| Anordnung | Gatter | Tiefe |
|---|---|---|
| Kette | n − 1 | n − 1 |
| **Binärbaum** | n − 1 | **⌈log₂ n⌉** |

Beispiel: 8 Bits per XOR → 7 Gatter, Tiefe
log₂ 8 = **3**.

Weitere Faustregeln:
- Ripple-Carry-Addierer: Pfad wächst **linear** mit
  der Bitbreite (Übertrag läuft durch alle Stufen).
- Abgerollte Schleife mit Abhängigkeit zur
  Vorgängeriteration (C08): Pfad wächst mit der
  Anzahl Iterationen.
- Register dazwischen (Pipelining) teilen den Pfad.

## ✍️ Aufgabe
Ein Ausgangsbit eines CRC-Netzwerks ist das XOR von
**8** Eingangsbits, ein anderes von **5**.
1. Wie lang ist der kritische Pfad in XOR-Gattern
   (2 Eingänge), bestmöglich optimiert?
2. Begründe kurz.

<details><summary>✅ Lösung</summary>

1. **3 XOR-Gatter**.
2. Das längste ist die Verknüpfung von 8 Bits. Mit
   7 Gattern als **Binärbaum** angeordnet ergibt sich
   eine Tiefe von log₂ 8 = 3. (Die 5 Bits brauchen
   ⌈log₂ 5⌉ = 3 auch, aber nicht mehr.)
</details>

## 🎓 Klausur
**F24 A1 F10**, F21 A2 F6, F22 A2 F9a.
