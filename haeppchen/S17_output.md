# S17 · Senso: Ausgabeeinheit

6 min · zurück: [S16](S16_counter.md) · weiter: [S18](S18_steuerung_entwurf.md)

## Ziel
Eine rein kombinatorische Komponente einmal als Gatterschaltung und einmal abstrakt beschreiben.

## Erklärung
Die Ausgabe steuert vier LEDs:
- `led_on = '1'`: die LED mit der Farbe `color` leuchtet.
- `all_on = '1'`: alle LEDs leuchten (Spiel verloren), egal was sonst anliegt.

```vhdl
entity output is
  port(
    led_on, all_on : in  std_logic;
    color          : in  std_logic_vector(1 downto 0);
    leds           : out std_logic_vector(3 downto 0)
    );
end entity output;
```

## Aufgabe
1. Warum hat `output` weder `clk` noch `res_n`?
2. Gib die Gleichung für `leds(2)` (gelb, `color = "10"`) nur mit Gattern an.
3. Schreibe eine abstrakte `architecture behav of output` mit einem Prozess.

<details><summary>Lösung</summary>

1. Die Ausgänge hängen nur von den **aktuellen** Eingängen ab, es muss nichts gespeichert werden. Ohne Speicher gibt es nichts zu takten und nichts zurückzusetzen.
2. `leds(2) <= all_on or (led_on and color(1) and not color(0));` – also ein Decoder 2 auf 4 mit Freigabe `led_on`, danach je ein ODER mit `all_on`.
3. Abstrakt:
```vhdl
library ieee;
use ieee.numeric_std.all;

architecture behav of output is
begin
  process(led_on, all_on, color) is
  begin
    leds <= (others => all_on);
    if led_on = '1' then
      leds(to_integer(unsigned(color))) <= '1';
    end if;
  end process;
end architecture behav;
```
`(others => all_on)` setzt alle vier Bits auf den Wert von `all_on`. Die spätere Zuweisung an ein einzelnes Bit überschreibt nur dieses Bit.
</details>

## Klausur
Gatter aus Text ableiten (L06), Decoder mit Index (P07), letzte Zuweisung gewinnt (C02).
