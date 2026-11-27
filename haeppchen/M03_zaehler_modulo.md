# M03 · Modulo-Zähler mit Übertrag

5 min · zurück: [M02](M02_schieberegister.md) · weiter: [M04](M04_taktteiler.md)

## Ziel
Einen Zähler schreiben, der sich zu größeren Zählern verketten lässt.

## Erklärung
Ein Modulo-Zähler zählt `0 … MAX` und beginnt dann wieder bei 0. Der Ausgang `ueberlauf` ist `'1'`, wenn **im nächsten Takt** übergelaufen wird – damit kann er die nächste Stufe weiterschalten (Sekunden → Minuten).

```vhdl
entity zaehler_mod is
  generic(MAX : positive := 9);
  port(
    clk, res_n : in  std_logic;
    en         : in  std_logic;
    q          : out integer range 0 to MAX;
    ueberlauf  : out std_logic
    );
end entity zaehler_mod;
```
`ueberlauf` ist **kombinatorisch** (nebenläufig), damit er im selben Takt wie der Zählerstand `MAX` anliegt.

## Aufgabe
Schreibe `architecture behav` mit einem internen Signal `cnt`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of zaehler_mod is
  signal cnt : integer range 0 to MAX;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= 0;
    else
      if clk'event and clk = '1' then
        if en = '1' then
          if cnt = MAX then
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
  q <= cnt;
  ueberlauf <= '1' when en = '1' and cnt = MAX else '0';
end architecture behav;
```
Kaskade: `en` der Zehnerstufe = `ueberlauf` der Einerstufe.
Weiter üben: Eingang `auf` (auf-/abwärts), Eingang `load` mit Startwert.
</details>

## Klausur
F20 A2 F5 (generischer Binärzähler), F23 A2 (Oszillator mit Zähler), Skript Kap. 2.3.9.
