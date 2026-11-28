# S07 · Senso: Taster testen

5 min · zurück: [S06](S06_impulsverkuerzer.md) · weiter: [S08](S08_input.md)

## Ziel
Eine Testbench schreiben, die Impulse zählt, statt einzelne Zeitpunkte zu prüfen.

## Erklärung
Der Taster soll bei **jeder** Druckdauer genau einen Impuls liefern. Statt zu raten, in welchem Takt `key` kommt, zählt die Testbench einfach alle Takte mit `key = '1'`:

- Taste drücken (`tx_n <= '0'`), viele Takte halten und mitzählen.
- Loslassen, noch ein paar Takte mitzählen.
- Am Ende muss die Zahl genau 1 sein.

So bleibt der Test richtig, auch wenn du den Synchronisierer später um eine Stufe verlängerst.

## Aufgabe
Schreibe den Teil des Stimulus-Prozesses, der einen 20 Takte langen Druck prüft. Variable: `n_pulses : natural`, Prozedur `takt` gibt es.

<details><summary>Lösung</summary>

```vhdl
n_pulses := 0;
tx_n <= '0';
for i in 1 to 20 loop
  takt;
  if key = '1' then
    n_pulses := n_pulses + 1;
  end if;
end loop;
tx_n <= '1';
for i in 1 to 5 loop
  takt;
  if key = '1' then
    n_pulses := n_pulses + 1;
  end if;
end loop;
assert n_pulses = 1
  report "Taster: " & integer'image(n_pulses) & " Impulse"
  severity error;
```
Zusatztest: Ein Druck, der kürzer als ein Takt ist, kann verloren gehen. In der Praxis sind Tastendrücke immer viel länger als ein Takt.
</details>

## Klausur
Testbenches mit Schleifen und `assert` (I03). Simulierbar mit `am_rechner/L13/tb_senso.vhd`.
