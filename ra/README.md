# Rechnerarchitektur: Übungen und Werkstatt

Zusätzliche Häppchen für das Fach **Rechnerarchitektur und Rechnerorganisation**, ergänzend zum Repo
[Rechnerarchtektur_Lernen](https://github.com/MoritzErmer/Rechnerarchtektur_Lernen). Die App zeigt sie im selben Fach
nach den dortigen Blöcken. Alle Programme sind für den IKR RISC II geschrieben und mit dem Simulator aus jenem Repo
geprüft: `node ra/am_rechner/alle_testen.js`.

Die Aufgaben aus den Übungen sind sinngemäß nacherzählt, die Übungsblätter selbst liegen nicht im Repo.

## Block U – Übungen nachgebaut
Übung 0 (Stapel, Konventionen, streq), Praktische Übung 0 (Game of Life), Übung 1 (Pipeline, LRU),
Praktische Übung 1 (2048), alles auf dem IKR RISC II.

| | Häppchen | Dauer |
|---|---|---|
| U01 | [Warum Unterprogramme einen Stapel brauchen](haeppchen/U01_stapel_warum.md) | 5 min |
| U02 | [Wer sichert die Register?](haeppchen/U02_caller_callee.md) | 5 min |
| U03 | [streq: zwei Strings vergleichen](haeppchen/U03_streq.md) | 10 min |
| U04 | [Unterprogramm ruft Unterprogramm](haeppchen/U04_stapel_risc.md) | 12 min |
| U05 | [Game of Life: eine Zelle](haeppchen/U05_gol_zelle.md) | 12 min |
| U06 | [Game of Life: ganze Runden](haeppchen/U06_gol_runde.md) | 15 min |
| U07 | [Datenabhängigkeiten im FIR-Filter](haeppchen/U07_pipeline_abh.md) | 10 min |
| U08 | [Superpipeline: schneller getaktet, mehr Wartezeit](haeppchen/U08_superpipeline.md) | 12 min |
| U09 | [LRU-Liste von Hand](haeppchen/U09_lru_hand.md) | 6 min |
| U10 | [LRU in Assembler](haeppchen/U10_lru_asm.md) | 15 min |
| U11 | [init und test_lru](haeppchen/U11_lru_test.md) | 12 min |
| U12 | [2048: Spielfeld zeichnen](haeppchen/U12_2048_draw.md) | 12 min |
| U13 | [2048: Zufall ohne Sprünge](haeppchen/U13_2048_lfsr.md) | 10 min |
| U14 | [2048: Steine aufrücken](haeppchen/U14_2048_compact.md) | 12 min |
| U15 | [2048: Vereinigen und ganzer Zug](haeppchen/U15_2048_zug.md) | 18 min |
| U16 | [2048: neuen Stein setzen](haeppchen/U16_2048_spawn.md) | 15 min |

## Block W – Werkstatt: komplett selbst programmieren
Nur Schnittstelle und Beschreibung, das Programm schreibst du ganz selbst.

| | Häppchen | Dauer |
|---|---|---|
| W01 | [Werkstatt: Programme komplett selbst schreiben](haeppchen/W01_werkstatt_start.md) | 5 min |
| W02 | [Maximum eines Arrays](haeppchen/W02_maximum.md) | 8 min |
| W03 | [Länge eines Strings](haeppchen/W03_strlen.md) | 6 min |
| W04 | [Zeichen in einem String zählen](haeppchen/W04_zaehle.md) | 7 min |
| W05 | [Array umdrehen](haeppchen/W05_umdrehen.md) | 10 min |
| W06 | [Multiplizieren ohne Multiplizierbefehl](haeppchen/W06_mulu.md) | 10 min |
| W07 | [Division mit Rest](haeppchen/W07_divu.md) | 14 min |
| W08 | [Bits zählen und Parität](haeppchen/W08_popcount.md) | 7 min |
| W09 | [Bubble Sort](haeppchen/W09_bubblesort.md) | 15 min |
| W10 | [Binäre Suche](haeppchen/W10_binsuche.md) | 12 min |
| W11 | [Rekursion: Fibonacci](haeppchen/W11_fib_rekursiv.md) | 15 min |
| W12 | [kgV aus drei Unterprogrammen](haeppchen/W12_kgv.md) | 18 min |
| W13 | [64-Bit-Addition](haeppchen/W13_add64.md) | 6 min |
| W14 | [Text in Zahl umwandeln](haeppchen/W14_atoi.md) | 12 min |
| W15 | [Sieb des Eratosthenes](haeppchen/W15_sieb.md) | 15 min |
| W16 | [Matrixmultiplikation](haeppchen/W16_matmul.md) | 25 min |
