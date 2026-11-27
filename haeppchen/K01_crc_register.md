# K01 · Klausur F24: CRC-Rechenwerk

⏱️ 8 min · zurück: [J05](J05_namen_fallen.md) · weiter: [K02](K02_crc_steuerwerk.md)

## 🎯 Ziel
Eine komplette `mixed`-Architecture wie in der
Klausur schreiben (Instanz + Register).

## 📖 Erklärung
Aufgabe (F24 A1 F3, sinngemäß): Die Komponente
`calc_crc` hat die Ports `clk`, `res_n`, `s`
(1 Bit) und `crc` (5 Bit). Innen:
- eine Instanz von `single_step` (Ports `q`, `s`,
  `d`, siehe A03), aus der Bibliothek `work`,
- ein 5-Bit-Register, das bei jeder steigenden
  Flanke `d` übernimmt und dessen Ausgang `q` an
  `single_step` zurückgeführt wird,
- asynchroner Reset auf `"00000"`,
- `crc` ist der Registerinhalt.

Plan:
1. Signale für die internen Leitungen (`q`, `d`)
2. Instanz von `single_step`
3. Registerprozess (D01)
4. Ausgang zuweisen

## ✍️ Aufgabe
Schreibe die vollständige Architecture `mixed` zur
gegebenen Entity `calc_crc`.

<details><summary>✅ Lösung</summary>

```vhdl
use work.all;
architecture mixed of calc_crc is
  signal q, d : std_logic_vector(4 downto 0);
begin
  isingle_step: entity single_step
    port map(q => q, s => s, d => d);

  reg: process(clk, res_n) is
  begin
    if res_n = '0' then
      q <= (others => '0');
    else
      if clk'event and clk = '1' then
        q <= d;
      end if;
    end if;
  end process reg;

  crc <= q;
end architecture mixed;
```
Warum `crc <= q` und nicht direkt `crc` im Prozess?
Weil `q` gelesen werden muss (Rückführung) und ein
`out`-Port nicht gelesen werden darf.
</details>

## 🎓 Klausur
**F24 A1 F3** (Musterlösung fast identisch).

💻 Am Rechner: `am_rechner/L09/crc.vhd`
