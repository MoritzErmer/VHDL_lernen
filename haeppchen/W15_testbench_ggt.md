# W15 · Testbench komplett selbst: ggT gegen Referenz

20 min · zurück: [W14](W14_mini_cpu.md) · weiter: [Übersicht](../README.md)

## Ziel
Eine Testbench schreiben, die einen Baustein **erschöpfend** gegen eine unabhängige Referenz prüft.

## Erklärung
Für den ggT aus W10 gibt es viele Eingaben. Statt einzelne Fälle von Hand auszurechnen, rechnet die Testbench selbst – mit einem **anderen** Verfahren als die Hardware, sonst würde ein Denkfehler doppelt gemacht:
- Hardware: Subtraktionsverfahren.
- Referenz in der Testbench: Euklid mit Rest (`mod`), als `function` im Deklarationsteil der Architecture.

Aufbau:
- Taktgenerator mit Abbruch: `clk <= not clk after T/2 when not ende;`
- DUT mit Named Association.
- Stimuli in der **Taktmitte** (`wait until clk'event and clk = '0';`), damit nichts auf der Flanke liegt (I05).
- Zwei Schleifen über `a` und `b` von 1 bis 30, jeweils starten, auf `fertig` warten (mit Schutz gegen Endlosschleife), vergleichen, Fehler zählen.
- Am Ende eine Zusammenfassung ausgeben und `ende <= true`.

## Aufgabe
Schreibe Entity `tb_ggt` und Architecture `sim` komplett.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity tb_ggt is
end entity tb_ggt;

architecture sim of tb_ggt is
  constant T : time := 10 ns;
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  signal ende : boolean := false;
  signal start, fertig : std_logic := '0';
  signal a, b, ergebnis : std_logic_vector(7 downto 0) := x"01";

  -- Referenz: Euklid mit Rest, ganz anders gerechnet als die Hardware
  function ggt_ref(x0, y0 : positive) return positive is
    variable x : natural := x0;
    variable y : natural := y0;
    variable r : natural;
  begin
    while y /= 0 loop
      r := x mod y;
      x := y;
      y := r;
    end loop;
    return x;
  end function ggt_ref;
begin
  clk <= not clk after T/2 when not ende;

  dut: entity work.ggt
    port map(clk => clk, res_n => res_n, start => start, a => a, b => b,
             ergebnis => ergebnis, fertig => fertig);

  stimuli: process is
    variable fehler : natural := 0;
    variable takte : natural;
  begin
    wait for 2 * T;
    res_n <= '1';
    for x in 1 to 30 loop
      for y in 1 to 30 loop
        wait until clk'event and clk = '0';     -- Stimuli in der Taktmitte
        a <= std_logic_vector(to_unsigned(x, 8));
        b <= std_logic_vector(to_unsigned(y, 8));
        start <= '1';
        wait until clk'event and clk = '0';
        start <= '0';
        takte := 0;
        while fertig = '0' loop
          wait until clk'event and clk = '0';
          takte := takte + 1;
          assert takte < 300 report "ggT haengt" severity failure;
        end loop;
        if to_integer(unsigned(ergebnis)) /= ggt_ref(x, y) then
          fehler := fehler + 1;
          report "ggT(" & integer'image(x) & ", " & integer'image(y) & ") = " &
                 integer'image(to_integer(unsigned(ergebnis))) & " statt " &
                 integer'image(ggt_ref(x, y)) severity error;
        end if;
      end loop;
    end loop;
    report "tb_ggt fertig, " & integer'image(fehler) & " Fehler";
    ende <= true;
    wait;
  end process stimuli;
end architecture sim;
```
Ergebnis der Simulation: 900 Fälle, 0 Fehler. Baue zur Probe einen Fehler in den ggT ein (z.B. `x >= y` statt `x > y`) und sieh nach, ob die Testbench ihn findet.
</details>

## Klausur
Testbenches mit Schleifen, `assert`/`report` und Prozeduren (I01–I05, P04, S12). Simulierbar: `STOP=1ms ./sim.sh tb_ggt am_rechner/L14/werkstatt.vhd am_rechner/L14/tb_ggt.vhd`.
