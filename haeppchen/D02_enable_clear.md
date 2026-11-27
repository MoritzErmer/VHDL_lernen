# D02 · Enable und synchrones Löschen

5 min · zurück: [D01](D01_flipflop.md) · weiter: [D03](D03_zaehler.md)

## Ziel
Register mit Steuereingängen bauen und
**asynchron vs. synchron** unterscheiden.

## Erklärung
```vhdl
reg: process(clk, res_n) is
begin
  if res_n = '0' then             -- asynchron
    q <= (others => '0');
  else
    if clk'event and clk = '1' then
      if clr = '1' then           -- synchron
        q <= (others => '0');
      elsif en = '1' then         -- Enable
        q <= d;
      end if;                     -- sonst: halten
    end if;
  end if;
end process reg;
```
| | asynchron (`res_n`) | synchron (`clr`) |
|---|---|---|
| wirkt | sofort | nur bei Taktflanke |
| steht | **außerhalb** der Flankenabfrage | **innerhalb** |
| Sensitivitätsliste | ja | nein |

**Halten ohne Latch:** Im getakteten Prozess ist
„kein else“ **erlaubt** – das FF behält seinen Wert
einfach (das *ist* ein Flipflop mit Enable). Die
Latch-Falle aus C06 gilt nur für kombinatorische
Prozesse!

## Aufgabe
Ein Steuerwerk liefert `clr`. Das 5-Bit-Register
`q` soll bei `clr = '1'` mit der Taktflanke gelöscht
werden, sonst `d` übernehmen. Asynchroner Reset über
`res_n`. Schreibe den Prozess.

<details><summary>Lösung</summary>

```vhdl
reg: process(clk, res_n) is
begin
  if res_n = '0' then
    q <= (others => '0');
  else
    if clk'event and clk = '1' then
      if clr = '1' then
        q <= (others => '0');
      else
        q <= d;
      end if;
    end if;
  end if;
end process reg;
```
</details>

## Klausur
**Frühjahr 2024, A1 F9** (Teil der Gesamtschaltung).
