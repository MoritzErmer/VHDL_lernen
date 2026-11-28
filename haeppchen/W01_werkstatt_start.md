# W01 · Werkstatt: so programmierst du ganze Bausteine

6 min · zurück: [S20](S20_senso_gesamt.md) · weiter: [W02](W02_lauflicht.md)

## Ziel
Wissen, wie du in Block W arbeitest: Aus einem Text wird ein **kompletter**, lauffähiger Baustein – Entity und Architecture, ohne Vorlage.

## Erklärung
In den Blöcken davor hast du oft Teile ergänzt oder Fragen beantwortet. In Block W bekommst du nur eine **Spezifikation**: was der Baustein tun soll, welche Ports er hat. Den Code schreibst du vollständig selbst.

So gehst du vor (wie in P01):
1. **Ports** aus der Liste in eine `entity` übertragen. Generics für alles, was eine Zahl ist, die man ändern will (Zeiten, Breiten).
2. **Was muss gespeichert werden?** Jede Antwort wird ein Signal im getakteten Prozess (Zustand, Zähler, Register).
3. **Steuerung:** Gibt es klar getrennte Phasen? Dann ein Automat. Sonst reicht oft ein einzelner getakteter Prozess.
4. **Code schreiben**, dabei immer das Skript-Muster: `process(clk, res_n)`, `if res_n = '0' then … else if clk'event and clk = '1' then …`.
5. **Abgleichen**: Die App zeigt dir, was fehlt und was anders ist. Andere Namen oder eine andere Aufteilung können trotzdem richtig sein.
6. **Am Rechner testen**: Zu jeder Aufgabe gibt es in `am_rechner/L14` eine Testbench. Tippe deine Lösung ab und simuliere sie.

Die Aufgaben werden größer: vom Lauflicht (ein Prozess) bis zum Mini-Prozessor mit eigenem Befehlssatz. Plane für die großen ruhig 20–30 Minuten ein und teile sie dir auf.

## Aufgabe
Lies die Spezifikation von W02 (Lauflicht) und notiere nur: Welche Signale braucht der getaktete Prozess?

<details><summary>Lösung</summary>

- einen **Teiler** (zählt Takte bis zum nächsten Schritt),
- die **Position** der leuchtenden LED,
- die **Richtung** (hoch oder runter).

Die LEDs selbst sind keine eigenen Register: Sie werden kombinatorisch aus der Position berechnet.
</details>

## Klausur
In der Klausur schreibst du ganze Architectures auf Papier, z.B. Steuerwerk und ROM in F24 A1 (K02, K06) oder den Stack in F24 A2 (P17).
