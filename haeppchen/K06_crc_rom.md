# K06 · Klausur F24: CRC per ROM

10 min · zurück: [K05](K05_volladdierer_unsigned.md) · weiter: [P01](P01_projekt_rezept.md)

## Ziel
Die größte Programmieraufgabe aus F24 lösen: Funktion
+ Array + ROM-Zugriff.

## Erklärung
Statt die 11-Bit-Nachricht `s` in mehreren Takten
durchzurechnen, wird für **jede** mögliche Nachricht
die Prüfsumme vorab berechnet und in einem ROM
abgelegt (2¹¹ · 5 Bit = 10 240 Bit).

Bausteine:
- `rom_type`: 2048 Einträge à 5 Bit (E04/E05)
- `init_rom`: für jede Adresse `i` die CRC
  berechnen – mit dem CRC-Schritt aus A03 als
  Schleife über die 11 Bits (C08, H06)
- Lesen: `crc <= r(to_integer(unsigned(s)));`

## Aufgabe
Schreibe die Architecture `behav` zur Entity `rom`
(Eingang `s(10 downto 0)`, Ausgang `crc(4 downto 0)`).
Die Bits werden von `s(0)` bis `s(10)` verarbeitet,
Start mit `q = "00000"`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.numeric_std.all;

architecture behav of rom is
  type rom_type is array (0 to 2047)
    of std_logic_vector(4 downto 0);

  pure function init_rom return rom_type is
    variable s      : std_logic_vector(10 downto 0);
    variable d, q   : std_logic_vector(4 downto 0);
    variable result : rom_type;
  begin
    for i in rom_type'range loop
      q := (others => '0');
      s := std_logic_vector(to_unsigned(i, 11));
      for j in 0 to 10 loop
        d(4 downto 3) := q(3 downto 2);
        d(2) := q(4) xor s(j) xor q(1);
        d(1) := q(0);
        d(0) := q(4) xor s(j);
        q := d;
      end loop;
      result(i) := d;
    end loop;
    return result;
  end function init_rom;

  signal r : rom_type := init_rom;
begin
  crc <= r(to_integer(unsigned(s)));
end architecture behav;
```
(`constant r` statt `signal r` geht auch und ist
sogar klarer.)
</details>

## Klausur
**F24 A1 F11/F12**.
