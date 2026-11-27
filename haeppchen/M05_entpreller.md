# M05 · Entpreller

6 min · zurück: [M04](M04_taktteiler.md) · weiter: [M06](M06_pwm.md)

## Ziel
Einen mechanischen Taster zuverlässig auswerten.

## Erklärung
Ein Taster **prellt**: beim Drücken springt das Signal einige Millisekunden zwischen 0 und 1. Die Eingangsstufe für Taster hat deshalb drei Teile:
1. **Synchronisierer** (D05) gegen Metastabilität
2. **Entpreller**: der Ausgang ändert sich erst, wenn der Eingang `N` Takte lang **stabil anders** war
3. **Flankenerkennung** (D07), wenn ein einzelner Puls gebraucht wird

```vhdl
entity entpreller is
  generic(N : positive := 4);
  port(
    clk, res_n : in  std_logic;
    roh        : in  std_logic;   -- schon synchronisiert
    sauber     : out std_logic
    );
end entity entpreller;
```
Idee: Ein Zähler läuft, solange `roh` vom gespeicherten Zustand abweicht. Ist `roh` wieder gleich, fängt er von vorn an.

## Aufgabe
Schreibe `architecture behav` mit den Signalen `zustand` und `cnt`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of entpreller is
  signal zustand : std_logic;
  signal cnt     : integer range 0 to N;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      zustand <= '0';
      cnt     <= 0;
    else
      if clk'event and clk = '1' then
        if roh = zustand then
          cnt <= 0;
        elsif cnt = N-1 then
          zustand <= roh;
          cnt     <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;
  sauber <= zustand;
end architecture behav;
```
Praxis: bei 50 MHz und 10 ms Prellzeit ist `N = 500 000`.
</details>

## Klausur
F20 A2 F9 (asynchrone Tastatureingänge), Skript Kap. 6.1 (Metastabilität).
