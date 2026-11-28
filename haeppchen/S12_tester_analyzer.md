# S12 · Senso: Testbench aus tester und analyzer

10 min · zurück: [S11](S11_lfsr_schleife.md) · weiter: [S13](S13_lfsr_testbench.md)

## Ziel
Eine Testbench in eigene Komponenten aufteilen: eine erzeugt Stimuli, eine wertet aus.

## Erklärung
Gesucht sind Muster `fb` mit der **maximalen Zykluslänge 255**: Alle Werte außer 0 kommen dann im Zyklus vor. Dafür werden alle 128 Muster ausprobiert.

- **tester**: legt nacheinander jedes Muster an `fb`, gibt einen Takt `reset = '1'` und wartet dann 256 Takte, länger als jeder mögliche Zyklus.
- **analyzer**: zählt nach jedem `reset`, wie viele Takte vergehen, bis der Startwert wiederkommt.

Neue `wait`-Form (I02):
```vhdl
wait on clk until clk = '1' and reset = '1';
```
Wartet auf ein Ereignis an `clk`, bei dem danach die Bedingung gilt. Also: die nächste steigende Flanke, an der `reset = '1'` ist.

Der analyzer, wie er im Projekt verwendet wird:
```vhdl
process is
  variable cycle_length_counter : integer;
  variable start_value : std_logic_vector(7 downto 0);
begin
  wait until res_n = '1';
  loop
    wait on clk until clk = '1' and reset = '1';
    cycle_length_counter := 1;
    wait on clk until clk = '1' and reset = '0';
    start_value := q;
    wait on clk until clk = '1';
    while q /= start_value loop
      cycle_length_counter := cycle_length_counter + 1;
      wait on clk until clk = '1';
    end loop;
    report "cycle length: " &
      integer'image(cycle_length_counter);
  end loop;
end process;
```

## Aufgabe
Schreibe den Prozess des **tester** (Ausgänge `reset` und `fb`, Eingänge `clk`, `res_n`). Tipp: Muster aus der Schleifenvariable mit `to_unsigned(i, 7)`.

<details><summary>Lösung</summary>

```vhdl
process is
begin
  reset <= '0';
  fb <= (others => '0');
  wait until res_n = '1';
  for i in 0 to 127 loop
    fb <= std_logic_vector(to_unsigned(i, 7));
    reset <= '1';
    wait on clk until clk = '1';
    reset <= '0';
    for j in 1 to 256 loop
      wait on clk until clk = '1';
    end loop;
  end loop;
  wait;
end process;
```
Nicht synthetisierbar (mehrere `wait`), muss es aber auch nicht sein: Das ist reiner Testbench-Code. Für `numeric_std` gehört `use ieee.numeric_std.all;` in die Library-Klausel.
</details>

## Klausur
`wait`-Formen und Testbench-Aufbau (I02, I03). Testbench als Strukturbeschreibung: G03.
