# B03 · Jede Zuweisung ist ein versteckter Prozess

4 min · zurück: [B02](B02_with_select.md) · weiter: [B04](B04_mehrfachtreiber.md)

## Ziel
Verstehen, wann nebenläufige Anweisungen
„aufwachen“ – Grundlage für alles in Block C.

## Erklärung
Der Simulator macht aus jeder nebenläufigen
Zuweisung intern einen **Prozess**, dessen
Sensitivitätsliste alle **rechts gelesenen
Signale** enthält:

```vhdl
y <= a when s = '1' else b;
```
ist gleichbedeutend mit
```vhdl
process(a, b, s) is
begin
  if s = '1' then
    y <= a;
  else
    y <= b;
  end if;
end process;
```
Ändert sich `a`, `b` oder `s` (= ein **Event**),
wird der Prozess ausgeführt und `y` neu berechnet.

Mit `with … select` entspricht das einem
`case`-Statement.

## Aufgabe
Schreibe als Prozess:
```vhdl
with op select
  y <= a and b when "00",
       a or  b when "01",
       a xor b when others;
```

<details><summary>Lösung</summary>

```vhdl
process(a, b, op) is
begin
  case op is
    when "00"   => y <= a and b;
    when "01"   => y <= a or b;
    when others => y <= a xor b;
  end case;
end process;
```
Sensitivitätsliste: **alle** gelesenen Signale
(`a`, `b`, `op`).
</details>

## Klausur
Wichtig für Fragen wie „Zu welcher Zeit …“ und
„Welche Werte haben die Signale …“
(z.B. F20 A1 F3/F4).
