# H06 · ROM per Funktion vorberechnen

⏱️ 7 min · zurück: [H05](H05_operatoren.md) · weiter: [I01](I01_takt_reset.md)

## 🎯 Ziel
Eine Tabelle zur **Übersetzungszeit** berechnen
lassen statt sie von Hand einzutippen.

## 📖 Erklärung
Eine Funktion kann den kompletten Array-Inhalt
berechnen. Als Initialwert einer **Konstanten**
wird sie bei der Elaboration ausgeführt – in der
Hardware landet nur die fertige Tabelle (= ROM):
```vhdl
type rom_type is array (0 to 15)
  of std_logic_vector(7 downto 0);

function init_rom return rom_type is
  variable result : rom_type;
begin
  for i in rom_type'range loop
    result(i) :=
      std_logic_vector(to_unsigned(i * i, 8));
  end loop;
  return result;
end function init_rom;

constant ROM : rom_type := init_rom;
...
quadrat <= ROM(to_integer(unsigned(x)));
```
Vorteil: Statt einer langen Rechenkette (langer
kritischer Pfad) nur ein Speicherzugriff.
Nachteil: Speicher wächst mit 2^Eingangsbits.

## ✍️ Aufgabe
Schreibe `init_rom` für ein ROM mit 8 Einträgen à
3 Bit, das zu jeder Adresse `i` die Anzahl der
Einsen von `i` speichert (`popcount`). Tipp: Wandle
`i` in einen 3-Bit-Vektor um und zähle.

<details><summary>✅ Lösung</summary>

```vhdl
type rom_type is array (0 to 7)
  of std_logic_vector(2 downto 0);

function init_rom return rom_type is
  variable result : rom_type;
  variable v      : unsigned(2 downto 0);
  variable n      : natural;
begin
  for i in rom_type'range loop
    v := to_unsigned(i, 3);
    n := 0;
    for k in v'range loop
      if v(k) = '1' then
        n := n + 1;
      end if;
    end loop;
    result(i) :=
      std_logic_vector(to_unsigned(n, 3));
  end loop;
  return result;
end function init_rom;
```
</details>

## 🎓 Klausur
**F24 A1 F12** (CRC-ROM mit 2048 Einträgen über
`init_rom`).
