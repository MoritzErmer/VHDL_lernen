# M06 · PWM-Generator

4 min · zurück: [M05](M05_entpreller.md) · weiter: [M07](M07_fifo.md)

## Ziel
Ein Signal mit einstellbarem Tastgrad erzeugen (LED dimmen, Motor steuern).

## Erklärung
Ein freilaufender N-Bit-Zähler zählt `0 … 2^N-1`. Der Ausgang ist `'1'`, solange der Zähler **kleiner** als der Sollwert `duty` ist. Bei `duty = 4` und N = 4 ist das Signal 4 von 16 Takten an (25 %).

```vhdl
entity pwm is
  generic(N : positive := 4);
  port(
    clk, res_n : in  std_logic;
    duty       : in  std_logic_vector(N-1 downto 0);
    pwm_out    : out std_logic
    );
end entity pwm;
```

## Aufgabe
1. Schreibe `architecture behav` (Zähler als `unsigned`, Vergleich nebenläufig).
2. Welcher Tastgrad ergibt sich bei `duty = "1100"`?

<details><summary>Lösung</summary>

```vhdl
architecture behav of pwm is
  signal cnt : unsigned(N-1 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      cnt <= (others => '0');
    else
      if clk'event and clk = '1' then
        cnt <= cnt + 1;
      end if;
    end if;
  end process;
  pwm_out <= '1' when cnt < unsigned(duty) else '0';
end architecture behav;
```
2. 12 von 16 Takten = **75 %**.
</details>

## Klausur
Zähler + Vergleicher: F23 A2 (Oszillator `osc` mit `period`), F21 A2 (Zählerbasierte Steuerung).
