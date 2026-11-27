# E04 · Eigene Array-Typen

⏱️ 6 min · zurück: [E03](E03_aufzaehlungstypen.md) · weiter: [E05](E05_rom.md)

## 🎯 Ziel
Speicher und Tabellen als Array-Typ deklarieren.

## 📖 Erklärung
Ein Array braucht **immer einen eigenen Typ**:
```vhdl
type memory_type is array (0 to 7)
  of std_logic_vector(7 downto 0);
signal memory : memory_type;
```
- Zugriff: `memory(3)` ist ein Byte,
  `memory(3)(7)` dessen oberstes Bit.
- Index ist meist `integer` → aus Vektoren
  umwandeln: `memory(to_integer(unsigned(addr)))`.
- **Mehrdimensional**:
  ```vhdl
  type table_type is
    array (state_type, input_type) of state_type;
  ```
  Zugriff: `table(current_state, x)`.
  Als Index geht jeder **diskrete** Typ, auch
  Aufzählungstypen!
- **Unbeschränkt** (Größe erst bei Nutzung):
  ```vhdl
  type word_array is array (natural range <>)
    of std_logic_vector(7 downto 0);
  signal w : word_array(0 to 15);
  ```
  (`std_logic_vector` selbst ist so definiert.)

## ✍️ Aufgabe
Ein FIFO speichert **16 Werte à 8 Bit**.
1. Deklariere einen Typ `memory_type` und ein
   Signal `memory`.
2. Schreibe die Zeile, die bei der Taktflanke `din`
   an die Stelle `windex` (integer) schreibt.
3. Wie viele Dimensionen hat
   `array(state_type, input_type) of X`?

<details><summary>✅ Lösung</summary>

```vhdl
type memory_type is array (0 to 15)
  of std_logic_vector(7 downto 0);
signal memory : memory_type;

memory(windex) <= din;
```
3. **Zwei** Dimensionen (je eine pro Indextyp).
</details>

## 🎓 Klausur
**H19 A2 F6** (memory_type für FIFO),
**F24 A2 F1a** (Dimensionen von
`transition_table_type`), F23 A1 F5.
