# S15 · Senso: Typen für die 7-Segment-Anzeige

8 min · zurück: [S14](S14_random.md) · weiter: [S16](S16_counter.md)

## Ziel
Mit eigenen Typen eine Schnittstelle schreiben, bei der man Fehler gar nicht erst machen kann.

## Erklärung
Der Punktestand wird zweistellig angezeigt. Die einfache Schnittstelle wäre
`score_low : out std_logic_vector(6 downto 0)` – aber welches Bit ist welches Segment?

Besser mit dem Typsystem (E03, E04): ein Aufzählungstyp für die Segmente und ein Array, das mit ihnen indiziert wird.
```vhdl
package senso_pkg is
  type segment_type is (a, b, c, d, e, f, g);
  type seg7_type is array (segment_type) of std_logic;
end package senso_pkg;
```
Jetzt heißt es `score_low(g)` statt `score_low(6)`, und ein Vertauschen mit einem anderen 7-Bit-Vektor fällt dem Compiler auf.

Segmente: `a` oben, `b` rechts oben, `c` rechts unten, `d` unten, `e` links unten, `f` links oben, `g` Mitte. Die Anzeige ist **low-aktiv**: `'0'` = Segment leuchtet.

**BIN2BCD**: Der Punktestand ist binär (0 … 63). Für zwei Ziffern braucht man Zehner und Einer: `score / 10` und `score mod 10`.

## Aufgabe
Schreibe Entity und Architecture `behav` für `seg7_decoder` (Eingang `digit : integer range 0 to 9`, Ausgang `seg : seg7_type`) mit einer `with … select`-Zuweisung. Es reichen die Ziffern 0 bis 3, der Rest geht genauso.

<details><summary>Lösung</summary>

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use work.senso_pkg.all;

entity seg7_decoder is
  port(
    digit : in  integer range 0 to 9;
    seg   : out seg7_type
    );
end entity seg7_decoder;

architecture behav of seg7_decoder is
begin
  with digit select seg <=
  --  a    b    c    d    e    f    g
    ('0', '0', '0', '0', '0', '0', '1') when 0,
    ('1', '0', '0', '1', '1', '1', '1') when 1,
    ('0', '0', '1', '0', '0', '1', '0') when 2,
    ('0', '0', '0', '0', '1', '1', '0') when 3,
    ('1', '0', '0', '1', '1', '0', '0') when 4,
    ('0', '1', '0', '0', '1', '0', '0') when 5,
    ('0', '1', '0', '0', '0', '0', '0') when 6,
    ('0', '0', '0', '1', '1', '1', '1') when 7,
    ('0', '0', '0', '0', '0', '0', '0') when 8,
    ('0', '0', '0', '0', '1', '0', '0') when 9;
end architecture behav;
```
Die 0: alles leuchtet außer der Mitte `g`. Die 1: nur `b` und `c`. Weil `digit` nur 0 bis 9 annehmen kann, braucht es kein `when others`.
</details>

## Klausur
Eigene Typen und Arrays mit Aufzählungs-Index (E03, E04), `with … select` (B02).
