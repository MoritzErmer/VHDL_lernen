# H01 · Funktionen

⏱️ 6 min · zurück: [G06](G06_if_generate_rekursion.md) · weiter: [H02](H02_prozeduren.md)

## 🎯 Ziel
Eine Funktion schreiben, die einen Wert berechnet.

## 📖 Erklärung
```vhdl
function parity(v : std_logic_vector)
  return std_logic is
  variable p : std_logic := '0';
begin
  for i in v'range loop
    p := p xor v(i);
  end loop;
  return p;
end function parity;
```
- Parameter sind immer **Eingänge** (`in`, meist
  weggelassen), es gibt **genau einen** Rückgabewert.
- Innen: **sequenzielle** Anweisungen, nur
  **Variablen** (keine Signale deklarieren!), **kein
  `wait`**.
- `pure` (Standard): gleiche Argumente → gleiches
  Ergebnis, kein Zugriff auf Signale außerhalb.
  `impure function` darf das.
- **Unbeschränkte Parameter** (`std_logic_vector`
  ohne Breite) machen die Funktion für jede Breite
  nutzbar → mit Attributen (`v'range`) arbeiten.
- Aufruf in Ausdrücken, nebenläufig oder im Prozess:
  `p <= parity(data);`
- Synthese: wird zu **kombinatorischer Logik**
  (Schleife abgerollt).

## ✍️ Aufgabe
Schreibe `function clz(x : std_logic_vector) return
natural`, die die **führenden Nullen** zählt (von
`x'left` aus bis zur ersten `'1'`). Beispiel:
`clz("00101") = 2`, `clz("000") = 3`.

<details><summary>✅ Lösung</summary>

```vhdl
function clz(x : std_logic_vector)
  return natural is
  variable n : natural := 0;
begin
  for i in x'range loop       -- von links
    if x(i) = '1' then
      return n;
    end if;
    n := n + 1;
  end loop;
  return n;
end function clz;
```
`return` mitten in der Schleife beendet die Funktion
sofort.
</details>

## 🎓 Klausur
**F22 A1 F11** (`clz`), F24 A1 F12 (`init_rom`),
F22 A2 F3–F6.
