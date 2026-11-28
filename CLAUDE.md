# Lern-Häppchen – Projektregeln

Lernmaterial für die Klausur „Entwurf digitaler Systeme“ (VHDL) plus Android-App für beide Fächer
(VHDL + Rechnerarchitektur aus `MoritzErmer/Rechnerarchtektur_Lernen`). Struktur und Release-Pipeline
nach dem Muster von DesignLanguages.

- `haeppchen/`: die Lerneinheiten (Markdown, Format siehe vorhandene Dateien; Reihenfolge/Blöcke aus `README.md`).
- `am_rechner/`: VHDL-Beispiele mit Testbenches, alle mit GHDL geprüft (`./am_rechner/alle_testen.sh`).
- `ra/`: zusätzliche Häppchen fürs Fach Rechnerarchitektur (Blöcke U, W; die App hängt sie hinter die Blöcke aus dem RA-Repo).
  Programme in `ra/am_rechner/*.s` mit `; @test`-Zeilen, geprüft mit `node ra/am_rechner/alle_testen.js` (Simulator aus dem RA-Repo).
- `content/haeppchen.json`: von `tools/build_content.py` erzeugt (beide Fächer), wird in die APK gepackt.
- `app/`: Android-App (Kotlin/Compose). Inhalte werden nativ gerendert, nie als HTML/WebView.

Konventionen: UI-Texte Deutsch, Code/Kommentare Englisch. Versionen nur in `gradle/libs.versions.toml`.
VHDL-Code im Stil des Skripts (`clk'event and clk = '1'`, `res_n`, `end entity …;`).

```bash
python3 tools/build_content.py --ra ../moritzermer/rechnerarchtektur_lernen   # Inhalte neu bauen
./gradlew :app:testDebugUnitTest -q                                           # Logik-Tests
./gradlew :app:testDebugUnitTest -Pscreenshots -q                             # Screenshots nach docs/screenshots
./gradlew :app:assembleDebug -q
./am_rechner/alle_testen.sh                                                   # VHDL-Beispiele (GHDL)
```
Nach sichtbaren Änderungen Screenshots neu erzeugen und ansehen (kein Emulator nötig).
Bei HTTP 429 von Maven Central: warten und wiederholen.

## Sicherheit (öffentliches Repo)
- Niemals Signaturschlüssel, Passwörter oder Tokens committen. Der Release-Schlüssel liegt nur in den
  GitHub-Secrets `VHDL_KEYSTORE_BASE64` / `VHDL_KEYSTORE_PASSWORD`; `.github/release-cert-sha256.txt` ist
  nur der öffentliche Fingerabdruck.
- Keine Vorlesungsskripte oder Prüfungs-PDFs ins Repo (Urheberrecht); nur eigene Aufgaben mit Quellenangabe.
- Die App lädt nur per HTTPS von github.com und validiert die Inhalte (`ContentParser`).

## Release-Notes
Jeder Release listet automatisch unter „Neu in dieser Version“ die Commit-Nachrichten seit dem vorigen Release
(`.github/workflows/release.yml`). Deshalb: Commit-Nachrichten auf Deutsch und für Nutzer verständlich schreiben –
kurzer Titel, darunter Stichpunkte, was neu oder anders ist. Reine Inhaltsänderungen (`haeppchen/`) veröffentlicht
`content.yml` ohne neue APK; die App lädt sie im WLAN.
