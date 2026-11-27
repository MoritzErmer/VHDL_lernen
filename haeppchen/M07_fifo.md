# M07 · Synchroner FIFO

9 min · zurück: [M06](M06_pwm.md) · weiter: [M08](M08_ram.md)

## Ziel
Einen Ringpuffer mit Schreib- und Lesezeiger bauen – eine ganze Klausuraufgabe.

## Erklärung
Ein FIFO (first in, first out) speichert Werte in einem Array. Zwei Zeiger laufen im Kreis:
- `windex`: hier wird als Nächstes **geschrieben**
- `rindex`: hier steht das **vorderste** Element
- `count`: Füllstand, daraus `empty` und `full`

Regeln: Nicht schreiben, wenn voll; nicht lesen, wenn leer. Gleichzeitiges Schreiben und Lesen ändert den Füllstand nicht.

```vhdl
entity fifo is
  generic(DEPTH : positive := 4; W : positive := 8);
  port(
    clk, res_n   : in  std_logic;
    wr_en, rd_en : in  std_logic;
    din          : in  std_logic_vector(W-1 downto 0);
    dout         : out std_logic_vector(W-1 downto 0);
    empty, full  : out std_logic
    );
end entity fifo;
```

## Aufgabe
Schreibe `architecture behav`. Deklariere `memory_type`, die Zeiger und `count`. `dout` zeigt immer das vorderste Element.

<details><summary>Lösung</summary>

```vhdl
architecture behav of fifo is
  type memory_type is array (0 to DEPTH-1)
    of std_logic_vector(W-1 downto 0);
  signal memory : memory_type;
  signal windex, rindex : integer range 0 to DEPTH-1;
  signal count : integer range 0 to DEPTH;
begin
  process(clk, res_n) is
    variable do_wr, do_rd : boolean;
  begin
    if res_n = '0' then
      windex <= 0;
      rindex <= 0;
      count  <= 0;
    else
      if clk'event and clk = '1' then
        do_wr := wr_en = '1' and count < DEPTH;
        do_rd := rd_en = '1' and count > 0;
        if do_wr then
          memory(windex) <= din;
          windex <= (windex + 1) mod DEPTH;
        end if;
        if do_rd then
          rindex <= (rindex + 1) mod DEPTH;
        end if;
        if do_wr and not do_rd then
          count <= count + 1;
        elsif do_rd and not do_wr then
          count <= count - 1;
        end if;
      end if;
    end if;
  end process;
  dout  <= memory(rindex);
  empty <= '1' when count = 0 else '0';
  full  <= '1' when count = DEPTH else '0';
end architecture behav;
```
Die Variablen `do_wr`/`do_rd` werden zuerst geschrieben, dann gelesen → **keine** Flipflops (D04).
</details>

## Klausur
**Herbst 2019, Aufgabe 2** (synchroner FIFO: Entity, `memory_type`, `windex`/`rindex` nach jeder Flanke).
