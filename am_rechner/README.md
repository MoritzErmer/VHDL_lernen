# Am Rechner üben

Die Häppchen kannst du komplett am Handy lernen. Wenn du an einem Rechner
sitzt, kannst du hier Code **abtippen und wirklich simulieren** – das festigt
die Syntax enorm.

## Variante 1: im Browser (nichts installieren)
1. <https://www.edaplayground.com> öffnen (kostenloser Login).
2. Links „Testbench + Design“ → *Languages*: **VHDL**, *Tools*: **GHDL** (oder Aldec Riviera).
3. Rechts (`design.vhd`) die Komponente einfügen, links (`testbench.vhd`) die Testbench.
4. *Top entity*: Name der Testbench (z.B. `tb_halbaddierer`) → **Run**.

## Variante 2: lokal mit GHDL
GHDL installieren (Linux: `sudo apt install ghdl`, Windows/Mac: siehe
<https://github.com/ghdl/ghdl/releases>), dann im Repo-Ordner:
```bash
./sim.sh tb_halbaddierer am_rechner/L01/halbaddierer.vhd am_rechner/L01/tb_halbaddierer.vhd
```
Dateien in Abhängigkeits-Reihenfolge angeben (erst Bausteine, dann Testbench).
Wellenform ansehen: `gtkwave build/tb_halbaddierer/tb_halbaddierer.ghw`.

Alles auf einmal testen: `./am_rechner/alle_testen.sh`

## So übst du am besten
1. Komponente **selbst abtippen** in `meine_dateien/` (nicht kopieren!).
2. Mit der fertigen Testbench aus `am_rechner/` simulieren.
3. Fehlermeldung? Erst selbst suchen, dann mit der Datei hier vergleichen.

| Ordner | passt zu Häppchen | Inhalt |
|---|---|---|
| `L01` | A01–A03 | UND-Gatter, Halb-/Volladdierer |
| `L02` | A05, E2 | Vektoren, `numeric_std`-Rechner |
| `L03` | B01–B02 | Multiplexer, 7-Segment, Prioritätsencoder |
| `L04` | C02–C08 | Signal vs. Variable, ALU, Popcount |
| `L05` | D01, D07 | D-Flipflop, Flankenerkennung |
| `L07` | F02–F09 | Sequenzdetektor als Moore/Mealy/Medwedew, Garagentor |
| `L08` | G01–G06 | Volladdierer aus Halbaddierern, `generate`, rekursiver Encoder |
| `L10` | L01–L12 | Gatterbibliothek, Schaltpläne als behav und struct, Modularisierung |
| `L11` | M01–M10 | Register, Schieberegister, Zähler, Taktteiler, Entpreller, PWM, FIFO, RAM, Ampel, serieller Sender |
| `L09` | K01–K06 | Klausurlösungen F24 (CRC, Steuerwerk, ROM), H19, F20 |
| `L12` | P01–P18 | Projekte: Getränkeautomat, Codeschloss, Tastatur-Controller (F20), Empfänger (F19), Dividierwerk (F22), Oszillator und ROM (F23), Stack und Kellerautomat (F24) |
