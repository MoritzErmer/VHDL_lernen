# S13 · Senso: Testbench verdrahten und Muster finden

7 min · zurück: [S12](S12_tester_analyzer.md) · weiter: [S14](S14_random.md)

## Ziel
Eine Testbench als Strukturbeschreibung aufbauen und das Ergebnis der Simulation deuten.

## Erklärung
Die Testbench `galois_lfsr_tb` hat **keine Ports** und vier Instanzen:
- `clk_res_gen`: erzeugt `clk` und `res_n`,
- `tester` → `reset`, `fb`,
- `galois_lfsr` (das DUT, „device under test“),
- `analyzer` liest `reset` und `q`.

Interne Signale: genau die Verbindungen dazwischen (`clk`, `res_n`, `reset`, `fb`, `q`).

## Aufgabe
1. Schreibe `architecture struct of galois_lfsr_tb`.
2. Die Simulation findet 16 Muster mit Zykluslänge 255, darunter `"0001110"`, `"0110001"`, `"1100001"`. Warum findet sie kein Muster mit Länge 256?

<details><summary>Lösung</summary>

```vhdl
entity galois_lfsr_tb is
end entity galois_lfsr_tb;

architecture struct of galois_lfsr_tb is
  signal clk, res_n, reset : std_logic;
  signal fb : std_logic_vector(7 downto 1);
  signal q  : std_logic_vector(7 downto 0);
begin
  gen: entity work.clk_res_gen
    port map(clk => clk, res_n => res_n);
  tst: entity work.tester
    port map(clk => clk, res_n => res_n,
             reset => reset, fb => fb);
  dut: entity work.galois_lfsr
    port map(clk => clk, res_n => res_n,
             reset => reset, fb => fb, q => q);
  ana: entity work.analyzer
    port map(clk => clk, res_n => res_n,
             reset => reset, q => q);
end architecture struct;
```
2. Die 0 liegt immer in ihrem eigenen Zyklus (S09). Für alle anderen Werte bleiben höchstens 255 übrig.
</details>

## Klausur
Testbench als Strukturbeschreibung (G03, L10). Simulierbar: `STOP=1ms ./sim.sh galois_lfsr_tb am_rechner/L13/senso.vhd am_rechner/L13/lfsr_test.vhd`.
