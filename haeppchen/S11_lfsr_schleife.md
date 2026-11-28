# S11 · Senso: LFSR mit for-Schleife

6 min · zurück: [S10](S10_lfsr_code.md) · weiter: [S12](S12_tester_analyzer.md)

## Ziel
Dieselbe Hardware einmal mit Vektor-Operationen und einmal Bit für Bit in einer Schleife beschreiben.

## Erklärung
Eine `for`-Schleife ist synthetisierbar, wenn ihre Grenzen **Konstanten** sind (C07). Sie wird dann abgerollt, jede Iteration wird eigene Hardware.

Für jedes Bit gilt:
- `q(0)` bekommt `q(7)`.
- `q(i)` (für i = 1 … 7) bekommt `q(i-1) xor (fb(i) and q(7))`.

Das `and` ersetzt das `if q(7) = '1'`: Ist `q(7) = '0'`, ist das zweite XOR-Bit `'0'` und ändert nichts.

## Aufgabe
Schreibe `architecture loop_version of galois_lfsr` mit einem **Signal** `q_int` und einer `for`-Schleife.

<details><summary>Lösung</summary>

```vhdl
architecture loop_version of galois_lfsr is
  signal q_int : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      q_int <= "00000001";
    else
      if clk'event and clk = '1' then
        if reset = '1' then
          q_int <= "00000001";
        else
          q_int(0) <= q_int(7);
          for i in 1 to 7 loop
            q_int(i) <= q_int(i-1) xor (fb(i) and q_int(7));
          end loop;
        end if;
      end if;
    end if;
  end process;
  q <= q_int;
end architecture loop_version;
```
Weil `q_int` hier ein Signal ist, lesen alle Iterationen die **alten** Werte. Die Reihenfolge der Schleife ist deshalb egal. Die Testbench in `am_rechner/L13` prüft nach jeder Flanke, dass beide Architectures dasselbe liefern.
</details>

## Klausur
Synthetisierbare Schleifen (C07, J01). Zwei Architectures zu einer Entity, Auswahl mit `entity work.galois_lfsr(loop_version)` (G01).
