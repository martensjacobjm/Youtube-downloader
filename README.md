# Youtube-downloader

Repository innehåller två huvudkomponenter:

## 1. YouTube Downloader (v8)
Interactive PowerShell-baserad YouTube nedladdare med yt-dlp.

**Dokumentation:**
- [YouTube_Downloader_v8_GUIDE.md](YouTube_Downloader_v8_GUIDE.md) - Användarguide
- [YouTube_Downloader_COMPLETE_DOCUMENTATION_v8.md](YouTube_Downloader_COMPLETE_DOCUMENTATION_v8.md) - Komplett dokumentation

**Snabbstart:**
```powershell
.\RUN_DOWNLOADER.ps1
```

---

## 2. Word Document Generator (v1.0)
Python-baserat system för att skapa Word-dokument programmatiskt med JSON-konfiguration.

**Plats:** `word_generator/`

**Funktioner:**
- Skapa Word-dokument från JSON-konfiguration
- Stöd för rubriker, paragrafer, listor, tabeller
- Dynamiska sökvägar för Windows
- PowerShell wrapper med interaktiv meny
- Fullständig loggning och felhantering

**Snabbstart:**
```powershell
cd word_generator
.\RUN_WORD_GENERATOR.bat
```

**Dokumentation:**
Se [word_generator/README.md](word_generator/README.md) för komplett guide.

---

## Systemkrav

**YouTube Downloader:**
- Windows 10/11
- PowerShell 5.1+
- yt-dlp (installeras automatiskt)

**Word Document Generator:**
- Windows 10/11
- Python 3.8+
- python-docx (installeras automatiskt)
- PowerShell 5.1+

---

## Licens
Privat/intern användning. Kontakta ägaren för licensinformation.