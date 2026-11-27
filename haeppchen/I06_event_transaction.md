# I06 · Event vs. Transaction

⏱️ 5 min · zurück: [I05](I05_flanken_race.md) · weiter: [J01](J01_synthetisierbar.md)

## 🎯 Ziel
Den Unterschied kennen, der in F24 eine ganze
Teilaufgabe ausmacht.

## 📖 Erklärung
- **Transaction**: Einem Signal wird ein Wert
  zugewiesen (auch derselbe wie vorher).
- **Event**: Der Wert **ändert sich** wirklich.

Jedes Event ist eine Transaction, aber nicht
umgekehrt.

Prozesse mit Sensitivitätsliste reagieren nur auf
**Events**. Sendet eine Testbench zweimal
hintereinander `x <= 'a';`, sieht ein
`process(x)` das zweite `'a'` **nicht**.

Abhilfe in der Simulation:
```vhdl
tp: process(x'transaction) is
```
`x'transaction` ist ein Hilfssignal, das bei **jeder**
Zuweisung an `x` kippt → der Prozess läuft bei
jedem Zeichen.

**Aber:** Hardware kann Transactions nicht sehen
(ein Draht, der von 1 auf 1 „gesetzt“ wird, ändert
sich nicht) → **nicht synthetisierbar**. Die
synthetisierbare Lösung: einen **Takt** benutzen und
pro Takt ein Zeichen verarbeiten (F07).

## ✍️ Aufgabe
1. Warum braucht `tp` das `'transaction`-Attribut?
2. Warum ist `tp` damit nicht synthetisierbar?

<details><summary>✅ Lösung</summary>

1. Prozesse reagieren nur auf Events. Zwei gleiche
   aufeinanderfolgende Zeichen erzeugen nur **ein**
   Event und würden als **ein** Zeichen gezählt. Mit
   `'transaction` läuft der Prozess bei **jeder**
   Zuweisung an `x`.
2. Digitale Schaltungen können prinzipiell keine
   Transactions erkennen, sie reagieren nur auf
   Pegeländerungen (Events).
</details>

## 🎓 Klausur
**F24 A2 F4 und F8a** – wörtlich.
