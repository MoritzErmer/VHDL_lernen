# W09 · SPI-Master

20 min · zurück: [W08](W08_uart_rx.md) · weiter: [W10](W10_ggt.md)

## Ziel
Einen Master für eine synchrone serielle Schnittstelle schreiben, der gleichzeitig sendet und empfängt.

## Erklärung
SPI (Modus 0) verbindet z.B. Sensoren:
- `cs_n` geht während der Übertragung auf `'0'`.
- `sclk` ist in Ruhe `'0'`. 8 Takte lang: `mosi` liegt an, bei der **steigenden** Flanke von `sclk` lesen beide Seiten ein, bei der **fallenden** kommt das nächste Bit.
- MSB zuerst. Gleichzeitig kommt vom Slave ein Byte über `miso` zurück.

Ports und Generics:
- Generic `TEILER : positive := 25` (Systemtakte pro **halber** `sclk`-Periode, 1 MHz bei 50 MHz)
- `clk`, `res_n`, `start : in std_logic`, `tx_daten : in std_logic_vector(7 downto 0)`
- `rx_daten : out std_logic_vector(7 downto 0)`, `busy : out std_logic`
- `sclk`, `mosi`, `cs_n : out std_logic`, `miso : in std_logic`

Bausteine: Teiler, internes `sclk_i`, Bitzähler, Sende- und Empfangsschieberegister.

## Aufgabe
Schreibe Entity `spi_master` und Architecture `behav`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity spi_master is
  generic(TEILER : positive := 25);        -- Takte pro halber SCLK-Periode
  port(
    clk, res_n : in  std_logic;
    start      : in  std_logic;
    tx_daten   : in  std_logic_vector(7 downto 0);
    rx_daten   : out std_logic_vector(7 downto 0);
    busy       : out std_logic;
    sclk, mosi, cs_n : out std_logic;
    miso       : in  std_logic
    );
end entity spi_master;

architecture behav of spi_master is
  signal aktiv : std_logic;
  signal zaehler : natural range 0 to TEILER - 1;
  signal sclk_i : std_logic;
  signal bitnr : natural range 0 to 7;
  signal sr_tx, sr_rx : std_logic_vector(7 downto 0);
begin
  process(clk, res_n) is
  begin
    if res_n = '0' then
      aktiv <= '0'; zaehler <= 0; sclk_i <= '0'; bitnr <= 0;
      sr_tx <= (others => '0'); sr_rx <= (others => '0');
      rx_daten <= (others => '0');
    else
      if clk'event and clk = '1' then
        if aktiv = '0' then
          if start = '1' then
            aktiv <= '1';
            sr_tx <= tx_daten;
            zaehler <= 0;
            bitnr <= 0;
            sclk_i <= '0';
          end if;
        elsif zaehler = TEILER - 1 then
          zaehler <= 0;
          if sclk_i = '0' then                 -- steigende Flanke: einlesen
            sclk_i <= '1';
            sr_rx <= sr_rx(6 downto 0) & miso;
          else                                  -- fallende Flanke: naechstes Bit
            sclk_i <= '0';
            if bitnr = 7 then
              aktiv <= '0';
              rx_daten <= sr_rx;
            else
              bitnr <= bitnr + 1;
              sr_tx <= sr_tx(6 downto 0) & '0';
            end if;
          end if;
        else
          zaehler <= zaehler + 1;
        end if;
      end if;
    end if;
  end process;
  sclk <= sclk_i;
  mosi <= sr_tx(7);                             -- MSB zuerst
  cs_n <= not aktiv;
  busy <= aktiv;
end architecture behav;
```
`mosi` ist einfach das oberste Bit des Senderegisters. Geschoben wird nur bei der fallenden Flanke von `sclk`, deshalb ist das Bit bei der steigenden Flanke stabil.
</details>

## Klausur
Schieberegister (M02), Taktteiler (M04), Sender (M10).
