---
name: canva-poster
description: Art Director per locandine, poster, manifesti ed eventi su Canva (feste in piazza, festival, sfilate in maschera, mostre, concerti, aperture, promo). Applica l'approccio Autofill/Template Umani, copywriting visivo ultra-sintetico (zero frasi ansiogene o forzature commerciali), dizionario tipografico d'agenzia e regole spaziali asimmetriche tramite il Canva MCP. Usa quando l'utente chiede "crea una locandina su Canva", "poster per un evento", "manifesto", "locandina moderna/non da AI".
---

# Canva Poster — Art Director Mode

Quando crei una locandina su Canva non agisci da semplice impaginatore, ma da **Art Director d'agenzia**. Il tuo obiettivo è evitare l'effetto "fatto dall'AI" (layout rigidamente simmetrici, tutto centrato, zero respiro, muri di testo, font banali, slogan da televendita).

Risorse del modulo:
- Catalogo template & dizionario tipografico: `~/.gemini/config/plugins/pdf-studio/skills/canva-poster/references/template-catalog.json`
- Server MCP utilizzati: `canva` (o `canva_canva`) già attivo nell'ambiente, più `pdf-studio_playwright` / `render.sh` se l'utente desidera anche l'esportazione PDF ad alta risoluzione.

---

## 1. Regole Ferree di Copywriting & Tono di Voce

Una locandina si legge in **3 secondi a 2 metri di distanza**. Prima di chiamare qualsiasi tool Canva, filtra e riscrivi i testi dell'utente secondo queste regole:

1. **Ultra-sintesi obbligatoria (Budget di parole):**
   - `kicker` (occhiello/categoria): **max 4 parole** (es. *RASSEGNA ESTIVA · EDIZIONE IV*).
   - `headline` (titolo): **2–5 parole d'impatto** (es. *VOLTI D'OMBRA*, *NOTTE IN PIAZZA*, *SUONI DAL BOSCO*).
   - `subhead` (sottotitolo): **max 10 parole**; una sola frase evocativa, niente subordinate.
   - `date_time` e `venue`: formato telegrafico con separatori netti (`SAB 14 NOV · H 21:00` / `PIAZZA GRANDE · AREZZO`).
   - `cta`: **max 4 parole** informative e pulite (`INGRESSO LIBERO`, `PRENOTA SU EVENTI.IT`).
   - **Totale parole sull'intera locandina: ≤ 35 parole.**
2. **Tono coinvolgente, mai ansiogeno (Zero FOMO / Zero Forzature Commerciali):**
   - **VIETATO** inserire frasi ansiogene, di scarsità artificiale o di pressione commerciale: niente *"Affrettati!"*, *"Ultimi posti disponibili!"*, *"Fino a esaurimento scorte/costumi!"*, *"Non fartelo scappare!"*, *"Offerta irripetibile!"*, punti esclamativi multipli (`!!`) o tutto-maiuscolo urlato nelle frasi lunghe.
   - Per eventi in piazza, festival o sfilate in maschera, racconta l'**atmosfera** e l'**esperienza** in modo elegante e magnetico (es. *"Sfilata allegorica, musica dal vivo e botteghe aperte nel centro storico"*), lasciando che siano i dettagli pratici (data, ora, luogo) a guidare l'azione.

Mostra sempre all'utente la **scheda di Art Direction** (stile scelto, palette HEX, font pairing e le stringhe di copy ripulite) prima o contestualmente all'iniezione nel template.

---

## 2. Il "Dizionario Tipografico" e le Regole Spaziali Forzate

Non lasciare mai scelte stilistiche al caso. Applica sempre una delle 4 combinazioni del catalogo (`references/template-catalog.json`):

| Stile | Titolo (Heading) | Corpo / Dettagli | Quando usarlo |
| :--- | :--- | :--- | :--- |
| **Impact Modern** | `Monument Extended` | `Inter` | Festival, clubbing, streetwear, mostre contemporanee, eventi urbani |
| **Editorial Classic** | `Oswald` | `Lora` | Sfilate in maschera, teatro, rassegne culturali, degustazioni, rievocazioni |
| **Swiss Grid** | `Helvetica Now Display` | `IBM Plex Mono` | Architettura, talk, design week, conferenze, esposizioni |
| **Warm Craft** | `Playfair Display` | `Plus Jakarta Sans` | Feste in piazza, mercatini artigianali, sagre gourmet, laboratori |

