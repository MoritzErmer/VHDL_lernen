# H03 · Wo wird was deklariert?

4 min · zurück: [H02](H02_prozeduren.md) · weiter: [H04](H04_packages.md)

## Ziel
Sichtbarkeit von Typen, Konstanten und
Unterprogrammen sicher beurteilen.

## Erklärung
Deklarationsorte (von groß nach klein):

| Ort | sichtbar in |
|---|---|
| **Package** | jeder Design-Einheit mit `use work.pkg.all;` |
| **Entity** (vor `begin`/nach `port`) | Entity + allen ihren Architectures |
| **Architecture** (vor `begin`) | allen Prozessen dieser Architecture |
| **Prozess** (vor `begin`) | nur diesem Prozess |
| **Unterprogramm** | nur darin |

Regeln:
- **Möglichst lokal** deklarieren (Kapselung).
- **Signale** nur in Architecture/Package/Entity,
  **nie** im Prozess. Variablen nur in Prozess/
  Unterprogramm.
- Eine Prozedur, die ein Signal **ohne Parameter**
  treibt (`ser_in <= …`), muss dort deklariert sein,
  wo das Signal sichtbar ist – also im Prozess oder
  der Architecture, **nicht** in einem Package.
- Typen für **Ports** → Package (die Entity braucht
  sie schon).

## Aufgabe
Ein Testprozess `testp` nutzt Prozeduren `read` und
`write`, die Signale der Architecture direkt treiben.
1. Wo können `read`/`write` deklariert sein?
2. Welcher Ort ist am besten? Warum?

<details><summary>Lösung</summary>

1. Im Deklarationsteil der **Architecture**, die
   `testp` enthält, oder im Deklarationsteil des
   **Prozesses** `testp`.
2. **Im Prozess `testp`**, weil die Prozeduren nur
   dort verwendet werden (möglichst lokal).
</details>

## Klausur
**F19 A2 F1a/b** – genau diese Frage.
