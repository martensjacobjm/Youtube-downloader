#!/usr/bin/env python3
"""
Lägg till innehåll i befintligt Word-dokument
"""

from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

def add_table_example(doc):
    """Lägg till en tabell"""
    doc.add_heading('3.2.2 VERIFIERADE SPECIFIKATIONER', 2)

    # Skapa tabell med 4 kolumner
    table = doc.add_table(rows=1, cols=4)
    table.style = 'Light Grid Accent 1'

    # Rubrikrad
    hdr_cells = table.rows[0].cells
    hdr_cells[0].text = 'Parameter'
    hdr_cells[1].text = 'Värde (Imperial)'
    hdr_cells[2].text = 'Värde (SI)'
    hdr_cells[3].text = 'Status'

    # Datarader
    data = [
        ('Diskdiameter (yttre)', '10 inch', '254 mm', '✅ VERIFIERAD'),
        ('Antal diskar', '75 st', '75 st', '✅ VERIFIERAD'),
        ('Diskavstånd (gap)', '0.0092 inch', '0.234 mm', '✅ VERIFIERAD'),
        ('Max varvtal', '13 000 RPM', '13 000 RPM', '✅ MÄTT'),
        ('Max effekt', '5.8 Hp', '4.33 kW', '✅ MÄTT'),
    ]

    for param, imperial, si, status in data:
        row_cells = table.add_row().cells
        row_cells[0].text = param
        row_cells[1].text = imperial
        row_cells[2].text = si
        row_cells[3].text = status

    return doc

def add_calculations(doc):
    """Lägg till beräkningsexempel"""
    doc.add_page_break()
    doc.add_heading('3.2.3 BERÄKNAD GEOMETRI', 1)

    doc.add_heading('3.2.3.1 Diskpaketets totala axiella längd', 2)

    doc.add_paragraph('Formel:')
    formula = doc.add_paragraph('L_total = N_diskar × t_gap + (N_diskar - 1) × t_gap')
    formula.style = 'Intense Quote'

    doc.add_paragraph('där:')
    doc.add_paragraph('• L_total = diskpaketets totala axiella längd [mm]', style='List Bullet')
    doc.add_paragraph('• N_diskar = antal diskar = 75 st', style='List Bullet')
    doc.add_paragraph('• t_gap = diskavstånd = 0.234 mm', style='List Bullet')

    doc.add_paragraph('Beräkning:')
    calc = doc.add_paragraph('75 × 0.234 + 74 × 0.234 = 17.55 + 17.316 = 34.866 ≈ 35 mm')
    calc.style = 'Intense Quote'

    result = doc.add_paragraph('Resultat: Diskpaketets totala axiella längd = 35 mm ✅ BERÄKNAT')
    result.runs[0].bold = True

    return doc

def create_complete_document(output_path):
    """Skapa komplett dokument med allt innehåll"""

    doc = Document()

    # Titel
    title = doc.add_heading('KAPITEL 3.2: TESTUR ENERGY 10-TUMS TURBIN', 0)
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER

    # Metadata
    author = doc.add_paragraph('Jacob Martens')
    author.alignment = WD_ALIGN_PARAGRAPH.CENTER
    author.runs[0].bold = True

    version = doc.add_paragraph('Version 5.0')
    version.alignment = WD_ALIGN_PARAGRAPH.CENTER

    date = doc.add_paragraph('2025-10-26')
    date.alignment = WD_ALIGN_PARAGRAPH.CENTER

    doc.add_page_break()

    # Innehållsförteckning
    doc.add_heading('Innehållsförteckning', 1)
    doc.add_paragraph('[Automatisk innehållsförteckning skapas i Word]')
    doc.add_page_break()

    # Huvudinnehåll
    doc.add_heading('3.2.1 TURBINMODELL', 1)
    doc.add_paragraph(
        "TesTur Energy's 10-tums turbin utvecklades som första kommersiella "
        "implementering av Tesla-turbinprincipen för moderna tillämpningar. "
        "Designen fokuserar på lågtrycksdrift (20-150 PSI / 1.4-10.3 bar) med "
        "målsättningen att demonstrera praktisk användbarhet för energiproduktion."
    )

    # Lägg till tabell
    doc = add_table_example(doc)

    # Lägg till beräkningar
    doc = add_calculations(doc)

    # Sammanfattning
    doc.add_page_break()
    doc.add_heading('3.2.15 SAMMANFATTNING OCH SLUTSATSER', 1)

    doc.add_heading('Verifierade huvudspecifikationer', 2)

    doc.add_paragraph('Geometri:', style='Heading 3')
    doc.add_paragraph('• Diskdiameter: 254 mm (10 inch) ✅', style='List Bullet')
    doc.add_paragraph('• Antal diskar: 75 st ✅', style='List Bullet')
    doc.add_paragraph('• Diskavstånd: 0.234 mm ✅', style='List Bullet')
    doc.add_paragraph('• Total axiell längd: ~35 mm ✅', style='List Bullet')

    doc.add_paragraph('Prestanda (dynamometer-test, 150 PSI tank):', style='Heading 3')
    doc.add_paragraph('• Max effekt: 4.33 kW vid 8 000 RPM ✅', style='List Bullet')
    doc.add_paragraph('• Max moment: 6.51 Nm vid 4 000 RPM ✅', style='List Bullet')
    doc.add_paragraph('• Optimal driftpunkt: 8 000 RPM ✅', style='List Bullet')

    # Footer
    doc.add_page_break()
    footer = doc.add_paragraph('DOKUMENTSLUT KAPITEL 3.2')
    footer.runs[0].bold = True

    doc.add_paragraph('Version: 5.0 KORREKT')
    doc.add_paragraph('Datum: 2025-10-26')
    doc.add_paragraph('Författare: Jacob Martens')

    # Spara
    doc.save(output_path)
    print(f"✅ Komplett dokument skapat: {output_path}")
    print(f"📄 Dokumentet innehåller:")
    print(f"   - Formaterad titel och metadata")
    print(f"   - Innehållsförteckning")
    print(f"   - Huvudinnehåll med rubriker")
    print(f"   - Tabeller med specifikationer")
    print(f"   - Beräkningar med formler")
    print(f"   - Sammanfattning")
    print(f"\n📂 Öppna dokumentet i Word för att se allt innehåll!")

if __name__ == "__main__":
    output_path = "TesTur_Kapitel_3.2_KOMPLETT.docx"
    create_complete_document(output_path)
