# D07 · Flankenerkennung

⏱️ 5 min · zurück: [D06](D06_von_hand_simulieren.md) · weiter: [Übersicht](../README.md)

## 🎯 Ziel
Aus einem langen Tastendruck einen **einzigen**
Taktimpuls machen – Standardbaustein vor Automaten.

## 📖 Erklärung
Idee: Eingang um einen Takt verzögern und mit dem
aktuellen Wert vergleichen.
```
taste   : 0 0 1 1 1 1 0 0
taste_d : 0 0 0 1 1 1 1 0
puls    : 0 0 1 0 0 0 0 0
```
`puls = taste and not taste_d`

```vhdl
architecture behav of flanke is
  signal taste_d : std_logic;
begin
  reg: process(clk, res_n) is
  begin
    if res_n = '0' then
      taste_d <= '0';
    else
      if clk'event and clk = '1' then
        taste_d <= taste;
      end if;
    end if;
  end process reg;

  puls <= taste and not taste_d;
end architecture behav;
```
Struktur: **1 FF + kombinatorische Logik** am
Ausgang. (Ist `taste` asynchron → vorher noch durch
einen Synchronisierer, D05!)

## ✍️ Aufgabe
1. Ändere die Zuweisung so, dass `puls` bei der
   **fallenden** Flanke von `taste` kommt.
2. Welcher Automatentyp ist das (Mealy, Moore,
   Medwedew)? Tipp: Hängt `puls` direkt vom Eingang
   ab?

<details><summary>✅ Lösung</summary>

1. `puls <= not taste and taste_d;`
2. **Mealy**: Der Ausgang hängt vom Zustand
   (`taste_d`) **und** direkt vom Eingang (`taste`)
   ab. (Mehr dazu in Block F.)
</details>

## 🎓 Klausur
Automatentyp begründen: **F24 A1 F2**, F23 A2 F1,
F21 A2 F3.
