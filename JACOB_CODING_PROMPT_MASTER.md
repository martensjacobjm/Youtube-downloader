# Jacob – Kodprompt Master (samlad)
**Version:** 1.0 • **Datum:** 2025-10-24 19:15:32 CEST

> Denna fil sammanställer *samtliga* praktiska kod‑prompts och spelregler som du konsekvent krävt i tidigare chattar. Innehållet är en destillat av dina återkommande krav på struktur, körbarhet, felsäkring och dokumentation.

---

## 1. Globala grundregler (obligatoriska)

- **Språkdisciplin**
  - *Svenska* i dialog, uppdrag, rapporter och kommentarer till dig.
  - *Engelska* i **kod** (filnamn, variabler, funktionsnamn) och **kodkommentarer**.

- **Körbar helhet**
  - Kod ska levereras som **fullt körbara** skript eller filer, inte lösa fragment.
  - En sammanhållen *script block*-leverans som inkluderar: `cd`, `mkdir -p`, filskapande, `chmod`, ev. ikon/desktop‑entry (vid behov), samt **körning**.
  - **No placeholders** utan att de är uttryckligen markerade och förifyllda med realistiska defaultvärden.

- **Atomära ändringar**
  - Ändra en sak i taget, per tydligt markerad **commit**/sektion. Skriv exakt *vad* och *var* som ändras.

- **Linjär exekvering**
  - Utför steg i **rätt ordning**. Avsluta varje block innan nästa påbörjas.
  - Ingen "magisk" hoppning mellan steg.

- **Felhantering (strict)**
  - Vid fel: **stoppa körningen**, isolera felet, testa isolerat tills det fungerar.
  - **När verifierat:** fortsätt från nästa steg i komplett körbar kod.
  - Logga fel med tydlig orsak och åtgärd.

- **Cross‑validation & källor**
  - Fakta ska **dubbelkontrolleras** mot minst 2 oberoende källor när uppgiften är osäker/extern.
  - **Källhänvisning är obligatorisk**. För webbkällor: ange källa (titel/domän + datum). För dialogkällor: ange datum/tidsstämpel.

- **Begränsningar öppet**
  - Ange explicit vad som **inte** verifierats eller där antagande görs. Markera: `Detta är en gissning:`.

- **Determinism & reproducerbarhet**
  - Fäst versionsinfo (verktyg, bibliotek, profiler), miljöberoenden och konfig.
  - Ange **exakta** kommandon, flaggor, fil‑ och sökvägar.
  - Om slump används: dokumentera seed/parametrar.

---

## 2. Leveransformat

- **Kodblock** ska vara kompletta, körbara och självförklarande.
- **Kommentarblock** separeras från exekverbar kod.
  *Exempel:*

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
# ------------------------------------------
# Purpose: Example scaffolding
# Author: (you)
# Notes: Comments in English; commands explicit
# ------------------------------------------

main() {
  # 1) Prepare workspace
  mkdir -p "$HOME/projects/example"
  cd "$HOME/projects/example"

  # 2) Create app
  cat > app.py <<'PY'
#!/usr/bin/env python3
# Purpose: Minimal runnable template
# Logging: stdout + file
import logging, sys, pathlib

LOG = pathlib.Path("run.log")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout),
              logging.FileHandler(LOG, encoding="utf-8")]
)
def main():
    logging.info("Hello, Jacob. Script is reproducible and logged.")
if __name__ == "__main__":
    main()
PY
  chmod +x app.py

  # 3) Run
  ./app.py
}

main "$@"
```

- **Felhanteringsmönster** (Bash):

```bash
set -Eeuo pipefail
trap 'echo "[ERROR] Line $LINENO failed"; exit 1' ERR
```

- **PowerShell‑huvud** (för dina PS‑flöden & HTML/regex‑jobb):

```powershell
#Requires -Version 7.2
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSStyle.OutputRendering = "Host"  # deterministic output
# Logging init
$Log = Join-Path $PSScriptRoot "run.log"
Start-Transcript -Path $Log -Append | Out-Null
try {
    # ... your pipeline ...
}
finally {
    Stop-Transcript | Out-Null
}
```

---

## 3. Dokumentationskrav

- **Header i varje fil**: syfte, beroenden, körning, författare, datum.
- **Changelog** i slutet av leveransen (atomära punkter).
- **Kända begränsningar** + hur de verifierats eller inte.
- **Källor** (webb: kort citat + länk; intern dialog: datum/tid).

---

## 4. Mallar (kopiera‑kör)

### 4.1 Bash – "end‑to‑end" körbar leverans

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] Line $LINENO failed"; exit 1' ERR

# --- [Config] -------------------------------------------------
APP_DIR="${HOME}/tools/myapp"
LOG_FILE="${APP_DIR}/run.log"

# --- [Step 1] Prepare workspace -------------------------------
mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

# --- [Step 2] Create program ---------------------------------
cat > main.py <<'PY'
#!/usr/bin/env python3
# Purpose: Example program with logging & args
# Notes: Comments in English
import argparse, logging, sys, pathlib

def setup_logger(path: pathlib.Path):
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[logging.StreamHandler(sys.stdout),
                  logging.FileHandler(path, encoding="utf-8")]
    )

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=False, help="Optional input file")
    return p.parse_args()

def main():
    args = parse_args()
    setup_logger(pathlib.Path("run.log"))
    logging.info("Program start")
    if args.input:
        logging.info(f"Reading: {args.input}")
    logging.info("Done.")

if __name__ == "__main__":
    main()
PY
chmod +x main.py

# --- [Step 3] Run ---------------------------------------------
./main.py --input sample.txt || { echo "Isolated test failed"; exit 1; }

echo "[OK] Completed"
```

