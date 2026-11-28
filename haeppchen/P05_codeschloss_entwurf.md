# P05 · Codeschloss: Entwurf mit Zählern

8 min · zurück: [P04](P04_getraenk_testbench.md) · weiter: [P06](P06_codeschloss_code.md)

## Ziel
Einen Automaten entwerfen, der neben dem Zustand noch **Zähler** braucht – und entscheiden, was Zustand und was Zähler wird.

## Erklärung
Aufgabe: Ein Türschloss öffnet sich nach der Zifferfolge `C1 C2 C3` (Generics, Standard 3-5-1).
- Eingänge: `taste` (ein Takt `'1'` pro Ziffer), `ziffer(3 downto 0)`.
- Richtige Folge → `offen = '1'` für `T_OFFEN` Takte, danach wieder zu.
- Jede falsche Ziffer → von vorn beginnen. Nach **drei** Fehlversuchen hintereinander → `gesperrt = '1'` für `T_SPERRE` Takte, Eingaben werden ignoriert.

Entwurfsfrage: Zustand oder Zähler?
- „Wie viele Ziffern sind schon richtig?“ – nur 0, 1, 2 → **Zustände** `z0`, `z1`, `z2`.
- „Wie viele Fehler?“ – könnte man auch als Zustände bauen, aber dann verdreifacht sich alles (`z0_f0`, `z0_f1`, …). Besser: **Zähler** `fehler`.
- „Wie lange schon offen?“ – Zahl bis `T_OFFEN` → **Zähler** `zeit` (Muster aus M09).

Faustregel: Zählt etwas bis zu einer Zahl, die ein Generic ist oder größer als etwa 3 sein kann, wird es ein Zähler.

## Aufgabe
1. Zeichne das Zustandsdiagramm mit den Zuständen `z0`, `z1`, `z2`, `s_offen`, `s_gesperrt`. Beschrifte die Kanten mit Bedingungen wie `richtig`, `falsch and fehler = 2`, `zeit = T_OFFEN - 1`.
2. Schreibe die Entity `codeschloss` mit den Generics `C1`, `C2`, `C3` (`natural range 0 to 9`), `T_OFFEN`, `T_SPERRE` (`positive`).

<details><summary>Lösung</summary>

Übergänge (`richtig`/`falsch` heißt: `taste = '1'` und Ziffer passt/passt nicht):
- `z0 --richtig--> z1 --richtig--> z2 --richtig--> s_offen`
- `z0/z1/z2 --falsch, fehler < 2--> z0`
- `z0/z1/z2 --falsch, fehler = 2--> s_gesperrt`
- `s_offen --zeit = T_OFFEN-1--> z0`
- `s_gesperrt --zeit = T_SPERRE-1--> z0`

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity codeschloss is
  generic(
    C1 : natural range 0 to 9 := 3;
    C2 : natural range 0 to 9 := 5;
    C3 : natural range 0 to 9 := 1;
    T_OFFEN  : positive := 4;
    T_SPERRE : positive := 8
    );
  port(
    clk, res_n      : in  std_logic;
    taste           : in  std_logic;
    ziffer          : in  std_logic_vector(3 downto 0);
    offen, gesperrt : out std_logic
    );
end entity codeschloss;
```
</details>

## Klausur
Automat plus Zähler/Register ist das Grundmuster vieler Klausuraufgaben, z.B. das CRC-Steuerwerk in F24 A1 (K02) oder der Empfänger in F19 A1 (P11).
