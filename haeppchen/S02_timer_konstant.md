# S02 · Senso: Zeitgeber mit fester Dauer

8 min · zurück: [S01](S01_senso_ueberblick.md) · weiter: [S03](S03_timer_testen.md)

## Ziel
Aus einer Zeitangabe die Zahl der Takte berechnen und einen startbaren Zeitgeber schreiben.

## Erklärung
Der Zeitgeber `timer` steuert, wie lange eine Farbe leuchtet:
- `start_timer = '1'` startet ihn.
- Nach der Dauer **d** ist `timer_expired` genau **einen Takt** lang `'1'`.
- Während er läuft, ist egal, was an `start_timer` anliegt.

```vhdl
entity timer is
  port(
    clk, res_n    : in  std_logic;
    start_timer   : in  std_logic;
    dec_duration  : in  std_logic;
    res_duration  : in  std_logic;
    timer_expired : out std_logic
    );
end entity timer;
```
`dec_duration` und `res_duration` kommen erst in S04 dran.

Takte ausrechnen: d · f = 0,5 s · 50 000 000 Hz = **25 000 000** Takte. Der Zähler läuft von 0 bis 24 999 999, das braucht 25 Bit (2²⁵ = 33 554 432).

Bauplan: ein Flag `running` und ein Zähler `count`. Ist `running = '0'` und `start_timer = '1'`, geht es los. Erreicht `count` den letzten Wert, wird `timer_expired` für einen Takt gesetzt und `running` gelöscht.

## Aufgabe
Schreibe `architecture behav of timer` mit fester Dauer. Nimm dafür ein Generic `D_INIT : positive := 25_000_000` in die Entity auf, damit die Simulation mit kleinen Werten laufen kann.

<details><summary>Lösung</summary>

```vhdl
architecture behav of timer is
  signal count   : integer range 0 to D_INIT - 1;
  signal running : std_logic;
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      count <= 0;
      running <= '0';
      timer_expired <= '0';
    else
      if clk'event and clk = '1' then
        timer_expired <= '0';
        if running = '0' then
          if start_timer = '1' then
            running <= '1';
            count <= 0;
          end if;
        elsif count = D_INIT - 1 then
          running <= '0';
          timer_expired <= '1';
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;
end architecture behav;
```
`timer_expired <= '0';` am Anfang ist der Default. Nur im Takt, in dem die Zeit um ist, wird er überschrieben. So bleibt das Signal sicher nur einen Takt lang `'1'`.
</details>

## Klausur
Zähler mit Zeitbedingung wie in M04 (Taktteiler) und M09 (Ampel). Frequenz in Takte umrechnen: F23 A2 F4.
