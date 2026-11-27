# C06 · Kombinatorischer Prozess & die Latch-Falle

5 min · zurück: [C05](C05_if_case.md) · weiter: [C07](C07_for_schleife.md)

## Ziel
Die zwei Regeln für **kombinatorische** Prozesse
auswendig können.

## Erklärung
**Regel 1 – Sensitivitätsliste vollständig:**
Alle Signale, die im Prozess **gelesen** werden,
gehören in die Liste. Sonst: Simulation ≠ Hardware.

**Regel 2 – Jeder Ausgang in jedem Pfad:**
Jedes Signal, dem im Prozess zugewiesen wird, muss
in **jedem** möglichen Durchlauf einen Wert bekommen.
Sonst muss die Hardware den alten Wert **speichern**
→ es entsteht ein **Latch** (ungewollt, böse).

```vhdl
process(en, d) is   -- (falsch) Latch für q!
begin
  if en = '1' then
    q <= d;
  end if;           -- en='0': q behält Wert
end process;
```
**Lösung:** Default-Zuweisung am Anfang
```vhdl
process(a, b, sel) is
begin
  y <= '0';             -- Default
  v <= '1';             -- Default
  if sel = '1' then
    y <= a;
  ...
```
VHDL-2008: `process(all)` erledigt Regel 1
automatisch.

## Aufgabe
Was ist falsch? (2 Dinge)
```vhdl
process(a) is
begin
  if a = '1' then
    y <= b;
    z <= '1';
  else
    y <= c;
  end if;
end process;
```

<details><summary>Lösung</summary>

1. **Sensitivitätsliste unvollständig**: `b` und `c`
   werden gelesen, fehlen aber → `process(a, b, c)`.
2. **`z` ist im else-Zweig nicht zugewiesen** →
   Latch. Fix: `z <= '0';` als Default am Anfang
   oder im else-Zweig.
</details>

## Klausur
„Synthetisierbar / was erzeugt das Synthese-Tool?“ –
Latch vs. Flipflop vs. kombinatorisch muss sitzen.
