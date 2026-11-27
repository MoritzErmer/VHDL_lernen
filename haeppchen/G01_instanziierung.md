# G01 · Komponenten instanziieren

6 min · zurück: [F09](F09_verhalten_ablesen.md) · weiter: [G02](G02_component.md)

## Ziel
Bausteine in einer Architecture einsetzen und
verdrahten.

## Erklärung
Volladdierer aus zwei Halbaddierern:
```vhdl
architecture struct of volladdierer is
  signal s1, c1, c2 : std_logic;  -- Drähte
begin
  ha1: entity work.halbaddierer
    port map(a => a,  b => b,
             s => s1, c => c1);
  ha2: entity work.halbaddierer
    port map(a => s1, b => cin,
             s => s,  c => c2);
  cout <= c1 or c2;
end architecture struct;
```
- `ha1:` = **Label** (Pflicht, eindeutig).
- `entity work.halbaddierer` = **direkte
  Instanziierung** aus der Bibliothek `work`.
  Variante der Klausur: erst `use work.all;` vor der
  Architecture, dann nur `entity halbaddierer`.
- Bestimmte Architecture: `entity work.x(behav)`.
- `port map(formal => aktual)`: links der **Port der
  Komponente**, rechts das **eigene Signal/Port**.
- Interne Verbindungen brauchen **Signale**
  (vor `begin` deklariert).
- Unbenutzter Ausgang: `y => open`.
- Mischung aus Instanzen und Zuweisungen/Prozessen
  heißt oft `architecture mixed`.

## Aufgabe
Eine Komponente `single_step` (Ports `q`, `s`, `d`,
je wie in A03) soll mit einem 5-Bit-Register
verbunden werden: `d` geht ins Register, das
Register gibt `q` zurück. Schreibe die Instanz und
die nötige Signaldeklaration.

<details><summary>Lösung</summary>

```vhdl
signal q, d : std_logic_vector(4 downto 0);
...
isingle_step: entity work.single_step
  port map(q => q, s => s, d => d);
```
Dazu kommt der Registerprozess aus D01 und
`crc <= q;` – zusammen die Architecture `mixed` aus
**F24 A1 F3** (→ K01).
</details>

## Klausur
**F24 A1 F3/F9**, F20 A1 F1b, F19 A1 F2,
F23 A1 F2b – in jeder Klausur.
