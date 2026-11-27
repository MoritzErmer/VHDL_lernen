# K02 · Klausur F24: Steuerwerk

⏱️ 8 min · zurück: [K01](K01_crc_register.md) · weiter: [K03](K03_prio_encoder_8bit.md)

## 🎯 Ziel
Einen Steuerwerks-Automaten vollständig mit
Zustands- und Übergangsprozess angeben.

## 📖 Erklärung
Aufgabe (F24 A1 F8, gekürzt): Entity `ctrl` mit
`clk`, `res_n`, `start` und Ausgängen. Zustände
`S1, S2, S3, CLEAR`, Reset nach `S1`.
- `S1`: wartet auf `start = '1'` → dann `S2`
- `S2` → `S3` → `CLEAR` → `S1` (je ein Takt)

Den Ausgangsprozess hast du in F06 geschrieben.

## ✍️ Aufgabe
Schreibe die Architecture `behav` mit Typ,
Signalen, **`state_p`** (Register) und
**`transition_p`** (Übergänge, mit Default).
Den Ausgangsprozess darfst du weglassen.

<details><summary>✅ Lösung</summary>

```vhdl
architecture behav of ctrl is
  type state_type is (S1, S2, S3, CLEAR);
  signal current_state, next_state : state_type;
begin
  state_p: process(clk, res_n) is
  begin
    if res_n = '0' then
      current_state <= S1;
    else
      if clk'event and clk = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process state_p;

  transition_p: process(current_state, start) is
  begin
    next_state <= current_state;
    case current_state is
      when S1 =>
        if start = '1' then
          next_state <= S2;
        end if;
      when S2 =>
        next_state <= S3;
      when S3 =>
        next_state <= CLEAR;
      when CLEAR =>
        next_state <= S1;
    end case;
  end process transition_p;

  -- output_p: siehe F06
end architecture behav;
```
Warum 4 Takte? 3 Takte rechnen + 1 Takt, um das
Register zu löschen (F24 A1 F7).
</details>

## 🎓 Klausur
**F24 A1 F7/F8**.
