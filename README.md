# VHDL lernen – in 5-Minuten-Häppchen

Für die Klausur **Entwurf digitaler Systeme** (Uni Stuttgart, IKR).
Code-Stil exakt wie im Skript (`clk'event and clk = '1'`, Reset `res_n`,
`end entity …;`, Automaten mit `transition_function` / `state` / `output_function`).

## Als Handy-App: Lern-Häppchen
Alle Häppchen gibt es als Android-App – zusammen mit dem Fach **Rechnerarchitektur**
([Rechnerarchtektur_Lernen](https://github.com/MoritzErmer/Rechnerarchtektur_Lernen)):

- **Offline** von Anfang an, neue Inhalte lädt die App automatisch im **WLAN**
- Editor mit **Syntax-Highlighting** (VHDL und IKR-Assembler) und Sondertasten (`<=`, `:=`, `=>`, …)
- **Abgleich** deiner Lösung mit der Musterlösung, Selbsteinschätzung als `1` / `X` / `0`
- **Export** deiner Antworten und Fragen, um sie im Chat mit Claude durchzusprechen
- Hell- und Dunkelmodus

**Installieren:** unter [Releases](https://github.com/MoritzErmer/VHDL_lernen/releases/latest) die
`Lern-Haeppchen-….apk` auf dem Handy öffnen. Quellcode in [`app/`](app/), Screenshots in [`docs/screenshots/`](docs/screenshots/).

## So funktioniert's
Jedes Häppchen dauert **4–6 Minuten** und passt auf den Handy-Bildschirm:

1. **Ziel** – was du danach kannst
2. **Erklärung** – kurz, mit Beispielcode
3. **Aufgabe** – im Kopf, auf Papier oder in der Notizen-App lösen
4. **Lösung** – erst aufklappen, wenn du eine eigene Antwort hast!
5. **Klausur** – wo genau das schon abgefragt wurde

Klausur-Kürzel: **F24** = Frühjahr 2024, **H19** = Herbst 2019, usw.
Tipp: Mach die Aufgabe eines Häppchens am nächsten Tag **nochmal ohne
Erklärung** – Wiederholung ist der eigentliche Lerneffekt.

---

## Block A – Grundgerüst
| | Häppchen | Inhalt |
|---|---|---|
| A01 | [VHDL beschreibt Hardware](haeppchen/A01_hardware_denken.md) | Entity/Architecture, nebenläufig |
| A02 | [Die Entity](haeppchen/A02_entity.md) | Ports, Richtungen, `;`-Regel |
| A03 | [Die Architecture](haeppchen/A03_architecture.md) | Schaltbild → Code |
| A04 | [std_logic](haeppchen/A04_std_logic.md) | 9 Werte, `'U'`, `'-'` |
| A05 | [Vektoren](haeppchen/A05_vektoren.md) | Index, Slice, `&`, `and`, `others` |
| A06 | [Syntax-Fallen](haeppchen/A06_fallen_library.md) | Fehlersuche |

## Block B – Nebenläufige Anweisungen
| | Häppchen | Inhalt |
|---|---|---|
| B01 | [when … else](haeppchen/B01_when_else.md) | Priorität |
| B02 | [with … select](haeppchen/B02_with_select.md) | Mux, Decoder |
| B03 | [Versteckter Prozess](haeppchen/B03_versteckter_prozess.md) | Äquivalenz zum Prozess |
| B04 | [Ein Signal – ein Treiber](haeppchen/B04_mehrfachtreiber.md) | Mehrfachtreiber |

## Block C – Prozesse (das Herzstück!)
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

## Block D – Getaktete Logik
| | Häppchen | Inhalt |
|---|---|---|
| D01 | [Flipflop-Template](haeppchen/D01_flipflop.md) | asynchroner Reset |
| D02 | [Enable & Clear](haeppchen/D02_enable_clear.md) | synchron vs. asynchron |
| D03 | [Zähler](haeppchen/D03_zaehler.md) | `unsigned` / `integer` |
| D04 | [Flipflops zählen](haeppchen/D04_flipflops_zaehlen.md) | Klausur-Favorit |
| D05 | [Synchronisierer](haeppchen/D05_synchronisierer.md) | Metastabilität |
| D06 | [Von Hand simulieren](haeppchen/D06_von_hand_simulieren.md) | Werte nach jeder Flanke |
| D07 | [Flankenerkennung](haeppchen/D07_flankenerkennung.md) | Puls aus Tastendruck |

## Block E – Typen & Arrays
| | Häppchen | Dauer |
|---|---|---|
| E01 | [integer, natural, positive, subtype](haeppchen/E01_integer_subtypes.md) | 5 min |
| E02 | [Umwandlungen mit numeric_std](haeppchen/E02_umwandlungen.md) | 6 min |
| E03 | [Aufzählungstypen](haeppchen/E03_aufzaehlungstypen.md) | 5 min |
| E04 | [Eigene Array-Typen](haeppchen/E04_arrays.md) | 6 min |
| E05 | [ROM als konstantes Array](haeppchen/E05_rom.md) | 6 min |
| E06 | [Records](haeppchen/E06_records.md) | 4 min |
| E07 | [Positional vs. named association](haeppchen/E07_aggregate.md) | 4 min |
| E08 | [Attribute](haeppchen/E08_attribute.md) | 5 min |

## Block F – Automaten
| | Häppchen | Dauer |
|---|---|---|
| F01 | [Mealy, Moore, Medwedew](haeppchen/F01_automatentypen.md) | 5 min |
| F02 | [Das 3-Prozess-Template (Moore)](haeppchen/F02_moore_template.md) | 7 min |
| F03 | [Mealy-Automat](haeppchen/F03_mealy.md) | 6 min |
| F04 | [Medwedew: Ausgang aus dem Register](haeppchen/F04_medwedew.md) | 5 min |
| F05 | [Defaults im Automaten](haeppchen/F05_defaults.md) | 5 min |
| F06 | [Steuerwerk + Rechenwerk](haeppchen/F06_steuerwerk.md) | 7 min |
| F07 | [Zustandstabelle als Array](haeppchen/F07_tabelle_als_array.md) | 6 min |
| F08 | [Selbst entwerfen: Garagentor](haeppchen/F08_entwurf_garagentor.md) | 8 min |
| F09 | [Verhalten aus Code ablesen](haeppchen/F09_verhalten_ablesen.md) | 6 min |

## Block G – Strukturbeschreibung
| | Häppchen | Dauer |
|---|---|---|
| G01 | [Komponenten instanziieren](haeppchen/G01_instanziierung.md) | 6 min |
| G02 | [component-Deklaration & positional](haeppchen/G02_component.md) | 4 min |
| G03 | [Testbench als Strukturbeschreibung](haeppchen/G03_testbench_struct.md) | 6 min |
| G04 | [Generics](haeppchen/G04_generics.md) | 6 min |
| G05 | [for-generate](haeppchen/G05_for_generate.md) | 6 min |
| G06 | [if-generate & Rekursion](haeppchen/G06_if_generate_rekursion.md) | 7 min |

## Block L – Vom Schaltplan zum Code
| | Häppchen | Dauer |
|---|---|---|
| L01 | [Schaltpläne lesen: DIN-Symbole](haeppchen/L01_din_symbole.md) | 5 min |
| L02 | [behav, struct, mixed: der Unterschied](haeppchen/L02_behav_struct.md) | 6 min |
| L03 | [Vom Schaltplan zur Verhaltensbeschreibung](haeppchen/L03_plan_zu_behav.md) | 6 min |
| L04 | [Vom Schaltplan zur Strukturbeschreibung](haeppchen/L04_plan_zu_struct.md) | 7 min |
| L05 | [Signale sind Leitungen](haeppchen/L05_signale_leitungen.md) | 6 min |
| L06 | [Vom Text über den Plan zum Code](haeppchen/L06_text_plan_code.md) | 7 min |
| L07 | [Hierarchie: Module aus Modulen](haeppchen/L07_hierarchie.md) | 7 min |
| L08 | [Multiplexer: Gatter, Verhalten, Baustein](haeppchen/L08_multiplexer.md) | 8 min |
| L09 | [Schaltpläne mit Flipflops](haeppchen/L09_getaktete_plaene.md) | 8 min |
| L10 | [Modularisieren: ein System schneiden](haeppchen/L10_modularisieren.md) | 8 min |
| L11 | [Verdrahtungsfehler finden](haeppchen/L11_verdrahtungsfehler.md) | 6 min |
| L12 | [Klausurtraining: Plan komplett umsetzen](haeppchen/L12_klausur_schaltplan.md) | 9 min |

## Block M – Standardbausteine selbst bauen
| | Häppchen | Dauer |
|---|---|---|
| M01 | [Register mit Enable und Löschen](haeppchen/M01_register.md) | 5 min |
| M02 | [Schieberegister: seriell und parallel](haeppchen/M02_schieberegister.md) | 6 min |
| M03 | [Modulo-Zähler mit Übertrag](haeppchen/M03_zaehler_modulo.md) | 5 min |
| M04 | [Taktteiler als Enable-Puls](haeppchen/M04_taktteiler.md) | 5 min |
| M05 | [Entpreller](haeppchen/M05_entpreller.md) | 6 min |
| M06 | [PWM-Generator](haeppchen/M06_pwm.md) | 4 min |
| M07 | [Synchroner FIFO](haeppchen/M07_fifo.md) | 9 min |
| M08 | [RAM und Registerbank](haeppchen/M08_ram.md) | 5 min |
| M09 | [Automat mit Timer: Ampel](haeppchen/M09_ampel_timer.md) | 8 min |
| M10 | [Serieller Sender: alles zusammen](haeppchen/M10_sender.md) | 10 min |

## Block H – Funktionen, Prozeduren, Packages
| | Häppchen | Dauer |
|---|---|---|
| H01 | [Funktionen](haeppchen/H01_funktionen.md) | 6 min |
| H02 | [Prozeduren](haeppchen/H02_prozeduren.md) | 6 min |
| H03 | [Wo wird was deklariert?](haeppchen/H03_wo_deklarieren.md) | 4 min |
| H04 | [Packages](haeppchen/H04_packages.md) | 6 min |
| H05 | [Operatoren überladen](haeppchen/H05_operatoren.md) | 5 min |
| H06 | [ROM per Funktion vorberechnen](haeppchen/H06_rom_init_funktion.md) | 7 min |

## Block I – Testbenches
| | Häppchen | Dauer |
|---|---|---|
| I01 | [Takt- und Reset-Generator](haeppchen/I01_takt_reset.md) | 5 min |
| I02 | [Die vier wait-Formen](haeppchen/I02_wait.md) | 4 min |
| I03 | [assert und erschöpfender Test](haeppchen/I03_assert_test.md) | 6 min |
| I04 | [Simulationszeiten berechnen](haeppchen/I04_simulationszeit.md) | 4 min |
| I05 | [Stimuli nicht auf die Flanke legen](haeppchen/I05_flanken_race.md) | 5 min |
| I06 | [Event vs. Transaction](haeppchen/I06_event_transaction.md) | 5 min |

## Block J – Synthesefragen
| | Häppchen | Dauer |
|---|---|---|
| J01 | [Synthetisierbar oder nicht?](haeppchen/J01_synthetisierbar.md) | 5 min |
| J02 | [Kritischer Pfad](haeppchen/J02_kritischer_pfad.md) | 6 min |
| J03 | [Hardware-Aufwand von Operatoren](haeppchen/J03_aufwand.md) | 5 min |
| J04 | [Funktionale vs. Timing-Simulation](haeppchen/J04_simulationsarten.md) | 3 min |
| J05 | [Namen und Schreibweise](haeppchen/J05_namen_fallen.md) | 3 min |

## Block K – Klausurtraining
| | Häppchen | Dauer |
|---|---|---|
| K01 | [Klausur F24: CRC-Rechenwerk](haeppchen/K01_crc_register.md) | 8 min |
| K02 | [Klausur F24: Steuerwerk](haeppchen/K02_crc_steuerwerk.md) | 8 min |
| K03 | [Klausur H19: 8-Bit-Prioritätsencoder](haeppchen/K03_prio_encoder_8bit.md) | 7 min |
| K04 | [Klausur F20: Multiplizierer mit Schleife](haeppchen/K04_multiplizierer.md) | 9 min |
| K05 | [Klausur F20: Volladdierer mit „+“](haeppchen/K05_volladdierer_unsigned.md) | 5 min |
| K06 | [Klausur F24: CRC per ROM](haeppchen/K06_crc_rom.md) | 10 min |

## Block P – Projekte im Klausurstil
Komplett selbst programmieren: Automaten, Steuer- und Rechenwerke, nach Altklausuren (F19, F20, F22, F23, F24) aufgebaut.

| | Häppchen | Dauer |
|---|---|---|
| P01 | [Vom Aufgabentext zum fertigen Automaten](haeppchen/P01_projekt_rezept.md) | 6 min |
| P02 | [Getränkeautomat: Zustandsdiagramm und Entity](haeppchen/P02_getraenk_entwurf.md) | 7 min |
| P03 | [Getränkeautomat: Architecture komplett](haeppchen/P03_getraenk_code.md) | 10 min |
| P04 | [Getränkeautomat: Testbench selbst schreiben](haeppchen/P04_getraenk_testbench.md) | 8 min |
| P05 | [Codeschloss: Entwurf mit Zählern](haeppchen/P05_codeschloss_entwurf.md) | 8 min |
| P06 | [Codeschloss: Architecture komplett](haeppchen/P06_codeschloss_code.md) | 12 min |
| P07 | [Klausur F20: Tastatur-Controller – Decoder und Multiplexer](haeppchen/P07_tastatur_decoder_mux.md) | 8 min |
| P08 | [Klausur F20: Binärzähler mit Freigabe](haeppchen/P08_tastatur_zaehler.md) | 6 min |
| P09 | [Klausur F20: Tastenspeicher mit 2D-Array](haeppchen/P09_tastatur_speicher.md) | 8 min |
| P10 | [Klausur F20: Tastatur-Controller verdrahten](haeppchen/P10_tastatur_top.md) | 9 min |
| P11 | [Klausur F19: Serieller Rahmen und Sende-Prozedur](haeppchen/P11_empfaenger_rahmen.md) | 8 min |
| P12 | [Klausur F19: Serieller Empfänger](haeppchen/P12_empfaenger_code.md) | 12 min |
| P13 | [Klausur F22: Ein Divisionsschritt als Prozedur](haeppchen/P13_divstep.md) | 10 min |
| P14 | [Klausur F22: N-schrittiges Dividierwerk mit valid](haeppchen/P14_dividierwerk.md) | 10 min |
| P15 | [Klausur F23: Ton-Oszillator](haeppchen/P15_oszillator.md) | 9 min |
| P16 | [Klausur F23: Perioden-ROM und Synthesizer verdrahten](haeppchen/P16_perioden_rom.md) | 8 min |
| P17 | [Klausur F24: Stapelspeicher (Stack)](haeppchen/P17_stack.md) | 10 min |
| P18 | [Klausur F24: Kellerautomat für Klammerausdrücke](haeppchen/P18_kellerautomat.md) | 14 min |

## Block S – Projekt Senso
Das Merkspiel Senso komplett in VHDL, Komponente für Komponente (nach Übung 2 „Senso“): Zeitgeber, Taster, Zufall, Zähler, Anzeige, Steuerung.

| | Häppchen | Dauer |
|---|---|---|
| S01 | [Projekt Senso: das ganze System im Überblick](haeppchen/S01_senso_ueberblick.md) | 5 min |
| S02 | [Senso: Zeitgeber mit fester Dauer](haeppchen/S02_timer_konstant.md) | 8 min |
| S03 | [Senso: Zeitgeber testen](haeppchen/S03_timer_testen.md) | 7 min |
| S04 | [Senso: Zeitgeber wird schneller](haeppchen/S04_timer_variabel.md) | 7 min |
| S05 | [Senso: Synchronisierer – vier Schreibweisen](haeppchen/S05_synchronisierer_varianten.md) | 8 min |
| S06 | [Senso: Impulsverkürzer als Moore-Automat](haeppchen/S06_impulsverkuerzer.md) | 9 min |
| S07 | [Senso: Taster testen](haeppchen/S07_button_testen.md) | 5 min |
| S08 | [Senso: Eingabeeinheit mit vier Tastern](haeppchen/S08_input.md) | 8 min |
| S09 | [Senso: rückgekoppeltes Schieberegister von Hand](haeppchen/S09_lfsr_verstehen.md) | 8 min |
| S10 | [Senso: LFSR mit einstellbarer Rückkopplung](haeppchen/S10_lfsr_code.md) | 7 min |
| S11 | [Senso: LFSR mit for-Schleife](haeppchen/S11_lfsr_schleife.md) | 6 min |
| S12 | [Senso: Testbench aus tester und analyzer](haeppchen/S12_tester_analyzer.md) | 10 min |
| S13 | [Senso: Testbench verdrahten und Muster finden](haeppchen/S13_lfsr_testbench.md) | 7 min |
| S14 | [Senso: Zufall mit Startwert-Speicher](haeppchen/S14_random.md) | 9 min |
| S15 | [Senso: Typen für die 7-Segment-Anzeige](haeppchen/S15_counter_typen.md) | 8 min |
| S16 | [Senso: Zählereinheit](haeppchen/S16_counter.md) | 9 min |
| S17 | [Senso: Ausgabeeinheit](haeppchen/S17_output.md) | 6 min |
| S18 | [Senso: Hauptsteuerung entwerfen](haeppchen/S18_steuerung_entwurf.md) | 12 min |
| S19 | [Senso: Hauptsteuerung programmieren](haeppchen/S19_steuerung_code.md) | 14 min |
| S20 | [Senso: alles verbinden und das Spiel testen](haeppchen/S20_senso_gesamt.md) | 12 min |

---

**Am Rechner üben:** siehe [am_rechner/](am_rechner/README.md) –
getestete Beispiele mit Testbenches zum Abtippen und Simulieren.
Deine eigenen Dateien kommen nach `meine_dateien/`.
