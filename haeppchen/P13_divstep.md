# P13 · Klausur F22: Ein Divisionsschritt als Prozedur

10 min · zurück: [P12](P12_empfaenger_code.md) · weiter: [P14](P14_dividierwerk.md)

## Ziel
Die Schulmethode der Division als Hardware-Schritt verstehen und als Prozedur schreiben.

## Erklärung
Nach **F22 A1** (sinngemäß): Dividiert wird `a` (N Bit) durch `b` (M Bit). Alles steckt in **einem** Vektor `f` mit M + N Bit:

`f = Rest (M Bit) & Dividend (N Bit)`

Am Anfang ist der Rest 0. Ein Schritt:
1. Die obersten **M + 1** Bits von `f` sind der aktuelle „Teil-Dividend“. Davon `b` abziehen (mit einer führenden `'0'` auf M + 1 Bit erweitert).
2. Kein Unterlauf (oberstes Bit der Differenz `'0'`): `b` passt hinein → Quotientenbit `'1'`, Differenz wird der neue Rest.
3. Sonst: Quotientenbit `'0'`, Rest bleibt.
4. `f` um eins nach links schieben, Quotientenbit rechts einfügen.

Nach N Schritten steht in den unteren N Bits der **Quotient**, in den oberen M Bits der **Rest**.

Beispiel N = M = 4, a = 14, b = 3, `f` nach jedem Schritt:
```
start   0000 1110
1       0001 1100   00001 < 3
2       0000 1001   00011 - 3 = 0
3       0001 0010   00001 < 3
4       0010 0100   00010 < 3
```
Ergebnis: q = 0100 = 4, r = 0010 = 2.

## Aufgabe
Schreibe die Prozedur für den Deklarationsteil einer Architecture mit den Generics `N` und `M`:
```vhdl
procedure divstep(f : inout unsigned(M+N-1 downto 0);
                  d_b : in  unsigned(M-1 downto 0)) is
```
Rechne danach im Kopf: a = 13, b = 5. Welcher Quotient und Rest kommen heraus?

<details><summary>Lösung</summary>

```vhdl
procedure divstep(f : inout unsigned(M+N-1 downto 0);
                  d_b : in  unsigned(M-1 downto 0)) is
  variable d : unsigned(M downto 0);
begin
  d := f(M+N-1 downto N-1) - ('0' & d_b);
  if d(M) = '0' then
    f := d(M-1 downto 0) & f(N-2 downto 0) & '1';
  else
    f := f(M+N-2 downto 0) & '0';
  end if;
end procedure divstep;
```
Beim Fall „passt“ setzt sich das neue `f` zusammen aus: neuer Rest, die restlichen Dividendenbits eins nach links, Quotientenbit `'1'`.

13 / 5 = 2 Rest 3.
</details>

## Klausur
**F22 A1 F1–F7** (Prozedur `divstep` analysieren, Werte von `f` angeben). Prozeduren: H02.
