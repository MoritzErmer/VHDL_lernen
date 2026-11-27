# D03 · Zähler mit numeric_std

⏱️ 6 min · zurück: [D02](D02_enable_clear.md) · weiter: [D04](D04_flipflops_zaehlen.md)

## 🎯 Ziel
Einen Zähler beschreiben – zwei typische Stile.

## 📖 Erklärung
**Stil 1: Signal vom Typ `unsigned`**
```vhdl
library ieee; use ieee.numeric_std.all;
...
signal cnt : unsigned(3 downto 0);
...
if clk'event and clk = '1' then
  cnt <= cnt + 1;     -- läuft 15 → 0 über
end if;
...
q <= std_logic_vector(cnt);   -- nebenläufig
```
**Stil 2: Variable vom Typ `integer` (Skript)**
```vhdl
process(clk, res_n) is
  variable q_int : integer range 0 to 9;
begin
  if res_n = '0' then
    q_int := 0;
  else
    if clk'event and clk = '1' then
      if q_int = 9 then
        q_int := 0;
      else
        q_int := q_int + 1;
      end if;
    end if;
  end if;
  q <= std_logic_vector(to_unsigned(q_int, 4));
end process;
```
- `integer range 0 to 9` → Synthese nimmt 4 Bit.
- `integer` läuft **nicht** automatisch über →
  Überlauf selbst behandeln (sonst Simulationsfehler).
- `unsigned` läuft modulo 2ⁿ über.
- In Stil 2 steht `q <= …` **außerhalb** der
  Flankenabfrage → `q` ist kein eigenes FF, sondern
  nur der Ausgang des FFs von `q_int`.

## ✍️ Aufgabe
Schreibe einen **Modulo-6-Zähler** `cnt` (Signal,
`unsigned(2 downto 0)`) mit Enable `en`: zählt nur
bei `en = '1'`, nach 5 kommt 0.
Nur den Teil **innerhalb** der Flankenabfrage.

<details><summary>✅ Lösung</summary>

```vhdl
if en = '1' then
  if cnt = 5 then
    cnt <= (others => '0');
  else
    cnt <= cnt + 1;
  end if;
end if;
```
`cnt = 5` ist erlaubt: numeric_std definiert
`=` zwischen `unsigned` und `natural`.
</details>

## 🎓 Klausur
Generischer Binärzähler: **F20 A2 F5**; Zähler mit
Variablen: F23 A2 F3 (`counter`).
