# A06 · Fehlersuche: typische Syntax-Fallen

5 min · zurück: [A05](A05_vektoren.md) · weiter: [B01](B01_when_else.md)

## Ziel
Die Fehler erkennen, die in Klausuren am häufigsten
Punkte kosten.

## Erklärung
- `library ieee; use ieee.std_logic_1164.all;`
  gilt nur für die **direkt folgende** Entity (und
  deren Architectures). Zweite Entity in derselben
  Datei → nochmal hinschreiben!
- Für Arithmetik zusätzlich:
  `use ieee.numeric_std.all;`
- Eine Entity kann **mehrere Architectures** haben.
  Auswahl bei Instanziierung:
  `entity work.mux4(with_select)`
- `out`-Ports **nicht lesen** → internes Signal
  anlegen und am Ende zuweisen:
  ```vhdl
  signal q_int : std_logic;
  ...
  q <= q_int;
  ```
  (Genau so macht es das Skript beim Zähler.)
- Groß-/Kleinschreibung ist egal, `--` ist Kommentar.

## Aufgabe
Finde die **4 Fehler**:
```vhdl
entity zaehler is
  port(
    clk : in std_logic;
    q   : out std_logic;
    );
end zaehler;

architecture behav of zaehler
begin
  q <= not q;
end architecture behav;
```

<details><summary>Lösung</summary>

1. `library ieee; use ieee.std_logic_1164.all;` fehlt.
2. `;` nach dem letzten Port (`q : out std_logic;`).
3. `architecture behav of zaehler` – das **`is`**
   fehlt.
4. `q <= not q;` liest den `out`-Port `q`
   (und wäre außerdem eine kombinatorische
   Schleife ohne Takt!).

`end zaehler;` ist übrigens **erlaubt** (Kurzform),
im Skript-Stil schreibt man aber `end entity zaehler;`.
</details>

## Klausur
„Geben Sie … vollständig an“ heißt: inklusive
`library`/`use`. Fehlt das, gibt es Abzug.
