# L11 · Verdrahtungsfehler finden

6 min · zurück: [L10](L10_modularisieren.md) · weiter: [L12](L12_klausur_schaltplan.md)

## Ziel
Typische Fehler in Strukturbeschreibungen erkennen, bevor sie Punkte kosten.

## Erklärung
Checkliste für jede `struct`-Architecture:
- Ist jede innere Leitung **deklariert**?
- Wird jede Leitung von **genau einem** Ausgang getrieben?
- Ist jeder **Eingang** einer Instanz verbunden?
- Stimmen bei positional association **Reihenfolge und Richtung** (Ausgang an Ausgang)?
- Wird kein `out`-Port gelesen und kein `in`-Port getrieben?
- Passen die **Breiten** (`std_logic` an `std_logic`, 4 Bit an 4 Bit)?

## Aufgabe
Finde die **5 Fehler** in dieser Mehrheitsentscheider-Struktur (Plan wie in L06):
```vhdl
architecture struct of mehrheit is
  signal ab, ac : std_logic;
begin
  g1: entity work.and_2 port map(a, ab, b);
  g2: entity work.and_2 port map(x0 => a, x1 => c, y => ab);
  g3: entity work.and_2 port map(x0 => b, x1 => c);
  g4: entity work.or_3  port map(x0 => ab, x1 => ac,
                                 x2 => bc, y => y);
  y <= ab;
end architecture struct;
```

<details><summary>Lösung</summary>

1. `g1` positional in falscher Reihenfolge: Die Ports sind `(x0, x1, y)`. So landet `ab` am Eingang `x1` und der Eingang `b` am **Ausgang** `y` → Fehler (ein `in`-Port wird getrieben). Richtig: `port map(a, b, ab)`.
2. `g2` treibt `ab` ein zweites Mal (zwei Treiber), richtig ist `y => ac`.
3. `g3` hat keinen Ausgang angeschlossen, `bc` wird nie getrieben – richtig: `y => bc`.
4. `bc` ist nicht deklariert.
5. `y` wird doppelt getrieben (`g4` und `y <= ab;`) – die Zeile `y <= ab;` muss weg.

Wichtig: Der **Compiler meldet nur 1 und 4**. Die Fehler 2, 3 und 5 übersetzen fehlerfrei und fallen erst in der Simulation auf (`'X'` durch zwei Treiber, `'U'` auf der nie getriebenen Leitung) – oder gar nicht, wenn man nicht testet.
</details>

## Klausur
Hilft bei jeder Struktur-Aufgabe (F19 A1 F2, F20 A1 F1b, F24 A1 F9) – und beim Lesen fremder Codes in Fragen wie „Was ist hier falsch?“.
