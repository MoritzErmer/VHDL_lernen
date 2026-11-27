# C08 · Variablen in Schleifen (Akkumulator)

⏱️ 6 min · zurück: [C07](C07_for_schleife.md) · weiter: [D01](D01_flipflop.md)

## 🎯 Ziel
Mit einer Variablen über mehrere Schleifendurchläufe
ein Ergebnis aufbauen – sehr klausurtypisch.

## 📖 Erklärung
Signale sind im Prozess „eingefroren“ (C02). Will man
ein Zwischenergebnis **im selben Durchlauf**
weiterverwenden, braucht man eine **Variable**.

Muster:
```vhdl
process(x) is
  variable cnt : integer range 0 to 8;
begin
  cnt := 0;                  -- 1. initialisieren
  for i in x'range loop
    if x(i) = '1' then
      cnt := cnt + 1;        -- 2. akkumulieren
    end if;
  end loop;
  anzahl <= cnt;             -- 3. ans Signal
end process;
```
Hardware: eine Kette von N Addierer-Stufen
(abgerollt), kein Speicher – weil `cnt` immer erst
**geschrieben** und dann gelesen wird.

## ✍️ Aufgabe
Ein CRC-Schritt (siehe A03) soll **M-mal
hintereinander** angewendet werden, mit den Bits
`s(0)` bis `s(M-1)`. Ergänze den Prozess:
```vhdl
process(q, s) is
  variable d_int, q_int :
    std_logic_vector(4 downto 0);
begin
  q_int := q;
  for i in 0 to M - 1 loop
    -- ??? 4 Zeilen: ein Schritt mit s(i)
    -- ??? 1 Zeile: Ergebnis weiterreichen
  end loop;
  d <= d_int;
end process;
```

<details><summary>✅ Lösung</summary>

```vhdl
    d_int(4 downto 3) := q_int(3 downto 2);
    d_int(2) := q_int(4) xor s(i) xor q_int(1);
    d_int(1) := q_int(0);
    d_int(0) := q_int(4) xor s(i);
    q_int := d_int;
```
`q_int := d_int;` reicht das Ergebnis an den nächsten
Schleifendurchlauf weiter.
</details>

## 🎓 Klausur
**Frühjahr 2024, A1 F6b**. Ähnlich: F20 A1 F6
(Multiplizierer mit Variable `ac`).
