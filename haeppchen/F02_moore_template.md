# F02 · Das 3-Prozess-Template (Moore)

7 min · zurück: [F01](F01_automatentypen.md) · weiter: [F03](F03_mealy.md)

## Ziel
Einen Moore-Automaten im Skript-Stil aufschreiben.

## Erklärung
Sequenzdetektor: `y = '1'`, wenn zuletzt `1 0 1`
kam (überlappend).
```vhdl
architecture moore of detektor is
  type state_type is (start, s1, s10, s101);
  signal current_state, next_state : state_type;
begin
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
        if x = '1' then next_state <= s101;
        else            next_state <= start;
        end if;
      when s101 =>
        if x = '1' then next_state <= s1;
        else            next_state <= s10;
        end if;
    end case;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= start;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;

  output_function: process(current_state) is
  begin
    case current_state is
      when s101   => y <= '1';
      when others => y <= '0';
    end case;
  end process output_function;
end architecture moore;
```
3 Prozesse = 3 Blöcke im Blockschaltbild:
f (kombinatorisch) → Zustandsregister → g.

## Aufgabe
1. Warum steht in `transition_function` **kein**
   `when others`?
2. Was wäre falsch an `output_function:
   process(current_state, x)` für einen Moore-
   Automaten?
3. Warum ist `s101 → x='0' → s10` richtig und nicht
   `→ start`?

<details><summary>Lösung</summary>

1. Alle 4 Werte von `state_type` sind aufgezählt →
   `case` ist vollständig. (`when others` wäre
   erlaubt, aber unnötig.)
2. `x` würde in der Liste stehen, obwohl Moore nur
   vom Zustand abhängt – ein Hinweis, dass man
   eigentlich einen Mealy-Automaten baut.
3. **Überlappung**: Die letzten Zeichen sind `…1 0` –
   das `1` aus `101` ist schon der Anfang eines neuen
   `10`.
</details>

## Klausur
Grundgerüst für jede Automaten-Frage, z.B. **F24
A1 F8**, Skript Kap. 3.4.2.

Am Rechner: `am_rechner/L07/detektor.vhd`
