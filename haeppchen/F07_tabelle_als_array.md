# F07 · Zustandstabelle als Array

6 min · zurück: [F06](F06_steuerwerk.md) · weiter: [F08](F08_entwurf_garagentor.md)

## Ziel
Einen Automaten kompakt mit einer konstanten
Übergangstabelle beschreiben.

## Erklärung
Statt verschachtelter `case`-Anweisungen:
```vhdl
type table_type is
  array (state_type, input_type) of state_type;
constant TRANS : table_type := (
  --        kurz   lang   pause
  luecke => (kurz1, lang1, luecke),
  kurz1  => (kurz2, warte, luecke),
  ...
  others => (warte, warte, luecke));
...
next_state <= TRANS(current_state, x);
```
- Zeilen-Index = Zustand, Spalten-Index = Eingabe.
- Mit einem Record (E06) kann jedes Feld auch die
  **Ausgabe** enthalten:
  `TRANS(state, x).state`, `TRANS(state, x).output`.
- Synthetisierbar als **Medwedew/Mealy-Kern**:
  ```vhdl
  if clk'event and clk = '1' then
    state <= TRANS(state, x).state;
  end if;
  ...
  y <= TRANS(state, x).output;   -- Mealy
  ```

## Aufgabe
Die Tabelle `transition_table` hat Felder vom Typ
`state_output_pair_type` (`.state`, `.output`).
Schreibe eine **synthetisierbare** Architecture-Zeile
für `y` und den getakteten Prozess für `state`
(Reset auf `q0`, `res_n` low-aktiv).

<details><summary>Lösung</summary>

```vhdl
tp: process(res_n, clk) is
begin
  if res_n = '0' then
    state <= q0;
  else
    if clk'event and clk = '1' then
      state <= transition_table(state, x).state;
    end if;
  end if;
end process tp;

y <= transition_table(state, x).output;
```
</details>

## Klausur
**F24 A2 F9** (exakt das), Skript Kap. 3.4.1
(„Alternative Implementierung für Prozess f“).
