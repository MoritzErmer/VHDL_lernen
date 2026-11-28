# U09 · LRU-Liste von Hand

6 min · zurück: [U08](U08_superpipeline.md) · weiter: [U10](U10_lru_asm.md)

## Ziel
Verstehen, wie eine LRU-Liste bei jedem Zugriff umsortiert wird.

## Erklärung
Nach **Übung 1, Aufgabe 1.2** (sinngemäß): Eine Liste ordnet die Elemente 0 … N−1 danach, wann zuletzt auf sie zugegriffen wurde: vorne das zuletzt benutzte, hinten das am längsten nicht benutzte (Least Recently Used). Das braucht man z.B. für die Ersetzungsstrategie in Caches.

Bei einem Zugriff auf `element`:
1. Das Element in der Liste suchen (von hinten).
2. Alle Elemente **davor** um eine Stelle nach hinten schieben.
3. `element` ganz vorne eintragen.
4. Rückgabe: das letzte Element der Liste (der nächste Kandidat zum Ersetzen).

```c
char lru(char *LIST, char element, int N) {
    int ret_val = 0;
    for (int i = N - 1; i >= 0; i--) {
        if (LIST[i] == element) {
            for (int j = i - 1; j >= 0; j--)
                LIST[j + 1] = LIST[j];
            LIST[0] = element;
            ret_val = LIST[N - 1];
            break;
        }
    }
    return ret_val;
}
```

## Aufgabe
N = 8, Liste anfangs (0, 1, 2, 3, 4, 5, 6, 7).
1. Liste und Rückgabewert nach einem Zugriff auf 5?
2. Danach ein Zugriff auf 7?
3. Und wieder von vorn: Zugriffe auf 4, 2, 7 nacheinander?

<details><summary>Lösung</summary>

1. (5, 0, 1, 2, 3, 4, 6, 7), Rückgabe **7**.
2. (7, 5, 0, 1, 2, 3, 4, 6), Rückgabe **6**.
3. Nach 4: (4, 0, 1, 2, 3, 5, 6, 7), Rückgabe 7. Nach 2: (2, 4, 0, 1, 3, 5, 6, 7), Rückgabe 7. Nach 7: (7, 2, 4, 0, 1, 3, 5, 6), Rückgabe **6**.

Ausgehend von der Anfangsliste liefert ein Zugriff auf 7 direkt (7, 0, 1, 2, 3, 4, 5, 6) und Rückgabe 6.
</details>

## Klausur
**Ü1 A1.2 F1.** LRU begegnet dir wieder bei Caches.
