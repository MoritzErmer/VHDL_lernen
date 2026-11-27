# G06 · if-generate & Rekursion

7 min · zurück: [G05](G05_for_generate.md) · weiter: [L01](L01_din_symbole.md)

## Ziel
Eine Komponente sich selbst instanziieren lassen –
die schwerste Strukturaufgabe der Klausuren.

## Erklärung
`if … generate` erzeugt Hardware nur, wenn die
(konstante!) Bedingung gilt. Damit baut man
**Rekursion**: Eine Entity instanziiert sich selbst
mit kleinerem Generic, bis ein **Abbruchfall** erreicht
ist.

Prioritätsencoder mit `2^A_WIDTH` Eingängen:
```vhdl
recursion_end: if A_WIDTH = 1 generate
  v_l  <= e(0);
  v_h  <= e(1);
  a(0) <= a_sel;
end generate recursion_end;

recursion: if A_WIDTH > 1 generate
  signal a_l, a_h :
    std_logic_vector(A_WIDTH-2 downto 0);
begin
  a(a'left) <= a_sel;
  a(a'left-1 downto 0) <= a_l when v_l = '1'
                          else a_h;
  lower: entity work.priorityencoder(recursive)
    generic map(A_WIDTH => A_WIDTH - 1)
    port map(e => e(e'length/2 - 1 downto 0),
             v => v_l, a => a_l);
  higher: entity work.priorityencoder(recursive)
    generic map(A_WIDTH => A_WIDTH - 1)
    port map(e => e(e'left downto e'length/2),
             v => v_h, a => a_h);
end generate recursion;
```
(dazu nebenläufig: `v <= v_l or v_h;` und
`a_sel <= not v_l when (v_l or v_h) = '1' else '-';`)

- Im `generate` dürfen **eigene Signale** deklariert
  werden (vor `begin`).
- Die Architecture muss **explizit** genannt werden
  (`(recursive)`), sonst ist die Wahl unklar.

## Aufgabe
1. Was ist der Abbruchfall, und warum braucht man ihn?
2. Bei `A_WIDTH = 3`: Wie viele Eingänge hat `e`, und
   wie viele Instanzen entstehen insgesamt
   (inkl. der obersten)?

<details><summary>Lösung</summary>

1. `A_WIDTH = 1` (2 Eingänge, direkt verdrahtet).
   Ohne ihn würde die Instanziierung **endlos**
   weiterlaufen – die Elaboration bricht ab.
2. `e` hat 2³ = **8** Eingänge. Instanzen:
   1 (Breite 3) + 2 (Breite 2) + 4 (Breite 1) = **7**.
</details>

## Klausur
**H19 A1 F11** (25 Punkte!), **F23 A1 F8/F10**
(rekursive `det_plru_element`, `update_tree`).
