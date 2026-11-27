# H05 · Operatoren überladen

⏱️ 5 min · zurück: [H04](H04_packages.md) · weiter: [H06](H06_rom_init_funktion.md)

## 🎯 Ziel
Eigene Typen mit `+`, `-`, `*` rechnen lassen.

## 📖 Erklärung
Steht der Funktionsname in **Anführungszeichen**, ist
die Funktion ein **Operator**. Man kann sie dann in
Infix-Schreibweise aufrufen:
```vhdl
type complex is record
  re, im : integer;
end record;

function "+"(a, b : complex) return complex is
begin
  return (re => a.re + b.re,
          im => a.im + b.im);
end function "+";
...
z := x + y;          -- ruft "+"(x, y) auf
```
- **Überladung**: Derselbe Name `"+"` existiert
  mehrfach; der Compiler wählt die Variante anhand
  der **Parametertypen** (und des Rückgabetyps).
- Genau so definiert `numeric_std` das `+` für
  `unsigned`.
- Nur **vorhandene** Operator-Symbole sind erlaubt
  (`"+"`, `"*"`, `"and"`, `"="` …), keine neuen.
- Unäre Operatoren haben einen Parameter:
  `function "-"(a : complex) return complex`

## ✍️ Aufgabe
1. Welche Besonderheit haben Funktionen, deren Namen
   in Anführungszeichen stehen?
2. Schreibe `"-"` (binär) für `complex`.

<details><summary>✅ Lösung</summary>

1. Sie **überladen einen Operator** und können in
   der üblichen Operator-Schreibweise (`a - b`)
   aufgerufen werden.

```vhdl
function "-"(a, b : complex) return complex is
begin
  return (re => a.re - b.re,
          im => a.im - b.im);
end function "-";
```
</details>

## 🎓 Klausur
**F22 A2 F3, F5, F6** (Operatoren für `fractional`
und `complex`).
