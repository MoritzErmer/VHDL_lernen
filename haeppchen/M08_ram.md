# M08 · RAM und Registerbank

5 min · zurück: [M07](M07_fifo.md) · weiter: [M09](M09_ampel_timer.md)

## Ziel
Einen beschreibbaren Speicher modellieren und seine Kapazität berechnen.

## Erklärung
Ein RAM ist ein Array (E04), das **synchron geschrieben** und hier **asynchron gelesen** wird:
- Schreiben nur bei steigender Flanke und `we = '1'`
- Lesen kombinatorisch: `dout <= memory(addr)`
- Kapazität: 2^ADDR_WIDTH Wörter · DATA_WIDTH Bit (E05)

Eine **Registerbank** im Prozessor ist dasselbe, nur mit mehreren Leseports.

```vhdl
entity ram is
  generic(ADDR_WIDTH : natural := 3; DATA_WIDTH : positive := 8);
  port(
    clk  : in  std_logic;
    we   : in  std_logic;
    addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    din  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    dout : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity ram;
```

## Aufgabe
1. Schreibe `architecture behav` (braucht `numeric_std`).
2. Kapazität für `ADDR_WIDTH = 10`, `DATA_WIDTH = 16`?

<details><summary>Lösung</summary>

```vhdl
architecture behav of ram is
  type memory_type is array (0 to 2**ADDR_WIDTH - 1)
    of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal memory : memory_type;
begin
  process(clk) is
  begin
    if clk'event and clk = '1' then
      if we = '1' then
        memory(to_integer(unsigned(addr))) <= din;
      end if;
    end if;
  end process;
  dout <= memory(to_integer(unsigned(addr)));
end architecture behav;
```
2. 2^10 · 16 = **16 384 Bit** (2 KiB).
Kein Reset: Speicher werden in Hardware nicht gelöscht (zu teuer).
</details>

## Klausur
**F19 A2 F5–F7** (`ram` mit `ADDR_WIDTH`, `DATA_WIDTH`, Lesemultiplexer), F24 A2 F10 (Stack).
