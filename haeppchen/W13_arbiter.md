# W13 · Round-Robin-Arbiter

15 min · zurück: [W12](W12_frequenzzaehler.md) · weiter: [W14](W14_mini_cpu.md)

## Ziel
Mit einer Schleife und Variablen eine faire Zuteilung beschreiben.

## Erklärung
Vier Teilnehmer wollen dieselbe Ressource (z.B. einen Bus). Jeder meldet sich mit `req(i) = '1'`. Der Arbiter gibt immer genau einem `grant(i) = '1'`.

Regeln:
- Wer `grant` hat, behält es, solange er `req` hält.
- Gibt er ab, wird der **nächste** Anfragende nach ihm (im Kreis 0 → 1 → 2 → 3 → 0) bedient. So kommt jeder dran, niemand verhungert.
- Fragt niemand, ist `grant = "0000"`.

Ports: `clk`, `res_n`, `req : in std_logic_vector(3 downto 0)`, `grant : out std_logic_vector(3 downto 0)`. Merke dir `letzter` (wer zuletzt dran war).

## Aufgabe
Schreibe Entity `arbiter` und Architecture `behav`. Die Suche nach dem Nächsten machst du mit einer `for`-Schleife von 1 bis 4 und `(letzter + i) mod 4`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity arbiter is
  port(
    clk, res_n : in  std_logic;
    req        : in  std_logic_vector(3 downto 0);
    grant      : out std_logic_vector(3 downto 0)
    );
end entity arbiter;

architecture behav of arbiter is
  signal g      : std_logic_vector(3 downto 0);
  signal letzter : natural range 0 to 3;
begin
  process(clk, res_n) is
    variable idx : natural range 0 to 3;
    variable gefunden : boolean;
  begin
    if res_n = '0' then
      g <= (others => '0');
      letzter <= 3;
    else
      if clk'event and clk = '1' then
        if (g and req) /= "0000" then
          null;                               -- Besitzer fragt noch: behalten
        else
          g <= (others => '0');
          gefunden := false;
          for i in 1 to 4 loop
            idx := (letzter + i) mod 4;
            if not gefunden and req(idx) = '1' then
              g(idx) <= '1';
              letzter <= idx;
              gefunden := true;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;
  grant <= g;
end architecture behav;
```
Die Variable `gefunden` sorgt dafür, dass nur der **erste** Treffer zählt. In Hardware wird daraus ein Prioritätsencoder, dessen Startpunkt von `letzter` abhängt.
</details>

## Klausur
Schleifen mit Variablen (C08), Prioritätsencoder (K03).
