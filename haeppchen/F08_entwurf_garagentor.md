# F08 · Selbst entwerfen: Garagentor

⏱️ 8 min · zurück: [F07](F07_tabelle_als_array.md) · weiter: [F09](F09_verhalten_ablesen.md)

## 🎯 Ziel
Von einer Textbeschreibung zu fertigem Automaten-Code.

## 📖 Erklärung
Vorgehen in 4 Schritten:
1. **Zustände** sammeln (was „merkt“ sich das System?)
2. **Übergänge** je Zustand und Eingang
3. **Ausgänge** je Zustand → Moore
4. Code nach Template (F02) hinschreiben

Spezifikation:
- Eingänge: `taster` (1-Takt-Puls), `oben`, `unten`
  (Endschalter), `hindernis` (Lichtschranke)
- Ausgänge: `motor_auf`, `motor_zu`
- Zu → Taster → öffnet, bis `oben` → offen
- Offen → Taster → schließt, bis `unten` → zu
- Beim Schließen und `hindernis` → sofort wieder
  öffnen

## ✍️ Aufgabe
Schreibe den Typ, `transition_function` und
`output_function`. (Den `state`-Prozess kannst du
weglassen.)

<details><summary>✅ Lösung</summary>

```vhdl
type state_type is (zu, oeffnet, offen, schliesst);

transition_function: process(current_state,
    taster, oben, unten, hindernis) is
begin
  next_state <= current_state;
  case current_state is
    when zu =>
      if taster = '1' then
        next_state <= oeffnet;
      end if;
    when oeffnet =>
      if oben = '1' then
        next_state <= offen;
      end if;
    when offen =>
      if taster = '1' then
        next_state <= schliesst;
      end if;
    when schliesst =>
      if hindernis = '1' then
        next_state <= oeffnet;
      elsif unten = '1' then
        next_state <= zu;
      end if;
  end case;
end process transition_function;

output_function: process(current_state) is
begin
  motor_auf <= '0';
  motor_zu  <= '0';
  case current_state is
    when oeffnet   => motor_auf <= '1';
    when schliesst => motor_zu  <= '1';
    when others    => null;
  end case;
end process output_function;
```
Beachte: `hindernis` hat **Vorrang** vor `unten`
(Sicherheit!).
</details>

## 🎓 Klausur
Freie Entwurfsaufgaben wie **F20 A2 F8** (Tastatur)
oder F23 A2 F9 laufen genauso ab.

💻 Am Rechner: `am_rechner/L07/garagentor.vhd`
