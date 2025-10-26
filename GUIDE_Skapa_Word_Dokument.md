# Guide: Skapa Word-dokument från XML i VS Code

## 📋 Översikt

Det finns flera sätt att arbeta med Word-dokumentkod i VS Code.

## 🔧 Metod 1: Python-skript (REKOMMENDERAT)

### Steg 1: Kör Python-skriptet

```bash
# Från terminalen i VS Code
python3 create_word_doc.py
```

Detta skapar ett formaterat Word-dokument: `TesTur_Kapitel_3.2_Formatted.docx`

### Steg 2: Öppna dokumentet

```bash
# Linux/WSL
xdg-open TesTur_Kapitel_3.2_Formatted.docx

# Windows
start TesTur_Kapitel_3.2_Formatted.docx

# macOS
open TesTur_Kapitel_3.2_Formatted.docx
```

## 🔧 Metod 2: Om du har en befintlig document.xml

### Steg 1: Se till att du har XML-filen

```bash
# Skapa word-katalog om den inte finns
mkdir -p word

# Placera din document.xml där
# (kopiera från ditt befintliga Word-dokument)
```

### Steg 2: Extrahera från befintligt .docx

```bash
# Ett .docx-dokument är en ZIP-fil
# Packa upp det för att komma åt XML-filerna

unzip ditt_dokument.docx -d word_unpacked/
cd word_unpacked/word
cat document.xml  # Här är XML-koden
```

### Steg 3: Använd Python för att konvertera

```bash
python3 create_word_doc.py from-xml
```

## 🔧 Metod 3: Manuellt i VS Code med pandoc

### Installera pandoc

```bash
# Ubuntu/Debian
sudo apt-get install pandoc

# macOS
brew install pandoc

# Windows (via Chocolatey)
choco install pandoc
```

### Skapa Markdown-fil först

```bash
# Skapa en .md-fil i VS Code
# Skriv ditt innehåll i Markdown-format
```

### Konvertera till Word

```bash
pandoc din_fil.md -o output.docx
```

## 🔧 Metod 4: Använd Word Online/Desktop

### För bäst resultat:

1. **Kopiera innehållet** från XML (texten mellan `<w:t>` taggarna)
2. **Öppna Word** (Desktop eller Online på office.com)
3. **Klistra in** och formatera
4. **Spara** som .docx

## 📊 XML-struktur förklaring

```xml
<w:t>Detta är text i dokumentet</w:t>  <!-- Text -->
<w:p>                                   <!-- Paragraf -->
<w:tbl>                                 <!-- Tabell -->
<w:r>                                   <!-- Run (formateringsblock) -->
```

## 🎯 Snabbstart: Skapa ditt TesTur-dokument

```bash
# 1. Navigera till projektkatalogen
cd /home/user/Youtube-downloader

# 2. Kör Python-skriptet
python3 create_word_doc.py

# 3. Öppna resultatet
# Dokumentet heter: TesTur_Kapitel_3.2_Formatted.docx
```

## 🔍 Felsökning

### Problem: "python3: command not found"
```bash
# Installera Python
sudo apt-get install python3
```

### Problem: "No module named 'docx'"
```bash
# Installera python-docx
pip3 install python-docx
```

### Problem: "Permission denied"
```bash
# Lägg till exekveringsrättigheter
chmod +x create_word_doc.py
```

## 📝 Tips för VS Code

### Installera användbara tillägg:

1. **Python** (ms-python.python)
2. **XML Tools** (DotJoshJohnson.xml)
3. **Office Viewer** (cweijan.vscode-office)

### Kortkommandon:

- `Ctrl + Shift + P` - Command Palette
- `Ctrl + ` ` - Toggle Terminal
- `Ctrl + B` - Toggle Sidebar

## 🚀 Avancerat: Redigera Word-XML direkt

### Om du vill redigera XML direkt:

```bash
# 1. Packa upp Word-dokumentet
unzip dokument.docx -d temp_word

# 2. Redigera XML i VS Code
code temp_word/word/document.xml

# 3. Packa ihop igen
cd temp_word
zip -r ../dokument_ny.docx *
```

⚠️ **VARNING**: Redigering av Word-XML direkt kan göra dokumentet oläsbart om XML:en blir felaktig!

## ✅ Rekommenderad arbetsgång

1. **Använd Python-skriptet** för att skapa grunddokument
2. **Öppna i Word** för finformatering
3. **Spara som .docx** för slutgiltig version

