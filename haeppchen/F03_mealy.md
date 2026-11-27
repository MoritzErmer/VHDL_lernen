# F03 · Mealy-Automat

6 min · zurück: [F02](F02_moore_template.md) · weiter: [F04](F04_medwedew.md)

## Ziel
Denselben Detektor als Mealy-Automaten bauen und
den Zeitunterschied verstehen.

## Erklärung
Mealy erkennt `101` schon **während** die letzte `1`
anliegt → der Zustand `s101` entfällt:
```vhdl
type state_type is (start, s1, s10);
```
Übergänge (x=0 / x=1, Ausgabe nach `/`):
| Zustand | x = 0 | x = 1 |
|---|---|---|
| start | start / 0 | s1 / 0 |
| s1 | s10 / 0 | s1 / 0 |
| s10 | start / 0 | s1 / **1** |

```vhdl
output_function: process(x, current_state) is
begin
  y <= '0';
  if current_state = s10 and x = '1' then
    y <= '1';
  end if;
end process output_function;
```
Zeitlich: Moore-`y` kommt **einen Takt nach**
dem letzten Bit, Mealy-`y` **im selben Takt**
(solange `x` anliegt).

## Aufgabe
Schreibe `transition_function` für den Mealy-
Detektor (3 Zustände, Tabelle oben).

<details><summary>Lösung</summary>

```vhdl
transition_function: process(x, current_state) is
begin
  case current_state is
    when start =>
      if x = '1' then next_state <= s1;
      else            next_state <= start;
      end if;
    when s1 =>
      if x = '1' then next_state <= s1;
      else            next_state <= s10;
      end if;
    when s10 =>
      if x = '1' then next_state <= s1;
      else            next_state <= start;
      end if;
  end case;
end process transition_function;
```
</details>

## Klausur
Skript Kap. 3.4.1 (Morsedetektor als Mealy),
**F24 A1 F8** (Steuerwerk als Mealy: weniger Takte).
