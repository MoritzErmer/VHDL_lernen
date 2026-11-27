# K03 · Klausur H19: 8-Bit-Prioritätsencoder

⏱️ 7 min · zurück: [K02](K02_crc_steuerwerk.md) · weiter: [K04](K04_multiplizierer.md)

## 🎯 Ziel
Eine 10-Punkte-Aufgabe in einem Zug lösen.

## 📖 Erklärung
Aufgabe (H19 A1 F8): Entity `priorityencoder_8_bit`
mit `e(7 downto 0)`, `v` und `a(2 downto 0)`.
`e(0)` hat die **höchste** Priorität. Schreibe die
Architecture `behav_loop` mit einer Schleife.

Bausteine, die du brauchst:
- Default-Zuweisungen (C02, C06)
- Schleife mit Überschreiben → Priorität (C07)
- `to_unsigned` + Typumwandlung (E02)
- `'-'` für den ungültigen Fall (A04)

## ✍️ Aufgabe
Schreibe die vollständige Architecture inkl. der
nötigen `library`/`use`-Zeile.

<details><summary>✅ Lösung</summary>

```vhdl
library ieee; use ieee.numeric_std.all;

architecture behav_loop of priorityencoder_8_bit is
begin
  encoder: process(e) is
  begin
    v <= '0';
    a <= "---";
    for i in 7 downto 0 loop
      if e(i) = '1' then
        v <= '1';
        a <= std_logic_vector(to_unsigned(i, 3));
      end if;
    end loop;
  end process encoder;
end architecture behav_loop;
```
Prüffragen: Läuft die Schleife `7 downto 0`
(damit Index 0 zuletzt schreibt und gewinnt)? Ist
`a` 3 Bit breit (`to_unsigned(i, 3)`)?
</details>

## 🎓 Klausur
**H19 A1 F8** (10 Punkte), dazu F5–F7.
