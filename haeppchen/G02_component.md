# G02 · component-Deklaration & positional

⏱️ 4 min · zurück: [G01](G01_instanziierung.md) · weiter: [G03](G03_testbench_struct.md)

## 🎯 Ziel
Die zweite Instanziierungs-Schreibweise lesen und
schreiben können.

## 📖 Erklärung
Klassisch (VHDL-87-Stil) wird die Komponente
**zuerst deklariert**, dann instanziiert:
```vhdl
architecture struct of top is
  component and_2 is
    port(
      x0, x1 : in  std_logic;
      y      : out std_logic);
  end component and_2;
  signal h : std_logic;
begin
  u1: and_2 port map(x0 => a, x1 => b, y => h);
  u2: and_2 port map(h, c, y);  -- positional
end architecture struct;
```
- Die `component`-Deklaration ist eine **Kopie der
  Port-Liste** der Entity (Schlüsselwort
  `component` statt `entity`).
- Instanz ohne das Wort `entity`.
- Welche Entity dahinter steckt, wird beim
  Elaborieren gesucht (gleicher Name in `work`).
- Positional `port map(h, c, y)`: Reihenfolge wie
  in der Port-Liste – fehleranfällig.

| | direkt (`entity work.x`) | `component` |
|---|---|---|
| Deklaration nötig | nein | ja |
| Tippfehler-Gefahr | gering | Port-Liste doppelt |

## ✍️ Aufgabe
Schreibe `u2` aus dem Beispiel mit **named
association** und als **direkte** Instanziierung.

<details><summary>✅ Lösung</summary>

```vhdl
u2: entity work.and_2
  port map(x0 => h, x1 => c, y => y);
```
</details>

## 🎓 Klausur
Skript Kap. 3.6 (Components und Strukturbeschreibungen).
Die Musterlösungen nutzen meist die direkte Form.
