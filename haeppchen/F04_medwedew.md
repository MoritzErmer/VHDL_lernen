# F04 · Medwedew: Ausgang aus dem Register

5 min · zurück: [F03](F03_mealy.md) · weiter: [F05](F05_defaults.md)

## Ziel
Einen Automaten mit **registrierten** Ausgängen
schreiben.

## Erklärung
Idee aus dem Skript: Die Übergangsfunktion berechnet
neben `next_state` auch `next_y`. Beides wird im
`state`-Prozess **mit derselben Flanke** gespeichert:
```vhdl
signal next_y : std_logic;
...
state: process(clk, res_n) is
begin
  if res_n = '0' then
    current_state <= start;
    y <= '0';
  else
    if clk'event and clk = '1' then
      current_state <= next_state;
      y <= next_y;          -- y ist ein FF!
    end if;
  end if;
end process state;
```
- Es gibt **keinen** `output_function`-Prozess.
- `y` ist glitchfrei, weil es direkt aus einem FF
  kommt.
- Timing wie Moore (Ausgang einen Takt nach dem
  Eingang).

Der einfachste Medwedew-Automat ist ein **Register**
oder **Zähler**, dessen Inhalt der Ausgang ist.

## Aufgabe
Ergänze für den Detektor (Zustände `start, s1, s10,
s101`) im `when s10 =>`-Zweig von
`transition_function` die Zuweisungen an `next_state`
**und** `next_y`.

<details><summary>Lösung</summary>

```vhdl
when s10 =>
  if x = '1' then
    next_state <= s101;
    next_y     <= '1';
  else
    next_state <= start;
    next_y     <= '0';
  end if;
```
`next_y` ist `'1'` genau dann, wenn der **nächste**
Zustand `s101` ist.
</details>

## Klausur
Skript Kap. 3.4.3, **F24 A1 F2**, F21 A2 F3
(busy-Ausgang als Medwedew mit 2 Zuständen).
