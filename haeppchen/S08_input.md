# S08 · Senso: Eingabeeinheit mit vier Tastern

8 min · zurück: [S07](S07_button_testen.md) · weiter: [S09](S09_lfsr_verstehen.md)

## Ziel
Eine Komponente mehrfach mit `for … generate` instanziieren und die Ausgänge zusammenfassen.

## Erklärung
Die Eingabeeinheit `input` fasst vier Taster zusammen:
- `key_valid`: einen Takt `'1'`, wenn **irgendeine** Taste gedrückt wurde.
- `key_color`: Nummer der gedrückten Taste (`"00"` rot, `"01"` blau, `"10"` gelb, `"11"` grün).

```vhdl
entity input is
  port(
    clk, res_n : in  std_logic;
    key_in_n   : in  std_logic_vector(3 downto 0);
    key_valid  : out std_logic;
    key_color  : out std_logic_vector(1 downto 0)
    );
end entity input;
```

Bausteine:
- 4 × `button` per `for … generate` (G05), Ausgänge in einem Vektor `keys(3 downto 0)`.
- `key_valid`: ODER über alle `keys`.
- `key_color`: Prioritätsencoder mit `when … else` (B01), falls doch zwei Tasten gleichzeitig kommen.

Weil hier Struktur (Instanzen) und Verhalten (Zuweisungen) gemischt sind, heißt die Architecture `mixed`.

## Aufgabe
Schreibe `architecture mixed of input`.

<details><summary>Lösung</summary>

```vhdl
architecture mixed of input is
  signal keys : std_logic_vector(3 downto 0);
begin
  buttons: for i in 0 to 3 generate
    b: entity work.button
      port map(clk => clk, res_n => res_n,
               tx_n => key_in_n(i), key => keys(i));
  end generate buttons;

  key_valid <= keys(0) or keys(1) or keys(2) or keys(3);

  key_color <= "11" when keys(3) = '1' else
               "10" when keys(2) = '1' else
               "01" when keys(1) = '1' else
               "00";
end architecture mixed;
```
`key_color` ist nur gültig, solange `key_valid = '1'` ist. Ohne Tastendruck steht dort `"00"`, das ignoriert die Steuerung.
</details>

## Klausur
`generate` und Instanzen (G05, L10). Strukturbeschreibung mit Zusatzlogik wie in F20 A2 (P10).
