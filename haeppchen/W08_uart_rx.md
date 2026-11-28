# W08 · UART-Empfänger mit Parität

25 min · zurück: [W07](W07_reaktionstester.md) · weiter: [W09](W09_spi_master.md)

## Ziel
Einen seriellen Empfänger nach echtem UART-Standard mit Fehlererkennung schreiben.

## Erklärung
Standard-UART, wie ihn jeder PC spricht:
- Ruhe `'1'`, **Startbit `'0'`**, 8 Datenbits LSB zuerst, **Paritätsbit** (gerade Parität: Daten und Paritätsbit haben zusammen eine gerade Anzahl Einsen), **Stoppbit `'1'`**.
- Jedes Bit dauert `TAKTE_PRO_BIT` Takte (Generic, 434 für 115 200 Baud bei 50 MHz).

Anforderungen:
- `rx` synchronisieren (zwei Flipflops).
- Nach der fallenden Flanke bis zur **Mitte** des Startbits warten und prüfen, ob es noch `'0'` ist. Sonst war es eine Störung → zurück in Ruhe.
- Dann jedes Bit in seiner Mitte abtasten.
- Am Ende einen Takt `gueltig = '1'`, dazu `daten`, `par_fehler` (Parität falsch) und `rahmen_fehler` (Stoppbit war `'0'`).

Ports: `clk`, `res_n`, `rx : in std_logic`, `daten : out std_logic_vector(7 downto 0)`, `gueltig`, `par_fehler`, `rahmen_fehler : out std_logic`.

## Aufgabe
Schreibe Entity `uart_rx` und Architecture `behav` mit einem getakteten Prozess und den Zuständen `ruhe`, `start`, `empfang`.

<details><summary>Lösung</summary>

```vhdl
library ieee; use ieee.std_logic_1164.all;
entity uart_rx is
  generic(TAKTE_PRO_BIT : positive := 434);    -- 50 MHz / 115200 Baud
  port(
    clk, res_n : in  std_logic;
    rx         : in  std_logic;    -- Ruhe '1', Start '0', 8 Daten LSB zuerst, gerade Paritaet, Stopp '1'
    daten      : out std_logic_vector(7 downto 0);
    gueltig    : out std_logic;    -- ein Takt, wenn ein Byte fertig ist
    par_fehler : out std_logic;    -- gilt zusammen mit gueltig
    rahmen_fehler : out std_logic
    );
end entity uart_rx;

architecture behav of uart_rx is
  type state_type is (ruhe, start, empfang);
  signal state : state_type;
  signal rx_d, rx_dd : std_logic;
  signal teiler : natural range 0 to TAKTE_PRO_BIT - 1;
  signal bitnr  : natural range 0 to 9;            -- 0..7 Daten, 8 Paritaet, 9 Stopp
  signal sr     : std_logic_vector(8 downto 0);    -- Paritaet & Daten
begin
  process(clk, res_n) is
    variable p : std_logic;
  begin
    if res_n = '0' then
      state <= ruhe; rx_d <= '1'; rx_dd <= '1';
      teiler <= 0; bitnr <= 0; sr <= (others => '0');
      gueltig <= '0'; par_fehler <= '0'; rahmen_fehler <= '0';
      daten <= (others => '0');
    else
      if clk'event and clk = '1' then
        rx_d <= rx;
        rx_dd <= rx_d;
        gueltig <= '0';
        case state is
          when ruhe =>
            if rx_dd = '0' then
              state <= start;
              teiler <= 0;
            end if;
          when start =>                         -- bis zur Mitte des Startbits
            if teiler = TAKTE_PRO_BIT / 2 - 1 then
              teiler <= 0;
              if rx_dd = '0' then
                state <= empfang;
                bitnr <= 0;
              else
                state <= ruhe;                  -- nur ein Stoerimpuls
              end if;
            else
              teiler <= teiler + 1;
            end if;
          when empfang =>
            if teiler = TAKTE_PRO_BIT - 1 then
              teiler <= 0;
              if bitnr = 9 then                 -- Stoppbit
                state <= ruhe;
                daten <= sr(7 downto 0);
                p := '0';
                for i in 0 to 8 loop
                  p := p xor sr(i);
                end loop;
                par_fehler <= p;                -- gerade Paritaet: xor ueber alles = 0
                rahmen_fehler <= not rx_dd;
                gueltig <= '1';
              else
                sr <= rx_dd & sr(8 downto 1);
                bitnr <= bitnr + 1;
              end if;
            else
              teiler <= teiler + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture behav;
```
Die Parität prüft eine Schleife mit einer Variablen: XOR über alle 9 Bits muss `'0'` ergeben. Vergleiche mit dem Empfänger aus F19 (P12): andere Polarität, dafür Start-Prüfung und Fehlerbits.
</details>

## Klausur
Serielle Schnittstellen (F19 A1, P11/P12, M10), XOR-Schleife (C08).
