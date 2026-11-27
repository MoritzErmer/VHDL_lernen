# E05 · ROM als konstantes Array

6 min · zurück: [E04](E04_arrays.md) · weiter: [E06](E06_records.md)

## Ziel
Einen Nur-Lese-Speicher beschreiben und seine
Kapazität berechnen.

## Erklärung
Ein ROM ist eine **Konstante** vom Array-Typ plus
ein Lesezugriff – rein kombinatorisch:
```vhdl
architecture behav of rom is
  type rom_type is array (0 to 3)
    of std_logic_vector(7 downto 0);
  constant ROM : rom_type :=
    (x"12", x"34", x"56", x"78");
begin
  data <= ROM(to_integer(unsigned(addr)));
end architecture behav;
```
**Kapazität** eines Speichers:

  **Anzahl Wörter × Wortbreite** = 2^Adressbits × Datenbits

Beispiel: 11 Adressbits, 5 Datenbits →
2¹¹ · 5 = 2048 · 5 = **10 240 Bit**.

Mit Takt (synchrones ROM, typisch für FPGA-Block-RAM):
die Leseadresse oder Ausgabe in einem getakteten
Prozess registrieren.

## Aufgabe
1. Ein ROM hat `addr : std_logic_vector(9 downto 0)`
   und `data : std_logic_vector(15 downto 0)`.
   Kapazität in Bit und in Byte?
2. Schreibe ein ROM mit 4 Einträgen à 2 Bit, das zu
   jeder Adresse `a` (2 Bit) den Wert `3 - a`
   liefert.

<details><summary>Lösung</summary>

1. 2¹⁰ · 16 = 1024 · 16 = **16 384 Bit = 2048 Byte**.

```vhdl
architecture behav of rom is
  type rom_type is array (0 to 3)
    of std_logic_vector(1 downto 0);
  constant ROM : rom_type :=
    ("11", "10", "01", "00");
begin
  data <= ROM(to_integer(unsigned(a)));
end architecture behav;
```
(Braucht `use ieee.numeric_std.all;`)
</details>

## Klausur
**F24 A1 F11** (Kapazität), **F19 A2 F3/F4**
(ROM synthetisierbar angeben), F23 A2 F5
(`period_rom`).
