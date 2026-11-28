# P01 · Vom Aufgabentext zum fertigen Automaten

6 min · zurück: [K06](K06_crc_rom.md) · weiter: [P02](P02_getraenk_entwurf.md)

## Ziel
Ein festes Vorgehen kennen, mit dem du jede Automaten-Aufgabe von leerem Blatt bis zum fertigen Code löst.

## Erklärung
In Block P programmierst du alles **selbst**: keine Lückentexte, sondern ganze Entities und Architectures – so wie in der Klausur. Jede Aufgabe löst du in diesen Schritten:

1. **Schnittstelle**: Welche Eingänge, welche Ausgänge, welche Breiten? Daraus die `entity` (mit `clk`, `res_n`).
2. **Zustände**: Was muss sich der Automat merken? Jede unterscheidbare „Situation“ wird ein Zustand. Namen sprechend wählen (`g1` = 1 Euro eingeworfen).
3. **Übergänge**: Für jeden Zustand: Bei welcher Eingabe geht es wohin? Fehlt eine Angabe, **bleibt** er im Zustand.
4. **Ausgänge**: Hängen sie nur vom Zustand ab (**Moore**) oder auch von den Eingängen (**Mealy**)?
5. **Zusatzspeicher**: Zähler, Register, Timer – alles, was mehr als „wo bin ich“ ist, als eigenes Signal im getakteten Prozess.
6. **Code** nach Schema: `transition_function`, `state`, `output_function`.
7. **Testbench**: jede Kante im Zustandsdiagramm mindestens einmal durchlaufen.

Typische Fehler, die Punkte kosten:
- Vergessene Signale in der Sensitivitätsliste der kombinatorischen Prozesse.
- Kein Default (`next_state <= current_state;`, Ausgänge auf `'0'`) → Latches.
- Zustand im kombinatorischen Prozess „hochzählen“ – Zähler gehören in den getakteten Prozess.

## Aufgabe
Ein Getränkeautomat verkauft ein Getränk für **3 Euro**. Er nimmt 1- und 2-Euro-Münzen an (Eingänge `m1`, `m2`, je einen Takt lang `'1'`). Sind 3 Euro erreicht, gibt er einen Takt lang `ausgabe = '1'` aus; bei 4 Euro zusätzlich `rueckgeld = '1'` (1 Euro zurück).

Schritt 1–4 auf Papier: Welche Zustände brauchst du? Ist das Moore oder Mealy?

<details><summary>Lösung</summary>

Zustände nach eingeworfenem Betrag:
- `g0`: 0 Euro, `g1`: 1 Euro, `g2`: 2 Euro
- `aus`: Getränk wird ausgegeben (3 Euro)
- `aus_r`: Getränk und Rückgeld (4 Euro)

Fünf Zustände. Die Ausgänge hängen nur vom Zustand ab (`ausgabe = '1'` in `aus` und `aus_r`) → **Moore**. Nach `aus`/`aus_r` geht es im nächsten Takt zurück nach `g0`.
</details>

## Klausur
Fast jede Klausur hat eine Automaten- oder Steuerwerksaufgabe, z.B. F24 A1 (Steuerwerk, siehe K02) und F19 A1 (serieller Empfänger, ab P11).