### 4.2 PowerShell – robust pipeline (HTML/regex/yt-dlp‑stil)

```powershell
#Requires -Version 7.2
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Log = Join-Path $PSScriptRoot "run.log"
Start-Transcript -Path $Log -Append | Out-Null

try {
    # Region: Parameters
    param(
        [string]$Url,
        [string]$OutDir = "$PSScriptRoot\out"
    )

    # Region: Setup
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

    # Region: Example function
    function Normalize-Html([string]$Html) {
        # Keep it deterministic; strip scripts; convert BR/P/LIs to newlines
        $norm = $Html -replace '(?is)<br\s*/?>', "`n"
        $norm = $norm -replace '(?is)</(p|h[1-6]|li|tr|div)>', "`n"
        $norm = [regex]::Replace($norm,'(?is)<script[^>]*>.*?</script>','')
        return $norm
    }

    Write-Host "Pipeline OK"
}
catch {
    Write-Warning $_.Exception.Message
    throw
}
finally {
    Stop-Transcript | Out-Null
}
```

### 4.3 Python – modulärt "agent"‑mönster (AI‑rigg)

```python
#!/usr/bin/env python3
"""
Purpose: Modular agent runner with explicit logging and config
Notes: Comments in English; deterministic imports
"""
import logging, sys, pathlib, json

BASE = pathlib.Path.home() / "AI-Rigg"
LOG  = BASE / "logs" / "runner.log"
BASE.mkdir(parents=True, exist_ok=True)
(LOG.parent).mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout),
              logging.FileHandler(LOG, encoding="utf-8")]
)

def load_config(path: pathlib.Path):
    if not path.exists():
        logging.warning("Config missing; writing default")
        default = {"agents": []}
        path.write_text(json.dumps(default, indent=2), encoding="utf-8")
        return default
    return json.loads(path.read_text(encoding="utf-8"))

def main():
    cfg = load_config(BASE / "config.json")
    logging.info("Agents loaded: %d", len(cfg.get("agents", [])))
    # TODO: iterate agents deterministically

if __name__ == "__main__":
    main()
```

---

## 5. Domänspecifika riktlinjer (återkommande i chattar)

- **yt‑dlp/ffmpeg pipelines**
  - Ange *exakta* flaggor, container (MP4/MKV), codec‑val, undertext‑extraktion (text + språk), samt fallback när en stream saknas.
  - Leverera *separat* ljud‑extraktion (m4a/wav) vid behov, i egen atomär sektion.
  - Logga every step; stoppa vid fel; fortsätt efter isolerad fix.

- **Slicer/OrcaSlicer/PrusaSlicer konfig**
  - Specificera **version**, profilnamn, nyckelparametrar (hastigheter, accelerationer, layer time, bridging, supports). Undvik antaganden – referera manual/forumkälla.
  - När användaren saknar en meny: lokalisera exakt *var* i UI (med meny‑stig) eller erbjuda **exporterad profil**.

- **PowerShell HTML/regex/Text parsing**
  - Använd `Set-StrictMode`, transcript‑logg, och tydliga funktionsgränser.
  - Håll regex isolerade, med testbara provsträngar och normaliseringssteg innan extraktion.

- **AI‑rigg (lokala LLMs, orchestrators)**
  - Sätt katalogstruktur under `~/AI-Rigg/...` (modeller, logs, configs).
  - Alla externa verktyg versionslåses och dokumenteras (Ollama/LocalAI etc.).

---

## 6. Checklista före leverans

1. Är koden **körbar** utan manuella mellanmoment?
2. Finns **felhantering** och **loggning**?
3. Är alla **beroenden** och **versioner** dokumenterade?
4. Är ändringen **atomär** och beskriven?
5. Finns **källor** och **verifiering** för tveksamma delar?
6. Är det tydligt vad som är **antagande/gissning**?
7. Är språkregeln följd (svenska i dialog, engelska i kod)?

---

## 7. Källhänvisning (denna sammanställning)

- Återkommande krav från dina meddelanden: 2025‑10‑24 "User's Instructions" (state management, atomära ändringar, full körbarhet, logging, cross‑validation, källhänvisning, engelska i kod/svenska i dialog, linjär exekvering, strikt felhantering).
- Flertalet chattar under 2025‑10‑14..23 med referenser till PowerShell‑script, yt‑dlp/ffmpeg, Orca/Prusa‑inställningar, och AI‑rigg‑flöden (se "Recent Conversation Content").

---

## 8. Changelog
- **1.0** – Första samlade "Master"-prompten baserat på historik och återkommande krav.
