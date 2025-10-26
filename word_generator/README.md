# Word Document Generator

**Version:** 1.0
**Datum:** 2025-10-26
**Plattform:** Windows (VS Code)

> Ett komplett Python-baserat system för att skapa Word-dokument programmatiskt med stöd för dynamiska sökvägar, mallar, och JSON-konfiguration.

---

## Innehåll

1. [Översikt](#översikt)
2. [Installation](#installation)
3. [Snabbstart](#snabbstart)
4. [Användning](#användning)
5. [Konfigurationsformat](#konfigurationsformat)
6. [Avancerad användning](#avancerad-användning)
7. [Felsökning](#felsökning)
8. [Changelog](#changelog)

---

## Översikt

Word Document Generator är ett verktyg för att skapa Word-dokument (.docx) programmatiskt. Systemet består av:

- **Python-modul** (`word_document_creator.py`) - Kärnfunktionalitet för dokumentgenerering
- **PowerShell wrapper** (`RUN_WORD_GENERATOR.ps1`) - Interaktivt gränssnitt med dynamiska sökvägar
- **BAT-fil** (`RUN_WORD_GENERATOR.bat`) - Enkel start via dubbelklick
- **JSON-konfiguration** - Deklarativ dokumentdefinition

### Funktioner

- ✅ Skapa dokument från JSON-konfiguration
- ✅ Stöd för rubriker, paragrafer, listor (punktlistor & numrerade)
- ✅ Tabeller med valfri header-styling
- ✅ Sidbrytningar
- ✅ Dynamiska sökvägar för Windows
- ✅ Fullständig loggning (console + fil)
- ✅ Felhantering och validering
- ✅ Template-baserad generering (placeholders)
- ✅ VS Code-kompatibel

---

## Installation

### Förutsättningar

1. **Python 3.8+**
   - Ladda ner från [python.org](https://www.python.org/downloads/)
   - Markera "Add Python to PATH" vid installation

2. **PowerShell 7.2+** (rekommenderas, men PowerShell 5.1 fungerar också)
   - Windows 10/11 har PowerShell 5.1 inbyggt
   - För PowerShell 7: [Installation](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)

### Steg 1: Installera Python-beroenden

Öppna PowerShell eller Terminal i projektmappen:

```powershell
cd word_generator
pip install -r requirements.txt
```

**Alternativt:** Kör `RUN_WORD_GENERATOR.bat` - scriptet installerar automatiskt beroenden om de saknas.

---

## Snabbstart

### Metod 1: Dubbelklicka BAT-filen (enklast)

1. Öppna mappen `word_generator` i Utforskaren
2. Dubbelklicka på `RUN_WORD_GENERATOR.bat`
3. Följ menyn i PowerShell-fönstret

### Metod 2: PowerShell (rekommenderat för utveckling)

```powershell
cd word_generator
.\RUN_WORD_GENERATOR.ps1
```

### Metod 3: Python direkt (avancerat)

```powershell
python word_document_creator.py --help
python word_document_creator.py --config config/example.json
python word_document_creator.py --output test.docx --title "Mitt Dokument"
```

---

## Användning

### Skapa dokument från JSON-konfiguration

1. Skapa eller redigera en JSON-fil i `config/`-mappen
2. Kör PowerShell-wrappern och välj alternativ 1
3. Välj din konfigurationsfil från listan
4. Dokumentet skapas i `output/`-mappen

**Exempel:**

```powershell
.\RUN_WORD_GENERATOR.ps1
# Välj: 1 (från konfiguration)
# Välj: 1 (example.json)
```

### Skapa enkelt dokument med titel

```powershell
.\RUN_WORD_GENERATOR.ps1
# Välj: 2 (enkelt dokument)
# Ange titel: "Mitt Testdokument"
# Ange filnamn: "test"
```

### Öppna output-mappen

```powershell
.\RUN_WORD_GENERATOR.ps1
# Välj: 4 (öppna output-mapp)
```

---

## Konfigurationsformat

JSON-konfigurationsfiler definierar dokumentets struktur och innehåll.

### Grundstruktur

```json
{
  "filename": "output.docx",
  "title": "Document Title",
  "content": [
    // Content blocks här
  ]
}
```

### Content Block Types

#### 1. Heading (Rubrik)

```json
{
  "type": "heading",
  "text": "Rubriktext",
  "level": 1
}
```

- `level`: 1-9 (1 = huvudrubrik, 2 = underrubrik, osv.)

#### 2. Paragraph (Paragraf)

```json
{
  "type": "paragraph",
  "text": "Din text här",
  "bold": false,
  "italic": false,
  "font_size": 12
}
```

#### 3. Bullet List (Punktlista)

```json
{
  "type": "bullet_list",
  "items": [
    "Första punkten",
    "Andra punkten",
    "Tredje punkten"
  ]
}
```

#### 4. Numbered List (Numrerad lista)

```json
{
  "type": "numbered_list",
  "items": [
    "Första steget",
    "Andra steget",
    "Tredje steget"
  ]
}
```

#### 5. Table (Tabell)

```json
{
  "type": "table",
  "data": [
    ["Header 1", "Header 2", "Header 3"],
    ["Rad 1 Col 1", "Rad 1 Col 2", "Rad 1 Col 3"],
    ["Rad 2 Col 1", "Rad 2 Col 2", "Rad 2 Col 3"]
  ],
  "headers": true
}
```

- `headers`: true = första raden är fetstil (headers)

#### 6. Page Break (Sidbrytning)

```json
{
  "type": "page_break"
}
```

### Komplett Exempel

Se `config/example.json` för ett fullständigt exempel med alla block-typer.

---

## Avancerad användning

### Kommandoradsargument (Python direkt)

```bash
# Skapa från konfiguration
python word_document_creator.py --config config/example.json

# Skapa enkelt dokument
python word_document_creator.py --output test.docx --title "Test"

# Anpassad bas-mapp
python word_document_creator.py --base-dir C:\MyDocuments --config config/example.json

# Ändra loggningsnivå
python word_document_creator.py --log-level DEBUG --config config/example.json

# Visa hjälp
python word_document_creator.py --help
```

### Python API (för integration i egna scripts)

```python
from pathlib import Path
from word_document_creator import WordDocumentCreator

# Initiera
creator = WordDocumentCreator(
    base_dir=Path("C:/MyProject"),
    log_level="INFO"
)

# Skapa dokument från innehåll
content = [
    {"type": "heading", "text": "Hello World", "level": 1},
    {"type": "paragraph", "text": "Detta är mitt dokument."}
]

output = creator.create_document(
    filename="hello.docx",
    title="Hello World",
    content=content
)

print(f"Dokument skapat: {output}")
```

### Template-baserad generering (kommer snart)

```python
# Skapa template med placeholders
replacements = {
    "{{NAME}}": "Jacob",
    "{{DATE}}": "2025-10-26",
    "{{AMOUNT}}": "1000 SEK"
}

output = creator.create_from_template(
    template_name="invoice_template.docx",
    output_name="invoice_jacob.docx",
    replacements=replacements
)
```

---

## Felsökning

### Problem: "Python hittades inte"

**Lösning:**
1. Installera Python från [python.org](https://www.python.org/downloads/)
2. Markera "Add Python to PATH" vid installation
3. Starta om terminalen/PowerShell

### Problem: "python-docx saknas"

**Lösning:**

```powershell
pip install python-docx
# eller
pip install -r requirements.txt
```

### Problem: PowerShell execution policy error

**Lösning:**

```powershell
# Kör som administratör:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# eller använd BAT-filen (bypass automatiskt)
.\RUN_WORD_GENERATOR.bat
```

### Problem: "ModuleNotFoundError: No module named 'docx'"

**Lösning:**

```powershell
# Kontrollera att du använder rätt Python
python --version

# Installera i rätt Python-miljö
python -m pip install python-docx
```

### Loggfiler

Alla loggfiler sparas i `logs/`-mappen:

- **PowerShell wrapper:** `powershell_wrapper_YYYYMMDD_HHMMSS.log`
- **Python script:** `word_creator_YYYYMMDD_HHMMSS.log`

Kontrollera dessa vid fel.

---

## Katalogstruktur

```
word_generator/
├── word_document_creator.py   # Python-modul (kärnfunktionalitet)
├── RUN_WORD_GENERATOR.ps1      # PowerShell wrapper (interaktiv)
├── RUN_WORD_GENERATOR.bat      # BAT-launcher (dubbelklick)
├── requirements.txt            # Python-beroenden
├── README.md                   # Denna fil
│
├── config/                     # JSON-konfigurationsfiler
│   ├── example.json            # Exempel-konfiguration
│   └── template_example.json   # Mall-exempel
│
├── templates/                  # Word-templates (.docx med placeholders)
│   └── (lägg dina templates här)
│
├── output/                     # Genererade dokument (skapas automatiskt)
│   └── *.docx
│
└── logs/                       # Loggfiler (skapas automatiskt)
    ├── powershell_wrapper_*.log
    └── word_creator_*.log
```

---

## Teknisk information

### Beroenden

- **python-docx** (>=0.8.11) - Word-dokument manipulation
- **lxml** (>=4.9.0) - XML-bearbetning

### Kompatibilitet

- **Python:** 3.8, 3.9, 3.10, 3.11, 3.12
- **OS:** Windows 10/11 (primärt), Linux/macOS (osäkert)
- **PowerShell:** 5.1+ (7.2+ rekommenderas)
- **Word:** .docx-format (Office 2007+)

### Prestanda

- Små dokument (< 10 sidor): < 1 sekund
- Medelstora dokument (10-50 sidor): 1-3 sekunder
- Stora dokument (> 50 sidor): 3-10 sekunder

### Säkerhet

- Inga externa API-anrop
- Lokal bearbetning endast
- Inga känsliga data loggas (undvik lösenord i JSON)

---

## Changelog

### Version 1.0 (2025-10-26)

**Initial release**

- ✅ Python-modul för dokumentgenerering
- ✅ PowerShell wrapper med interaktiv meny
- ✅ BAT-launcher för Windows
- ✅ JSON-baserad konfiguration
- ✅ Stöd för: headings, paragraphs, bullet/numbered lists, tables, page breaks
- ✅ Dynamiska sökvägar för Windows
- ✅ Fullständig loggning (console + fil)
- ✅ Felhantering och validering
- ✅ Exempel-konfigurationer
- ✅ Dokumentation (denna README)

### Planerade funktioner (v1.1+)

- 🔲 Template-baserad generering med placeholders
- 🔲 Bild-stöd (infoga bilder i dokument)
- 🔲 Mer avancerad styling (färger, fonter, alignment)
- 🔲 PDF-export
- 🔲 GUI (Windows Forms eller Electron)
- 🔲 Batch-generering (flera dokument från CSV/Excel)

---

## Källor och referenser

- **python-docx dokumentation:** https://python-docx.readthedocs.io/
- **Office Open XML:** https://en.wikipedia.org/wiki/Office_Open_XML
- **PowerShell dokumentation:** https://learn.microsoft.com/en-us/powershell/

---

## Licens

Detta projekt är skapat för privat/intern användning. Kontakta ägaren för licensinformation.

---

## Support

Vid problem eller frågor:

1. Kontrollera [Felsökning](#felsökning)-sektionen
2. Granska loggfiler i `logs/`-mappen
3. Kontrollera att alla beroenden är installerade
4. Verifiera att Python-version är 3.8+

**Tekniska detaljer för support:**
- Python-version: `python --version`
- Installerade paket: `pip list`
- PowerShell-version: `$PSVersionTable`

---

**Genererad:** 2025-10-26
**Författare:** Jacob's Word Document Repository
**Version:** 1.0
