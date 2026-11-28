# P04 · Getränkeautomat: Testbench selbst schreiben

8 min · zurück: [P03](P03_getraenk_code.md) · weiter: [P05](P05_codeschloss_entwurf.md)

## Ziel
Eine Testbench mit Prozedur schreiben, die den Automaten systematisch prüft.

## Erklärung
Bausteine einer guten Testbench (Block I):
- Takt: `clk <= not clk after T/2;`
- Reset am Anfang, Stimuli **nicht** auf die Flanke legen (I05): nach der Flanke 1 ns warten.
- Wiederkehrende Abläufe als **Prozedur** im Prozess. Eine Prozedur, die ein Signal treibt, bekommt es als `signal`-Parameter:

```vhdl
procedure muenze(signal m : out std_logic) is
begin
  m <= '1'; takt; m <= '0';
end procedure;
```
- Prüfen mit `assert … report … severity error;`

## Aufgabe
Schreibe den Stimulus-Prozess der Testbench. Er soll:
1. eine Prozedur `takt` haben (auf steigende Flanke warten, dann 1 ns),
2. die Prozedur `muenze` von oben nutzen,
3. „1 Euro, dann 2 Euro“ einwerfen und prüfen, dass danach `ausgabe = '1'` und `rueckgeld = '0'` ist.

Signale `clk`, `res_n`, `m1`, `m2`, `ausgabe`, `rueckgeld` existieren bereits, der Automat ist instanziiert.

<details><summary>Lösung</summary>

```vhdl
stimuli: process is
  procedure takt is
  begin
    wait until clk'event and clk = '1';
    wait for 1 ns;
  end procedure;

  procedure muenze(signal m : out std_logic) is
  begin
    m <= '1'; takt; m <= '0';
  end procedure;
begin
  res_n <= '0';
  wait for 25 ns;
  res_n <= '1';
  takt;
  muenze(m1);
  muenze(m2);
  assert ausgabe = '1' and rueckgeld = '0'
    report "1 + 2 Euro falsch" severity error;
  takt;
  assert ausgabe = '0'
    report "Ausgabe zu lang" severity error;
  wait;
end process stimuli;
```
Nach `muenze(m2)` steht der Automat schon in `aus`: Die Flanke in `takt` hat ihn dorthin geschaltet. Weitere Fälle: 2 + 2 (Rückgeld), 1 + 1 + 1.
</details>

## Klausur
Testbench-Prozeduren: F19 A1 (`send_byte`, siehe P11). Komplette Testbench in `am_rechner/L12/tb_projekte.vhd`.
