# D04 · Wie viele Flipflops entstehen?

⏱️ 6 min · zurück: [D03](D03_zaehler.md) · weiter: [D05](D05_synchronisierer.md)

## 🎯 Ziel
Aus Code ablesen, welche Signale/Variablen zu
Flipflops werden – **Lieblingsfrage** der Klausur.

## 📖 Erklärung
In einem **getakteten** Prozess (innerhalb der
Flankenabfrage):

| Was | wird FF? |
|---|---|
| **Signal**, dem zugewiesen wird | **immer** |
| **Variable**, die **gelesen wird, bevor** sie im selben Durchlauf geschrieben wird | **ja** (sie muss den Wert vom letzten Takt speichern) |
| Variable, die **immer zuerst geschrieben**, dann gelesen wird | **nein** (nur Zwischenergebnis = Kombinatorik) |

Anzahl FFs = Anzahl **Bits** (`integer range 0 to
9` → 4 Bit, `unsigned(7 downto 0)` → 8 Bit,
`boolean`/`std_logic` → 1 Bit).

## ✍️ Aufgabe
Wie viele Flipflops?
```vhdl
process(clk) is
  variable t : std_logic;
  variable v : unsigned(3 downto 0);
begin
  if clk'event and clk = '1' then
    t := x and y;
    z <= t;
    cnt <= v;
    v := v + 1;
  end if;
end process;
```
(`z`: std_logic, `cnt`: unsigned(3 downto 0))

<details><summary>✅ Lösung</summary>

**9 Flipflops.**
- `t`: zuerst geschrieben, dann gelesen → **0**
- `z`: Signal → **1**
- `v`: wird in `cnt <= v` und `v + 1` gelesen,
  bevor es geschrieben wird → **4**
- `cnt`: Signal, 4 Bit → **4**

(`cnt` enthält immer den Wert von `v` aus dem
vorigen Takt – daher zwei verschiedene Register.)
</details>

## 🎓 Klausur
F19 A1 F6, F21 A2 F4, F22 A2 F8/F10, F23 A2 F2 –
fast **jedes Jahr**.
