# S03 · Senso: Zeitgeber testen

7 min · zurück: [S02](S02_timer_konstant.md) · weiter: [S04](S04_timer_variabel.md)

## Ziel
Eine Komponente mit großem Generic in der Simulation mit kleinen Werten prüfen und Takte zählen.

## Erklärung
25 Millionen Takte zu simulieren dauert lange und sagt nichts Neues. Deshalb in der Testbench:
```vhdl
dut: entity work.timer
  generic map(D_INIT => 10)
  port map(...);
```
Dann misst eine Prozedur, wie viele Takte nach dem Start vergehen, bis `timer_expired` kommt:
- `start_timer` einen Takt auf `'1'`,
- danach in einer Schleife takten und mitzählen, bis `timer_expired = '1'`,
- prüfen, dass es im nächsten Takt wieder `'0'` ist.

Eine Sicherung gegen Endlosschleifen gehört dazu: Läuft der Zeitgeber nie ab, soll die Testbench mit `severity failure` abbrechen statt ewig zu laufen.

## Aufgabe
Schreibe `procedure miss_timer(erwartet : positive)` für den Stimulus-Prozess. Die Prozedur `takt` (Flanke abwarten, dann 1 ns) gibt es schon.

<details><summary>Lösung</summary>

```vhdl
procedure miss_timer(erwartet : positive) is
  variable n : natural := 0;
begin
  start_timer <= '1'; takt; start_timer <= '0';
  while timer_expired = '0' loop
    takt;
    n := n + 1;
    assert n < 100
      report "Timer laeuft nicht ab" severity failure;
  end loop;
  assert n = erwartet
    report "Dauer " & integer'image(n) severity error;
  takt;
  assert timer_expired = '0'
    report "laenger als ein Takt" severity error;
end procedure miss_timer;
```
Mit `D_INIT => 10` liefert `miss_timer(10)` keinen Fehler: Nach der Start-Flanke vergehen 10 Flanken bis `timer_expired`.
</details>

## Klausur
Testbench-Prozeduren und `assert` (I03, P04). Ganze Testbench in `am_rechner/L13/tb_senso.vhd`.
