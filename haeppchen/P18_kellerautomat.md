# P18 · Klausur F24: Kellerautomat für Klammerausdrücke

14 min · zurück: [P17](P17_stack.md) · weiter: [S01](S01_senso_ueberblick.md)

## Ziel
Einen Mealy-Automaten schreiben, der zusammen mit dem Stack verschachtelte Ausdrücke prüft.

## Erklärung
Nach **F24 A2** (sinngemäß). Regeln:
- Ein **Ausdruck A** ist ein Operand B oder zwei Ausdrücke, getrennt durch `'-'`.
- Ein **Operand B** ist `'x'`, `(A)` oder `[B]`.
- `'!'` beendet die Zeichenkette.

Gültig: `x-x`, `(x-x)-[x]`, `[(((x-[x])-x))]`. Ungültig: `xx`, `x--x`, `[x-x]` (in eckigen Klammern steht nur ein Operand), `(x-x]`.

Typen: `input_type is ('x', '-', '(', ')', '[', ']', '!')`, `output_type is ('0', '1', '*')`.

Drei Zustände genügen:
- `operand`: ein Operand wird erwartet (am Anfang, nach `'-'`, `'('`, `'['`).
- `operator`: ein Operand ist fertig, erlaubt sind `'-'`, `')'`, `']'`.
- `fehler`: wartet auf `'!'`.

Der Stack merkt sich, welche Klammer offen ist; `tos` geht in die Übergangsbedingungen ein. Mealy: `y`, `push`, `pop`, `clr` hängen von Zustand **und** Eingang ab. Für jedes Zeichen außer `'!'` ist `y = '*'`.

```vhdl
entity fsm is
  port(
    clk, res_n : in  std_logic;
    x          : in  input_type;
    tos        : in  stack_output_type;
    y          : out output_type;
    push       : out stack_input_type;
    pop, clr   : out boolean
    );
end entity fsm;
```

## Aufgabe
1. Überlege für jeden Zustand: Welche Zeichen sind erlaubt, was passiert mit dem Stack?
2. Schreibe `architecture behav of fsm` mit `transition_function` (erzeugt auch alle Ausgänge) und `state`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of fsm is
  type state_type is (operand, operator, fehler);
  signal current_state, next_state : state_type;
begin
  transition_function: process(current_state, x, tos) is
  begin
    next_state <= current_state;
    y <= '*'; push <= epsilon; pop <= false; clr <= false;
    if x = '!' then
      clr <= true;
      next_state <= operand;
      if current_state = operator and tos = eos then
        y <= '1';
      else
        y <= '0';
      end if;
    else
      case current_state is
        when operand =>
          case x is
            when 'x'    => next_state <= operator;
            when '('    => push <= '(';
            when '['    => push <= '[';
            when others => next_state <= fehler;
          end case;
        when operator =>
          case x is
            when '-' =>
              if tos = '[' then
                next_state <= fehler;
              else
                next_state <= operand;
              end if;
            when ')' =>
              if tos = '(' then pop <= true;
              else next_state <= fehler; end if;
            when ']' =>
              if tos = '[' then pop <= true;
              else next_state <= fehler; end if;
            when others =>
              next_state <= fehler;
          end case;
        when fehler =>
          null;
      end case;
    end if;
  end process transition_function;

  state: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= operand;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state;
end architecture behav;
```
Prüfe mit `(x-[x]-x)-[[x]])`: Nach dem letzten `]` ist der Stapel leer, das zusätzliche `)` findet `tos = eos` → `fehler` → `y = '0'`.
</details>

## Klausur
**F24 A2 F11** (Architecture `fsm`, Mealy, drei Zustände). Simulierbar in `am_rechner/L12/projekte_klausur.vhd` mit elf Testfolgen in `tb_projekte.vhd`.