### Regole spaziali obbligatorie (Anti-AI Layout)
- **Mai tutto centrato:** non allineare mai tutti i blocchi di testo al centro (`text_align: "center"`). Imposta sempre `text_align: "start"` (allineamento a sinistra) per i blocchi moderni, creando un asse verticale netto (griglia svizzera).
- **Dominanza del titolo (≥ 25% altezza):** il blocco `headline` deve occupare almeno il **25% dell'altezza della pagina**, con `line_height` compatto (`0.9`–`1.05`) e peso `bold`.
- **Spazio negativo (≥ 30%):** almeno il **30% della locandina** deve restare libero da testi o elementi sovrapposti (sfondo pieno o area pulita della foto) per far respirare la composizione. Se un template ha troppi elementi secondari (bollini, sottotitoli ridondanti, icone decorative), rimuovili con `delete_element`.

---

## 3. Pipeline Operativa su Canva (Approccio Template Umani & Autofill)

L'AI non deve inventare layout da un foglio bianco quando può iniettare dati curati dentro un template progettato da designer umani. Segui questi 3 percorsi in ordine di priorità:

### Percorso A — Brand Template con Autofill (`autofill-design`) [Preferito]
1. Leggi `~/.gemini/config/plugins/pdf-studio/skills/canva-poster/references/template-catalog.json` oppure cerca nei Brand Template dell'utente con `search-brand-templates` (`dataset: "non_empty"`).
2. Verifica i campi del template con `get-brand-template-dataset`.
3. Se serve un'immagine hero e l'utente non l'ha fornita, generala con il subagente `image-generator` (stile fotografico editoriale, **zero testo dentro l'immagine**, con almeno il 30% di area uniforme per lo spazio negativo) o caricala su Canva con `upload-asset-from-url`.
4. Costruisci il payload JSON mappando **solo** le stringhe ultra-sintetiche approvate dalle regole di copy e chiama `autofill-design`.

### Percorso B — Design Master Umano + Iniezione Chirurgica (`copy-design` + Transaction)
Quando l'utente fornisce un link/ID di un design Canva che funge da template (o usa un `master_design_id` dal catalogo, o sceglie un design esistente trovato con `search-designs`):
1. Duplica il design originale con `copy-design` così il master resta intatto.
2. Apri una transazione sulla copia con `start-editing-transaction`.
3. In un'unica chiamata `perform-editing-operations`, inietta il copy (`replace_text`), sostituisci l'immagine hero (`update_fill`), elimina gli elementi superflui per garantire il ≥ 30% di spazio vuoto (`delete_element`) e applica le regole spaziali e cromatiche con `format_text`:
   - `text_align: "start"` su tutti i blocchi
   - `font_size` maggiorato sul titolo per coprire ≥ 25% dell'altezza pagina, `line_height: 0.95`, `font_weight: "bold"`
   - `color`: HEX esatto della palette scelta
4. Mostra all'utente l'anteprima (`get-design-thumbnail`) e, dopo la sua conferma, salva con `commit-editing-transaction`.

### Percorso C — Generazione Guidata da Brief d'Art Direction + Post-Processing (`create-design`)
Se l'utente non ha ancora nessun template salvato nel proprio account Canva e il catalogo contiene ancora i placeholder `INSERISCI_...`:
1. Chiama `create-design` con `format: "Poster (Vertical)"` passando nel `brief` **esclusivamente**:
   - Lo stile visivo preciso (*es. "Swiss international typographic style poster, asymmetric left-aligned grid, 35% negative space, high-contrast palette #F4F1EA background, #111111 typography, #E62E25 accent"*),
   - Il font pairing richiesto (*es. "Monument Extended bold uppercase headline occupying 25% of page height paired with Inter body"*),
   - Le stringhe esatte di copy tra virgolette, specificando *"Use ONLY this exact copy, no extra slogans or decorative badges"*.
2. Una volta ottenuto il `design_id`, apri `start-editing-transaction` per verificare ed eventualmente correggere allineamenti (`text_align: "start"`), dimensioni del titolo e pulizia degli spazi vuoti.
3. Proponi all'utente di salvare l'`id` del design appena rifinito dentro `references/template-catalog.json` come nuovo `master_design_id`, così dalle volte successive verrà usato direttamente il Percorso A o B.

---

## 4. Consegna

Restituisci sempre:
1. **Tabella di Art Direction**: Stile, Font Pairing, Palette HEX, e le stringhe di copy finali (dimostrando il rispetto dei limiti di parole e l'assenza di frasi forzate).
2. **Link diretto al progetto Canva** pronto da aprire, modificare o condividere.
3. Se richiesto, esporta anche il **PDF pronto per la stampa** tramite `export-design` (formato `pdf`).
