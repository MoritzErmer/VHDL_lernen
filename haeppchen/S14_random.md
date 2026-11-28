# S14 · Senso: Zufall mit Startwert-Speicher

9 min · zurück: [S13](S13_lfsr_testbench.md) · weiter: [S15](S15_counter_typen.md)

## Ziel
Zwei Register mit Multiplexer und Freigabe aus einer Beschreibung auf Register-Transfer-Ebene programmieren.

## Erklärung
Senso muss dieselbe Zufallsfolge zweimal liefern: einmal zum Vorspielen, einmal zum Prüfen beim Nachspielen. Deshalb:
- Register **SR**: aktuelle Zufallszahl (LFSR mit festem, maximalem Muster).
- Register **MR**: gemerkter Startwert.
- `store_rnd = '1'`: MR übernimmt SR.
- `restore_rnd = '1'`: SR übernimmt MR (Vorrang).
- sonst `next_rnd = '1'`: SR macht einen LFSR-Schritt.
- `rnd(1 downto 0)`: zwei Bits aus SR, hier die unteren.

```vhdl
entity random is
  port(
    clk, res_n  : in  std_logic;
    next_rnd    : in  std_logic;
    store_rnd   : in  std_logic;
    restore_rnd : in  std_logic;
    rnd         : out std_logic_vector(1 downto 0)
    );
end entity random;
```
Zufall entsteht durch den Menschen: Im Startzustand läuft der Generator in jedem Takt weiter. Wann die Spielerin drückt, bestimmt den Startwert.

## Aufgabe
Schreibe `architecture behav of random`. Muster als Konstante `FB = "0001110"`.

<details><summary>Lösung</summary>

```vhdl
architecture behav of random is
  constant FB : std_logic_vector(7 downto 1) := "0001110";
  signal sr, mr : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      sr <= "00000001";
      mr <= "00000001";
    else
      if clk'event and clk = '1' then
        if store_rnd = '1' then
          mr <= sr;
        end if;
        if restore_rnd = '1' then
          sr <= mr;
        elsif next_rnd = '1' then
          if sr(7) = '1' then
            sr <= (sr(6 downto 0) xor FB) & sr(7);
          else
            sr <= sr(6 downto 0) & sr(7);
          end if;
        end if;
      end if;
    end if;
  end process;
  rnd <= sr(1 downto 0);
end architecture behav;
```
Die „?“-Logik aus dem Blockbild steckt im `if … elsif`: Der Multiplexer wählt MR bei `restore_rnd`, die Freigabe von SR ist `restore_rnd or next_rnd`.
</details>

## Klausur
Register mit Enable und Multiplexer (D02, M01), RTL-Bild in VHDL übersetzen (K01).
