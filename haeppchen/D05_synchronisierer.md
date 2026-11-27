# D05 · Schieberegister & Synchronisierer

5 min · zurück: [D04](D04_flipflops_zaehlen.md) · weiter: [D06](D06_von_hand_simulieren.md)

## Ziel
Schieberegister schreiben und wissen, warum man
asynchrone Eingänge über **2 Flipflops** einliest.

## Erklärung
**Schieberegister** (seriell rein, parallel raus):
```vhdl
if clk'event and clk = '1' then
  sr <= sr(6 downto 0) & ser_in;
end if;
```
**Asynchrone Eingänge** (Taster, serielle Leitung,
fremder Takt) können sich *genau an der Taktflanke*
ändern → das FF wird **metastabil** (weder 0 noch 1,
für unbestimmte Zeit).
**Abhilfe:** **Synchronisierer** = 2 FFs in Reihe.
Das erste darf metastabil werden, bis zur nächsten
Flanke hat es sich (sehr wahrscheinlich) beruhigt.

```vhdl
if clk'event and clk = '1' then
  ser_in_d  <= ser_in;      -- FF 1
  ser_in_dd <= ser_in_d;    -- FF 2 → sicher
end if;
```
Nur `ser_in_dd` darf weiterverwendet werden!

Mit **Variablen** geht das auch – dann aber in der
**umgekehrten** Reihenfolge (erst lesen, dann
schreiben, vgl. D04):
```vhdl
ser_in_dd := ser_in_d;
ser_in_d  := ser_in;
```

## Aufgabe
1. Wie heißt die Anordnung aus `ser_in_d` und
   `ser_in_dd`, und wozu dient sie?
2. Was passiert bei den Variablen, wenn man die zwei
   Zeilen vertauscht?

<details><summary>Lösung</summary>

1. **Synchronisierer** (Synchronisationsstufe / zwei-
   stufiges Schieberegister). Er verhindert, dass
   **Metastabilität** des asynchronen Eingangs in die
   Schaltung weitergegeben wird.
2. `ser_in_d := ser_in; ser_in_dd := ser_in_d;` →
   `ser_in_d` wird zuerst geschrieben → **kein FF**.
   Beide hätten sofort denselben Wert → nur **ein**
   Flipflop, Synchronisierer kaputt.
</details>

## Klausur
**Frühjahr 2019, A1 F5a** (Variablen `ser_in_d`,
`ser_in_dd`), F20 A2 F9 (Tastatur-Eingänge).
Designrichtlinien: Skript Kap. 6.1.
