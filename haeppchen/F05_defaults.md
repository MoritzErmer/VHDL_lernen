# F05 · Defaults im Automaten

5 min · zurück: [F04](F04_medwedew.md) · weiter: [F06](F06_steuerwerk.md)

## Ziel
Automaten kurz und latch-frei schreiben.

## Erklärung
Zwei Defaults sparen viel Schreibarbeit:
```vhdl
transition_p: process(current_state, start) is
begin
  next_state <= current_state;   -- bleib, wo du bist
  case current_state is
    when S1 =>
      if start = '1' then
        next_state <= S2;        -- nur Änderungen
      end if;
    when S2 =>
      next_state <= S3;
    ...
```
```vhdl
output_p: process(current_state, start) is
begin
  clr    <= '0';                 -- Ausgangs-
  valid  <= '0';                 -- Defaults
  sel_d  <= '-';                 -- egal, wenn
  case current_state is          -- nicht genutzt
    when S1 => sel_d <= '1';
    ...
```
Ohne Defaults müsste jeder Zweig **jeden** Ausgang
setzen – sonst entsteht ein Latch (C06).
`'-'` als Default für Multiplexer-Steuersignale gibt
der Synthese Freiheit (A04).

## Aufgabe
Was passiert hier, wenn `current_state = S3`?
```vhdl
process(current_state) is
begin
  case current_state is
    when S1 => valid <= '0'; clr <= '1';
    when S2 => valid <= '0';
    when S3 => valid <= '1'; clr <= '0';
  end case;
end process;
```
Und was passiert in `S2` mit `clr`?

<details><summary>Lösung</summary>

- In `S3`: `valid = '1'`, `clr = '0'` – korrekt.
- In `S2` wird `clr` **nicht** zugewiesen → `clr`
  behält den Wert aus dem vorherigen Zustand →
  **Latch**. Fix: `clr <= '0';` als Default vor dem
  `case` (und `valid <= '0';` gleich mit).
</details>

## Klausur
Musterlösung **F24 A1 F8** benutzt genau diese
Defaults (`next_state <= current_state;`,
`sel_k4 <= '-';`).
