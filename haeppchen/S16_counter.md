# S16 · Senso: Zählereinheit

9 min · zurück: [S15](S15_counter_typen.md) · weiter: [S17](S17_output.md)

## Ziel
Zwei Zähler, einen Vergleicher und zwei Decoder zu einer Einheit zusammenbauen und dabei abwägen: behav oder struct?

## Erklärung
Zwei Zähler (6 Bit):
- `score`: aktuelle Sequenzlänge = Punktestand.
- `step`: Schritt innerhalb der Sequenz, es gilt 0 ≤ step ≤ score.

Je Zähler gibt es `res_…` (synchron auf 0) und `inc_…` (+ 1). `step_eq_score = '1'`, wenn beide gleich sind: Die Sequenz ist zu Ende.

```vhdl
entity counter is
  port(
    clk, res_n    : in  std_logic;
    res_step      : in  std_logic;
    inc_step      : in  std_logic;
    res_score     : in  std_logic;
    inc_score     : in  std_logic;
    step_eq_score : out std_logic;
    score_low     : out seg7_type;
    score_high    : out seg7_type
    );
end entity counter;
```

Modularisierung: Die Zähler sind zwei kurze `if`-Abfragen, dafür lohnen sich keine eigenen Komponenten. Den 7-Segment-Decoder gibt es aber zweimal → eigene Komponente (S15), zweimal instanziiert. Ergebnis: eine **gemischte** Architecture.

## Aufgabe
Schreibe `architecture mixed of counter` mit `integer range 0 to 63` für die Zähler.

<details><summary>Lösung</summary>

```vhdl
architecture mixed of counter is
  signal step, score : integer range 0 to 63;
  signal tens, ones  : integer range 0 to 9;
begin
  counters: process(clk, res_n) is
  begin
    if res_n = '0' then
      step <= 0;
      score <= 0;
    else
      if clk'event and clk = '1' then
        if res_step = '1' then
          step <= 0;
        elsif inc_step = '1' then
          step <= (step + 1) mod 64;
        end if;
        if res_score = '1' then
          score <= 0;
        elsif inc_score = '1' then
          score <= (score + 1) mod 64;
        end if;
      end if;
    end if;
  end process counters;

  step_eq_score <= '1' when step = score else '0';

  tens <= score / 10;
  ones <= score mod 10;

  dec_high: entity work.seg7_decoder
    port map(digit => tens, seg => score_high);
  dec_low: entity work.seg7_decoder
    port map(digit => ones, seg => score_low);
end architecture mixed;
```
`mod 64` verhindert, dass `integer range 0 to 63` überläuft (in der Simulation wäre das ein Fehler). In Hardware ist das einfach der Überlauf eines 6-Bit-Zählers.
</details>

## Klausur
Behav vs. struct abwägen (L02, G01), Zähler mit Reset und Enable (D02, M03).
