# G05 · for-generate

⏱️ 6 min · zurück: [G04](G04_generics.md) · weiter: [G06](G06_if_generate_rekursion.md)

## 🎯 Ziel
N gleiche Bausteine automatisch erzeugen und
verketten.

## 📖 Erklärung
N-Bit-Ripple-Carry-Addierer aus Volladdierern:
```vhdl
architecture struct of adder_n is
  signal c : std_logic_vector(N downto 0);
begin
  c(0) <= cin;

  stufen: for i in 0 to N-1 generate
    va: entity work.volladdierer
      port map(a => a(i), b => b(i),
               cin => c(i),
               s => s(i), cout => c(i+1));
  end generate stufen;

  cout <= c(N);
end architecture struct;
```
- `generate` ist **nebenläufig** (außerhalb von
  Prozessen), `for … loop` ist **sequenziell** (im
  Prozess). Nicht verwechseln!
- Label vor `for … generate` ist Pflicht.
- Trick für Ketten: Ein Signal-Vektor, der **ein
  Element länger** ist als die Anzahl Stufen
  (`c(N downto 0)`).
- Im generate-Rumpf dürfen auch Zuweisungen und
  Prozesse stehen.

## ✍️ Aufgabe
Baue mit `for … generate` ein N-Bit-Schieberegister
aus N Instanzen von `d_ff` (Ports `clk`, `res_n`,
`d`, `q`). Eingang `ser_in`, Ausgang
`par_out(N-1 downto 0)`; `ser_in` geht in Stufe N-1,
Stufe i speist Stufe i-1.

<details><summary>✅ Lösung</summary>

```vhdl
architecture struct of schiebereg is
  signal z : std_logic_vector(N downto 0);
begin
  z(N) <= ser_in;
  stufen: for i in N-1 downto 0 generate
    ff: entity work.d_ff
      port map(clk => clk, res_n => res_n,
               d => z(i+1), q => z(i));
  end generate stufen;
  par_out <= z(N-1 downto 0);
end architecture struct;
```
</details>

## 🎓 Klausur
F20 A1 F10 (Multiplizierer für allgemeine N),
F21 A1 F10 (LAB generisch), H19 A1 F11.

💻 Am Rechner: `am_rechner/L08/adder_n.vhd`
