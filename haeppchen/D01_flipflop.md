# D01 · Das Flipflop-Template

5 min · zurück: [C08](C08_variable_akkumulator.md) · weiter: [D02](D02_enable_clear.md)

## Ziel
Das getaktete Prozess-Template **auswendig** und im
Stil der Vorlesung schreiben können.

## Erklärung
```vhdl
reg: process(clk, res_n) is
begin
  if res_n = '0' then           -- async. Reset
    q <= '0';
  else
    if clk'event and clk = '1' then
      q <= d;                   -- steig. Flanke
    end if;
  end if;
end process reg;
```
- Sensitivitätsliste: **nur `clk` und `res_n`**
  (`d` nicht! Der Prozess soll nur bei Takt oder
  Reset reagieren).
- `clk'event and clk = '1'` = steigende Flanke
  (gleichwertig: `rising_edge(clk)`).
- `res_n` = **low-aktiver** (`_n`), **asynchroner**
  Reset: wirkt sofort, ohne Takt.
- **Jedes Signal, das innerhalb der Flanken-Abfrage
  zugewiesen wird, wird ein Flipflop.**
- Kurzform mit `elsif` ist auch korrekt:
  `elsif clk'event and clk = '1' then`
- Vektoren zurücksetzen: `q <= (others => '0');`

## Aufgabe
Schreibe aus dem Kopf einen Prozess für ein
**5-Bit-Register** `q` (Signal), das bei jeder
steigenden Flanke `d` übernimmt und bei
`res_n = '0'` auf null geht.

<details><summary>Lösung</summary>

```vhdl
reg: process(clk, res_n) is
begin
  if res_n = '0' then
    q <= (others => '0');
  else
    if clk'event and clk = '1' then
      q <= d;
    end if;
  end if;
end process reg;
```
Das ist exakt der Prozess aus **F24 A1 F3**
(`calc_crc`). Ausgang danach nebenläufig:
`crc <= q;`
</details>

## Klausur
Dieses Template kommt in **jeder** Klausur vor –
in Registern, Zählern und Automaten.

Am Rechner: `am_rechner/L05/d_ff.vhd`
