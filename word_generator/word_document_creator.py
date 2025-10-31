#!/usr/bin/env python3
"""
Purpose: Word document generator using python-docx library with XML manipulation support
Author: Generated for Jacob's Word Document Repository
Notes: Comments in English; designed for Windows with dynamic paths
Dependencies: python-docx, lxml (optional for advanced XML manipulation)
"""

import logging
import sys
import pathlib
import json
from datetime import datetime
from typing import Optional, Dict, List, Any

# Third-party imports (will be installed via requirements.txt)
try:
    from docx import Document
    from docx.shared import Pt, Inches, RGBColor
    from docx.enum.text import WD_ALIGN_PARAGRAPH
except ImportError:
    print("[ERROR] python-docx not installed. Run: pip install python-docx")
    sys.exit(1)


class WordDocumentCreator:
    """
    Create and manipulate Word documents programmatically.
    Supports templates, dynamic content, and styling.
    """

    def __init__(self, base_dir: Optional[pathlib.Path] = None, log_level: str = "INFO"):
        """
        Initialize the Word document creator.

        Args:
            base_dir: Base directory for output (defaults to script directory)
            log_level: Logging level (DEBUG, INFO, WARNING, ERROR)
        """
        self.base_dir = base_dir or pathlib.Path(__file__).parent
        self.output_dir = self.base_dir / "output"
        self.templates_dir = self.base_dir / "templates"
        self.log_file = self.base_dir / "logs" / f"word_creator_{datetime.now():%Y%m%d_%H%M%S}.log"

        # Ensure directories exist
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.templates_dir.mkdir(parents=True, exist_ok=True)
        self.log_file.parent.mkdir(parents=True, exist_ok=True)

        # Setup logging
        self._setup_logging(log_level)

        logging.info(f"WordDocumentCreator initialized")
        logging.info(f"Base directory: {self.base_dir}")
        logging.info(f"Output directory: {self.output_dir}")

    def _setup_logging(self, level: str):
        """Configure logging to both console and file."""
        numeric_level = getattr(logging, level.upper(), logging.INFO)

        logging.basicConfig(
            level=numeric_level,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[
                logging.StreamHandler(sys.stdout),
                logging.FileHandler(self.log_file, encoding="utf-8")
            ]
        )

    def create_document(
        self,
        filename: str,
        title: Optional[str] = None,
        content: Optional[List[Dict[str, Any]]] = None
    ) -> pathlib.Path:
        """
        Create a new Word document with specified content.

        Args:
            filename: Output filename (without path)
            title: Document title (optional)
            content: List of content blocks (see documentation for format)

        Returns:
            Path to created document

        Example content format:
        [
            {"type": "heading", "text": "Main Title", "level": 1},
            {"type": "paragraph", "text": "Some text", "bold": False},
            {"type": "bullet_list", "items": ["Item 1", "Item 2"]},
            {"type": "table", "data": [["A", "B"], ["1", "2"]], "headers": True}
        ]
        """
        try:
            logging.info(f"Creating document: {filename}")

            # Create new document
            doc = Document()

            # Add title if provided
            if title:
                heading = doc.add_heading(title, level=0)
                heading.alignment = WD_ALIGN_PARAGRAPH.CENTER

            # Add content blocks
            if content:
                for block in content:
                    self._add_content_block(doc, block)

            # Save document
            output_path = self.output_dir / filename
            if not output_path.suffix:
                output_path = output_path.with_suffix('.docx')

            doc.save(str(output_path))
            logging.info(f"Document saved: {output_path}")

            return output_path

        except Exception as e:
            logging.error(f"Failed to create document: {e}")
            raise

    def _add_content_block(self, doc: Document, block: Dict[str, Any]):
        """Add a content block to the document based on type."""
        block_type = block.get("type", "paragraph")

        if block_type == "heading":
            level = block.get("level", 1)
            text = block.get("text", "")
            doc.add_heading(text, level=level)

        elif block_type == "paragraph":
            text = block.get("text", "")
            para = doc.add_paragraph(text)

            # Apply styling if specified
            if block.get("bold"):
                para.runs[0].bold = True
            if block.get("italic"):
                para.runs[0].italic = True
            if block.get("font_size"):
                para.runs[0].font.size = Pt(block["font_size"])

        elif block_type == "bullet_list":
            items = block.get("items", [])
            for item in items:
                doc.add_paragraph(item, style='List Bullet')

        elif block_type == "numbered_list":
            items = block.get("items", [])
            for item in items:
                doc.add_paragraph(item, style='List Number')

        elif block_type == "table":
            data = block.get("data", [])
            has_headers = block.get("headers", False)

            if data:
                rows = len(data)
                cols = len(data[0]) if data else 0
                table = doc.add_table(rows=rows, cols=cols)
                table.style = 'Light Grid Accent 1'

                for i, row_data in enumerate(data):
                    row = table.rows[i]
                    for j, cell_data in enumerate(row_data):
                        row.cells[j].text = str(cell_data)

                        # Bold header row
                        if i == 0 and has_headers:
                            row.cells[j].paragraphs[0].runs[0].bold = True

        elif block_type == "page_break":
            doc.add_page_break()

        else:
            logging.warning(f"Unknown block type: {block_type}")

    def create_from_template(
        self,
        template_name: str,
        output_name: str,
        replacements: Dict[str, str]
    ) -> pathlib.Path:
        """
        Create a document from a template with placeholder replacements.

        Args:
            template_name: Name of template file in templates directory
            output_name: Output filename
            replacements: Dictionary of placeholder -> value mappings

        Returns:
            Path to created document
        """
        try:
            template_path = self.templates_dir / template_name
            if not template_path.exists():
                raise FileNotFoundError(f"Template not found: {template_path}")

            logging.info(f"Creating document from template: {template_name}")

            # Load template
            doc = Document(str(template_path))

            # Replace placeholders in paragraphs
            for paragraph in doc.paragraphs:
                for key, value in replacements.items():
                    if key in paragraph.text:
                        paragraph.text = paragraph.text.replace(key, value)

            # Replace placeholders in tables
            for table in doc.tables:
                for row in table.rows:
                    for cell in row.cells:
                        for key, value in replacements.items():
                            if key in cell.text:
                                cell.text = cell.text.replace(key, value)

            # Save document
            output_path = self.output_dir / output_name
            if not output_path.suffix:
                output_path = output_path.with_suffix('.docx')

            doc.save(str(output_path))
            logging.info(f"Document saved: {output_path}")

            return output_path

        except Exception as e:
            logging.error(f"Failed to create document from template: {e}")
            raise

    def create_from_config(self, config_file: pathlib.Path) -> pathlib.Path:
        """
        Create a document from a JSON configuration file.

        Args:
            config_file: Path to JSON configuration file

        Returns:
            Path to created document
        """
        try:
            logging.info(f"Loading configuration: {config_file}")

            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)

            filename = config.get("filename", "output.docx")
            title = config.get("title")
            content = config.get("content", [])

            return self.create_document(filename, title, content)

        except Exception as e:
            logging.error(f"Failed to create document from config: {e}")
            raise


def main():
    """Main entry point for standalone execution."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Word Document Creator - Generate .docx files programmatically"
    )
    parser.add_argument(
        "--base-dir",
        type=pathlib.Path,
        help="Base directory for operations (default: script directory)"
    )
    parser.add_argument(
        "--config",
        type=pathlib.Path,
        help="JSON configuration file for document creation"
    )
    parser.add_argument(
        "--output",
        type=str,
        help="Output filename"
    )
    parser.add_argument(
        "--title",
        type=str,
        help="Document title"
    )
    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level"
    )

    args = parser.parse_args()

    # Initialize creator
    creator = WordDocumentCreator(
        base_dir=args.base_dir,
        log_level=args.log_level
    )

    # Create document
    if args.config:
        output_path = creator.create_from_config(args.config)
    else:
        # Create simple document with title only
        output = args.output or "output.docx"
        output_path = creator.create_document(
            filename=output,
            title=args.title or "Untitled Document"
        )

    print(f"\n[SUCCESS] Document created: {output_path}")
    print(f"[LOG] Check log file: {creator.log_file}")


if __name__ == "__main__":
    main()
