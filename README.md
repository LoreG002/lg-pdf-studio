# PDF Studio: Agentic Document Generation Pipeline

PDF Studio is an LLM-driven, headless publishing system designed to generate pixel-perfect, professional PDFs from HTML/CSS templates using the Model Context Protocol (MCP).

## 🛠️ Technologies

* **HTML & CSS**: The core layout and styling engine used to structure the documents.
* **SVG (Scalable Vector Graphics)**: Used exclusively for inline charts and QR codes to prevent race conditions caused by external JavaScript libraries during the rendering phase.
* **Chrome Headless**: The primary rendering engine utilized via a custom `render.sh` shell script.
* **Playwright MCP (`pdf-studio_playwright`)**: A secondary rendering integration that allows the AI agent to navigate pages, execute code, and take screenshots for visual inspection.
* **Python 3**: Employed as a fallback local HTTP server (`python3 -m http.server`) to bypass browser security restrictions on `file://` protocols.

## 🤖 Agentic Skills

### Professional PDF (`professional-pdf`)
* Generates multi-page, typographic-quality documents such as commercial offers, reports, company profiles, price lists, and menus.
* Structures content dynamically into `<section class="page">` elements, forcing page breaks instead of reducing font sizes below 9pt when content overflows.
* Requires a mandatory Quality Assurance (QA) step where the agent reviews a generated visual preview to fix text cuts, misalignments, or leftover `{{...}}` placeholders before delivery.

### Brochure & Flyer (`brochure`)
* Specializes in folded and marketing-oriented layouts, including A4 trifolds, bifold flyers, and digital catalogs.
* Implements strict marketing design principles, enforcing strong cover headlines with a maximum of 8 words and clear typographic hierarchies.
* Automatically calculates a 3mm bleed margin (+6mm total per side) for physical typography printing and provides user warnings regarding RGB to CMYK color conversions.
