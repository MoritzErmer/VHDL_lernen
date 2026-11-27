# H02 · Prozeduren

6 min · zurück: [H01](H01_funktionen.md) · weiter: [H03](H03_wo_deklarieren.md)

## Ziel
Wiederkehrende Abläufe (v.a. in Testbenches) als
Prozedur schreiben.

## Erklärung
```vhdl
procedure send_byte(
  byte : in std_logic_vector(7 downto 0)) is
begin
  ser_in <= '1';                  -- Startbit
  wait for T;
  for i in byte'reverse_range loop
    ser_in <= byte(i);            -- LSB zuerst
    wait for T;
  end loop;
  ser_in <= '0';                  -- Stoppbit
  wait for T;
end procedure send_byte;
```
| | Funktion | Prozedur |
|---|---|---|
| Rückgabe | genau 1 Wert (`return x`) | beliebig viele `out`/`inout`-Parameter |
| `wait` | verboten | erlaubt (wenn im Prozess ohne Sensitivitätsliste aufgerufen) |
| Aufruf | in Ausdruck | als eigene Anweisung |

- Parameter-Modi: `in`, `out`, `inout`; Klassen:
  `constant` (Default bei `in`), `variable` (Default
  bei `out`/`inout`), `signal`.
- Eine Prozedur, die im Prozess deklariert ist, darf
  dessen Signale (z.B. `ser_in`) **direkt** treiben.

## Aufgabe
1. Warum ist `send_byte` **nicht synthetisierbar**?
2. Schreibe eine Prozedur `pulse`, die das Signal
   `start` für **eine Periode T** auf `'1'` setzt und
   danach wieder auf `'0'`.

<details><summary>Lösung</summary>

1. Sie enthält `wait for` – Zeitangaben kann eine
   Schaltung nicht umsetzen (nur Takte).

```vhdl
procedure pulse is
begin
  start <= '1';
  wait for T;
  start <= '0';
end procedure pulse;
```
Aufruf im Testprozess: `pulse;`
</details>

## Klausur
**F19 A1 F3b/c, F9** (`send_byte`,
`send_byte_with_parity`), **F22 A1** (`divstep`),
F19 A2 F2 (`init`).
