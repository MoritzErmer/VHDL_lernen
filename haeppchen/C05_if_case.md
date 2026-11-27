# C05 · if und case

⏱️ 5 min · zurück: [C04](C04_delta_zyklen.md) · weiter: [C06](C06_latch_falle.md)

## 🎯 Ziel
Die beiden wichtigsten sequenziellen Anweisungen
syntaktisch sicher schreiben.

## 📖 Erklärung
```vhdl
if a = '1' then
  y <= "01";
elsif b = '1' then     -- elsif, NICHT elseif!
  y <= "10";
else
  y <= "00";
end if;
```
```vhdl
case op is
  when "00"        => y <= a and b;
  when "01" | "10" => y <= a or b;  -- mehrere
  when others      => y <= '0';
end case;
```
- `if` hat **Priorität** (wie `when…else`).
- `case`: alle Fälle gleichrangig, **alle Werte**
  müssen abgedeckt sein → bei `std_logic(_vector)`
  fast immer `when others`.
- Bei Aufzählungstypen (z.B. Zustände) kann man alle
  aufzählen; Bereiche gehen auch:
  `when kurz1 to kurz3 =>`
- Leerer Zweig: `when others => null;`
- `if`/`case` gibt es **nur im Prozess** (bzw.
  Funktion/Prozedur). Außerhalb: `when…else` /
  `with…select`.

## ✍️ Aufgabe
Finde die 3 Fehler:
```vhdl
process(sel, a) is
begin
  case sel is
    when "00" => y <= a;
    when "01" => y <= not a;
    when "10" => y <= '0';
  end;
  if a = '1' then z <= '1';
  else if a = '0' then z <= '0';
  end if;
end process;
```

<details><summary>✅ Lösung</summary>

1. `case` unvollständig → `when others => …` fehlt
   (`"11"`, `"XX"`, …).
2. `end;` muss `end case;` sein.
3. `else if` öffnet ein **neues** `if` (braucht ein
   eigenes `end if;`) → richtig ist `elsif`.
</details>

## 🎓 Klausur
H19 A1 F4: „Verwenden Sie ausschließlich
If-Statements“. Automaten (Block F) bestehen fast
nur aus `case`.
