# E08 · Attribute

5 min · zurück: [E07](E07_aggregate.md) · weiter: [F01](F01_automatentypen.md)

## Ziel
Attribute lesen, nutzen und durch Zahlen ersetzen
können.

## Erklärung
Für `signal v : std_logic_vector(7 downto 0);`

| Attribut | Wert |
|---|---|
| `v'left` | 7 (linke Grenze) |
| `v'right` | 0 |
| `v'high` | 7 (größter Index) |
| `v'low` | 0 |
| `v'length` | 8 |
| `v'range` | `7 downto 0` |
| `v'reverse_range` | `0 to 7` |

Bei `(0 to 7)`: `'left` = 0, aber `'high` = 7!

Für Signale:
- `clk'event` – **Wert hat sich geändert** (jetzt)
- `x'transaction` – Signal, das bei **jeder
  Zuweisung** kippt (auch ohne Wertänderung)

Für Typen: `sp_type'low`, `integer'high`,
`state_type'pos(q1)`.

Nutzen: Code passt sich automatisch an Breiten an:
```vhdl
variable tmp : unsigned(a'range);
for i in a'range loop ...
```

## Aufgabe
Ersetze die Attribute durch Ausdrücke mit `N`, wenn
`f : unsigned(2*N-1 downto 0)` gilt:
1. `f'length`  2. `f'left`  3. `f'high - 1`
4. `f'right`

<details><summary>Lösung</summary>

1. `2*N`  2. `2*N-1`  3. `2*N-2`  4. `0`
</details>

## Klausur
**F22 A1 F2a** (alle Attribute durch M, N
ersetzen), H19 A1 F11 (`e'length / 2`, `a'left`),
F24 A2 F10 (`sp_type'low`).
