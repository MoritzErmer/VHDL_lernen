# VHDL lernen – in 5-Minuten-Häppchen

Für die Klausur **Entwurf digitaler Systeme** (Uni Stuttgart, IKR).
Code-Stil exakt wie im Skript (`clk'event and clk = '1'`, Reset `res_n`,
`end entity …;`, Automaten mit `transition_function` / `state` / `output_function`).

## So funktioniert's
Jedes Häppchen dauert **4–6 Minuten** und passt auf den Handy-Bildschirm:

1. 🎯 **Ziel** – was du danach kannst
2. 📖 **Erklärung** – kurz, mit Beispielcode
3. ✍️ **Aufgabe** – im Kopf, auf Papier oder in der Notizen-App lösen
4. ✅ **Lösung** – erst aufklappen, wenn du eine eigene Antwort hast!
5. 🎓 **Klausur** – wo genau das schon abgefragt wurde

Klausur-Kürzel: **F24** = Frühjahr 2024, **H19** = Herbst 2019, usw.
Tipp: Mach die Aufgabe eines Häppchens am nächsten Tag **nochmal ohne
Erklärung** – Wiederholung ist der eigentliche Lerneffekt.

---

## 🧱 Block A – Grundgerüst
| | Häppchen | Inhalt |
|---|---|---|
| A01 | [VHDL beschreibt Hardware](haeppchen/A01_hardware_denken.md) | Entity/Architecture, nebenläufig |
| A02 | [Die Entity](haeppchen/A02_entity.md) | Ports, Richtungen, `;`-Regel |
| A03 | [Die Architecture](haeppchen/A03_architecture.md) | Schaltbild → Code |
| A04 | [std_logic](haeppchen/A04_std_logic.md) | 9 Werte, `'U'`, `'-'` |
| A05 | [Vektoren](haeppchen/A05_vektoren.md) | Index, Slice, `&`, `others` |
| A06 | [Syntax-Fallen](haeppchen/A06_fallen_library.md) | Fehlersuche |

## 🔀 Block B – Nebenläufige Anweisungen
| | Häppchen | Inhalt |
|---|---|---|
| B01 | [when … else](haeppchen/B01_when_else.md) | Priorität |
| B02 | [with … select](haeppchen/B02_with_select.md) | Mux, Decoder |
| B03 | [Versteckter Prozess](haeppchen/B03_versteckter_prozess.md) | Äquivalenz zum Prozess |
| B04 | [Ein Signal – ein Treiber](haeppchen/B04_mehrfachtreiber.md) | Mehrfachtreiber |

## ⚙️ Block C – Prozesse (das Herzstück!)
| | Häppchen | Inhalt |
|---|---|---|
| C01 | [Aufbau eines Prozesses](haeppchen/C01_prozess_aufbau.md) | Sensitivitätsliste, Simulationsstart |
| C02 | [Signale im Prozess](haeppchen/C02_signal_im_prozess.md) | vorgemerkt, letzte gewinnt |
| C03 | [Variablen](haeppchen/C03_variablen.md) | `:=` vs `<=` |
| C04 | [Delta-Zyklen](haeppchen/C04_delta_zyklen.md) | `wait for 0 ns` |
| C05 | [if und case](haeppchen/C05_if_case.md) | Syntax sicher |
| C06 | [Latch-Falle](haeppchen/C06_latch_falle.md) | 2 Regeln für Kombinatorik |
| C07 | [for-Schleife](haeppchen/C07_for_schleife.md) | abgerollte Hardware |
| C08 | [Variablen in Schleifen](haeppchen/C08_variable_akkumulator.md) | Akkumulator-Muster |

## ⏱️ Block D – Getaktete Logik
| | Häppchen | Inhalt |
|---|---|---|
| D01 | [Flipflop-Template](haeppchen/D01_flipflop.md) | asynchroner Reset |
| D02 | [Enable & Clear](haeppchen/D02_enable_clear.md) | synchron vs. asynchron |
| D03 | [Zähler](haeppchen/D03_zaehler.md) | `unsigned` / `integer` |
| D04 | [Flipflops zählen](haeppchen/D04_flipflops_zaehlen.md) | ⭐ Klausur-Favorit |
| D05 | [Synchronisierer](haeppchen/D05_synchronisierer.md) | Metastabilität |
| D06 | [Von Hand simulieren](haeppchen/D06_von_hand_simulieren.md) | Werte nach jeder Flanke |
| D07 | [Flankenerkennung](haeppchen/D07_flankenerkennung.md) | Puls aus Tastendruck |

## 🔜 Als Nächstes geplant
- **E – Typen:** integer/natural/positive, `numeric_std`-Umwandlungen,
  Aufzählungstypen, Arrays & ROM, Records, Attribute, named/positional association
- **F – Automaten:** Mealy/Moore/Medwedew erkennen & begründen, 3-Prozess-Template,
  Steuerwerk + Rechenwerk, Zustandstabelle als Array, Diagramm aus Code
- **G – Struktur:** Instanziierung, Testbench-Entity & `struct`, Generics,
  `for/if generate`, rekursive Komponenten
- **H – Unterprogramme:** Funktionen, Prozeduren, Packages, Operator-Überladung
- **I – Testbenches:** `wait`, `assert`, Takt-/Reset-Generator, `'transaction`
- **J – Synthese-Fragen:** synthetisierbar?, kritischer Pfad, Speicherkapazität
- **K – Klausur-Training:** komplette Klausuraufgaben in Häppchen zerlegt

---

💻 **Am Rechner üben:** siehe [am_rechner/](am_rechner/README.md) –
getestete Beispiele mit Testbenches zum Abtippen und Simulieren.
Deine eigenen Dateien kommen nach `meine_dateien/`.
