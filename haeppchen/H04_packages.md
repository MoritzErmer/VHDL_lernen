# H04 · Packages

⏱️ 6 min · zurück: [H03](H03_wo_deklarieren.md) · weiter: [H05](H05_operatoren.md)

## 🎯 Ziel
Typen, Konstanten und Funktionen in einem Package
bereitstellen.

## 📖 Erklärung
Ein Package hat zwei Teile:
```vhdl
library ieee; use ieee.std_logic_1164.all;

package types is                 -- Header:
  type input_type is (kurz, lang, pause);
  constant N : positive := 8;
  function parity(v : std_logic_vector)
    return std_logic;            -- nur Kopf!
end package types;

package body types is            -- Body:
  function parity(v : std_logic_vector)
    return std_logic is
    variable p : std_logic := '0';
  begin
    for i in v'range loop
      p := p xor v(i);
    end loop;
    return p;
  end function parity;
end package body types;
```
Nutzung (vor der Entity):
```vhdl
use work.types.all;
entity morsedetektor is
  port(x : in input_type; ...
```
- **Header** = was andere sehen (Schnittstelle),
  **Body** = Implementierung der Unterprogramme.
- Ohne Unterprogramme braucht man keinen Body.
- Selektiv: `use work.types.input_type;`

## ✍️ Aufgabe
Warum **müssen** Typen, die für **Ports** einer
Entity verwendet werden, in einem Package stehen und
können nicht in der Architecture deklariert werden?

<details><summary>✅ Lösung</summary>

Die Ports stehen in der **Entity**, und die Entity
wird **vor** (und unabhängig von) der Architecture
analysiert. Ein Typ aus der Architecture ist dort
noch nicht sichtbar. Außerdem müssen **alle**
Komponenten, die über diesen Port verbunden werden
(auch die Testbench), **denselben** Typ kennen – das
geht nur über ein gemeinsames Package.
</details>

## 🎓 Klausur
**F22 A2 F1a** (fractional/complex im Package),
F22 A2 F2 (Header ergänzen), F24 A2 F2.
