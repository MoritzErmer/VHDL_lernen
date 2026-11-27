# M01 · Register mit Enable und Löschen

5 min · zurück: [L12](L12_klausur_schaltplan.md) · weiter: [M02](M02_schieberegister.md)

## Ziel
Das häufigste Bauteil überhaupt aus dem Kopf schreiben: ein generisches Register.

## Erklärung
Ein Register speichert `N` Bit. Fast immer braucht es:
- **asynchronen Reset** `res_n` (außerhalb der Flankenabfrage)
- **synchrones Löschen** `clr` (innerhalb, hat Vorrang)
- **Enable** `en`: nur dann wird `d` übernommen, sonst **halten** (kein `else` nötig, D02)

```vhdl
library ieee; use ieee.std_logic_1164.all;

entity register_n is
  generic(N : positive := 8);
  port(
    clk, res_n : in  std_logic;
    en, clr    : in  std_logic;
    d          : in  std_logic_vector(N-1 downto 0);
    q          : out std_logic_vector(N-1 downto 0)
    );
end entity register_n;
```

## Aufgabe
Schreibe `architecture behav of register_n`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of register_n is
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      q <= (others => '0');
    else
      if clk'event and clk = '1' then
        if clr = '1' then
          q <= (others => '0');
        elsif en = '1' then
          q <= d;
        end if;
      end if;
    end if;
  end process;
end architecture behav;
```
Weiter üben: Ergänze einen Eingang `inc`, der den Inhalt um 1 erhöht (Tipp: `unsigned`, internes Signal, weil `q` gelesen werden müsste).
</details>

## Klausur
Register stecken in fast jeder Aufgabe: F24 A1 F3/F9 (mit `clr`), H19 A2 (FIFO), F23 A2 (`period_reg`).

Am Rechner (Repo-Ordner): `am_rechner/L11/bausteine.vhd`
