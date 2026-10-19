#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates the static GitHub Pages site in _site/ from app/assets/images/
# Usage: ruby bin/generate_static_site.rb [output_dir]

require 'fileutils'
require 'json'
require 'time'
require 'uri'

ROOT_DIR = File.expand_path('..', __dir__)
OUT_DIR = File.expand_path(ARGV[0] || File.join(ROOT_DIR, '_site'))
VERSION = File.read(File.join(ROOT_DIR, 'VERSION')).strip rescue '2.10'

FOLDERS = {
  'vanilla' => {
    label: '🍝 Vanilla (Pasta & Co.)',
    description: 'Child-safe Italian pasta & fun objects alphabet'
  },
  'ajcarlesso' => {
    label: '👨‍👩‍👦‍👦 AJ Carlesso (Family)',
    description: 'Original Carlesso family alphabet built for Alessandro in 24h'
  },
  'ajcarlesso-loads' => {
    label: '📸 AJ Loads (Extended)',
    description: 'Extended collection of family & objects photos'
  }
}.freeze

IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp .gif].freeze

def get_image_dimensions(path)
  # Use `file` or `sips` if available to determine dimensions
  out = `file #{Regexp.escape(path)} 2>/dev/null`
  if out =~ /(\d+)\s*x\s*(\d+)/
    w = Regexp.last_match(1).to_i
    h = Regexp.last_match(2).to_i
    return [w, h] if w > 0 && h > 0
  end
  [400, 300]
rescue StandardError
  [400, 300]
end

def classify_verticality(width, height)
  ar = width.to_f / height.to_f
  return 'very_wide' if ar > 1.52
  return 'landscape' if ar.between?(1.21, 1.52)
  return 'square'    if ar.between?(0.83, 1.209)
  return 'portrait'  if ar.between?(0.62, 0.829)
  'very_tall'
end

def parse_bilingual(filename)
  basename = File.basename(filename, File.extname(filename))
  if basename =~ /\A(.+?)\s*\((.+?)\)/
    it_raw = Regexp.last_match(1).strip
    en_raw = Regexp.last_match(2).strip
  else
    it_raw = basename.strip
    en_raw = basename.strip
  end

  clean_word = lambda do |w|
    first = w.split(/[\s_-]+/).first.to_s
    first.empty? ? '??' : first.capitalize
  end

  [clean_word.call(it_raw), clean_word.call(en_raw), basename]
end

puts "🚀 Building Baby Alphabet v#{VERSION} static site into #{OUT_DIR}..."
FileUtils.rm_rf(OUT_DIR)
FileUtils.mkdir_p(File.join(OUT_DIR, 'images'))
File.write(File.join(OUT_DIR, '.nojekyll'), '')

catalog = {
  version: VERSION,
  generated_at: Time.now.utc.iso8601,
  folders: {}
}

FOLDERS.each do |folder_key, meta|
  src_dir = File.join(ROOT_DIR, 'app', 'assets', 'images', folder_key)
  next unless Dir.exist?(src_dir)

  dst_dir = File.join(OUT_DIR, 'images', folder_key)
  FileUtils.mkdir_p(dst_dir)

  items = []
  Dir.children(src_dir, encoding: 'UTF-8').sort.each do |raw_entry|
    entry = raw_entry.encode('UTF-8', invalid: :replace, undef: :replace)
    full_path = File.join(src_dir, entry)
    next unless File.file?(full_path)
    ext = File.extname(entry).downcase
    next unless IMAGE_EXTENSIONS.include?(ext)

    FileUtils.cp(full_path, File.join(dst_dir, entry))
    next if entry.start_with?('_') # skip _empty, _portrait, _landscape placeholders from main items

    initial = entry[0].upcase
    next unless ('A'..'Z').include?(initial)

    w, h = get_image_dimensions(full_path)
    vert = classify_verticality(w, h)
    word_it, word_en, full_label = parse_bilingual(entry)

    items << {
      filename: entry,
      url: "images/#{folder_key}/#{URI.encode_www_form_component(entry).gsub('+', '%20')}",
      letter: initial,
      word_it: word_it,
      word_en: word_en,
      full_label: full_label,
      width: w,
      height: h,
      aspect_ratio: (w.to_f / h.to_f).round(2),
      verticality: vert
    }
  end

  catalog[:folders][folder_key] = {
    label: meta[:label],
    description: meta[:description],
    count: items.size,
    items: items
  }
  puts "  ✅ #{folder_key}: copied #{items.size} alphabet pictures"
end

File.write(File.join(OUT_DIR, 'data.json'), JSON.pretty_generate(catalog))

index_html = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>🔤 AJ Baby Alphabet — Interactive Bilingual Alphabet</title>
  <style>
    :root {
      --bg: #f8fafc;
      --card-bg: #ffffff;
      --text: #0f172a;
      --muted: #475569;
      --accent: #0284c7;
      --accent-light: #e0f2fe;
      --border: #e2e8f0;
      --badge-bg: rgba(15, 23, 42, 0.52);
      --badge-text: rgba(255, 255, 255, 0.92);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
    }
    /* Top Navigation Bar */
    .topbar {
      position: sticky;
      top: 0;
      z-index: 30;
      background: rgba(255, 255, 255, 0.92);
      backdrop-filter: blur(10px);
      -webkit-backdrop-filter: blur(10px);
      border-bottom: 1px solid var(--border);
      padding: 0.75rem 1.25rem;
      box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    }
    .topbar-inner {
      max-width: 1440px;
      margin: 0 auto;
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem 1.25rem;
      align-items: center;
      justify-content: space-between;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 0.6rem;
      font-weight: 800;
      font-size: 1.25rem;
      color: var(--text);
      text-decoration: none;
    }
    .brand span.version {
      font-size: 0.75rem;
      font-weight: 600;
      background: var(--accent-light);
      color: var(--accent);
      padding: 0.15rem 0.5rem;
      border-radius: 999px;
    }
    .controls {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      align-items: center;
    }
    .control-group {
      display: inline-flex;
      align-items: center;
      background: #f1f5f9;
      padding: 0.2rem;
      border-radius: 0.6rem;
      border: 1px solid var(--border);
    }
    .control-group button, .control-group select {
      border: none;
      background: transparent;
      padding: 0.35rem 0.65rem;
      font-size: 0.85rem;
      font-weight: 600;
      color: var(--muted);
      border-radius: 0.45rem;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .control-group button.active {
      background: #ffffff;
      color: var(--text);
      box-shadow: 0 1px 2px rgba(0,0,0,0.08);
    }
    .control-group button:hover:not(.active) {
      color: var(--text);
    }
    .btn-action {
      border: 1px solid var(--border);
      background: #ffffff;
      padding: 0.45rem 0.8rem;
      font-size: 0.85rem;
      font-weight: 600;
      border-radius: 0.55rem;
      cursor: pointer;
      color: var(--text);
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      box-shadow: 0 1px 2px rgba(0,0,0,0.03);
    }
    .btn-action:hover {
      background: #f8fafc;
      border-color: #cbd5e1;
    }
    /* Alphabet quick jump strip */
    .letter-strip {
      max-width: 1440px;
      margin: 0.5rem auto 0;
      padding-top: 0.5rem;
      border-top: 1px solid #f1f5f9;
      display: flex;
      flex-wrap: wrap;
      gap: 0.25rem;
      justify-content: center;
    }
    .letter-pill {
      min-width: 28px;
      height: 28px;
      padding: 0 6px;
      border-radius: 6px;
      border: 1px solid transparent;
      background: transparent;
      font-weight: 700;
      font-size: 0.8rem;
      cursor: pointer;
      color: var(--muted);
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    .letter-pill:hover, .letter-pill.active {
      background: var(--accent);
      color: white;
    }
    .letter-pill.empty-letter {
      opacity: 0.35;
    }

    /* Main Content Container */
    main {
      max-width: 1440px;
      margin: 1.25rem auto 3rem;
      padding: 0 1.25rem;
    }
    .story-banner {
      background: linear-gradient(135deg, #eff6ff 0%, #f0f9ff 100%);
      border: 1px solid #bae6fd;
      border-radius: 1rem;
      padding: 1rem 1.25rem;
      margin-bottom: 1.25rem;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
    }
    .story-banner p {
      margin: 0;
      font-size: 0.95rem;
      color: #0369a1;
    }

    /* Alphabet Grid */
    .alphabet-grid {
      display: grid;
      grid-template-columns: repeat(var(--cols, 4), minmax(0, 1fr));
      gap: 1rem;
    }
    @media (max-width: 1024px) {
      .alphabet-grid { grid-template-columns: repeat(min(var(--cols, 4), 3), minmax(0, 1fr)); }
    }
    @media (max-width: 720px) {
      .alphabet-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0.75rem; }
    }
    @media (max-width: 440px) {
      .alphabet-grid { grid-template-columns: 1fr; }
    }

    /* Card */
    .letter-card {
      position: relative;
      border-radius: 1rem;
      overflow: hidden;
      background: #1e293b;
      box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
      cursor: pointer;
      transition: transform 0.18s ease, box-shadow 0.18s ease;
      aspect-ratio: var(--card-aspect, 4 / 3);
      user-select: none;
    }
    .letter-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 10px 20px rgba(15, 23, 42, 0.14);
    }
    .letter-card img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      transition: transform 0.3s ease;
    }
    .letter-card:hover img {
      transform: scale(1.03);
    }

    /* Semi-transparent Letter Overlay (A/B/C) on top of the image */
    .letter-watermark {
      position: absolute;
      top: 12px;
      right: 14px;
      z-index: 3;
      font-size: clamp(2.4rem, 4.5vw, 3.8rem);
      font-weight: 900;
      line-height: 1;
      color: var(--badge-text);
      background: var(--badge-bg);
      backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
      padding: 0.2em 0.42em;
      border-radius: 0.4em;
      border: 2px solid rgba(255, 255, 255, 0.38);
      text-shadow: 0 2px 10px rgba(0, 0, 0, 0.55);
      letter-spacing: -0.02em;
      pointer-events: none;
    }
    .letter-watermark .lowercase-sub {
      font-size: 0.55em;
      font-weight: 700;
      opacity: 0.82;
      margin-left: 2px;
    }

    /* Card Count Pill (top-left) */
    .photo-count-pill {
      position: absolute;
      top: 12px;
      left: 12px;
      z-index: 3;
      background: rgba(15, 23, 42, 0.55);
      color: rgba(255, 255, 255, 0.9);
      font-size: 0.75rem;
      font-weight: 700;
      padding: 0.2rem 0.55rem;
      border-radius: 999px;
      backdrop-filter: blur(4px);
    }

    /* Frosted Glass Word Caption Bar */
    .card-caption {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      z-index: 3;
      padding: 0.65rem 0.85rem;
      background: linear-gradient(to top, rgba(15, 23, 42, 0.86) 0%, rgba(15, 23, 42, 0.58) 70%, rgba(15, 23, 42, 0.0) 100%);
      backdrop-filter: blur(4px);
      -webkit-backdrop-filter: blur(4px);
      color: #ffffff;
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 0.5rem;
    }
    .words-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: 0.35rem 0.75rem;
      align-items: baseline;
      font-weight: 800;
      font-size: clamp(1rem, 1.5vw, 1.35rem);
      text-shadow: 0 1px 4px rgba(0,0,0,0.8);
    }
    .word-item .initial-highlight {
      color: #fde047;
      text-decoration: underline;
      text-underline-offset: 3px;
    }
    .speak-btn {
      background: rgba(255, 255, 255, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.35);
      color: white;
      border-radius: 999px;
      width: 32px;
      height: 32px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      flex-shrink: 0;
      font-size: 0.95rem;
    }
    .speak-btn:hover {
      background: rgba(255, 255, 255, 0.35);
    }

    /* Modal for single letter detail */
    .modal-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(15, 23, 42, 0.72);
      backdrop-filter: blur(6px);
      z-index: 50;
      display: none;
      align-items: center;
      justify-content: center;
      padding: 1.25rem;
    }
    .modal-backdrop.open {
      display: flex;
    }
    .modal-content {
      background: white;
      border-radius: 1.25rem;
      max-width: 1050px;
      width: 100%;
      max-height: 90vh;
      overflow-y: auto;
      padding: 1.5rem;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.35);
    }
    .modal-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 1px solid var(--border);
      padding-bottom: 0.85rem;
      margin-bottom: 1.25rem;
    }
    .modal-header h2 {
      margin: 0;
      font-size: 1.75rem;
      display: flex;
      align-items: center;
      gap: 0.6rem;
    }
    .modal-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 1rem;
    }

    footer {
      text-align: center;
      padding: 2rem 1rem;
      border-top: 1px solid var(--border);
      color: var(--muted);
      font-size: 0.9rem;
    }
    footer a {
      color: var(--accent);
      text-decoration: none;
      font-weight: 600;
    }

    /* Print friendly mode */
    body.print-friendly .topbar,
    body.print-friendly .story-banner,
    body.print-friendly footer,
    body.print-friendly .photo-count-pill,
    body.print-friendly .speak-btn {
      display: none !important;
    }
    @media print {
      .topbar, .story-banner, footer, .photo-count-pill, .speak-btn {
        display: none !important;
      }
      main { margin: 0; padding: 0; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <a href="#" class="brand" id="resetViewBtn">
        <span>🔤 AJ Alphabet</span>
        <span class="version">v#{VERSION}</span>
      </a>

      <div class="controls">
        <!-- Dataset Switcher -->
        <div class="control-group" id="folderGroup" title="Choose picture collection">
          <button data-folder="vanilla" class="active">🍝 Vanilla (Pasta)</button>
          <button data-folder="ajcarlesso">👨‍👩‍👦‍👦 AJ Family</button>
          <button data-folder="all">🌍 All Pics</button>
        </div>

        <!-- Alphabet Language Switcher -->
        <div class="control-group" id="langGroup" title="Choose 26-letter UK or 21-letter Italian alphabet">
          <button data-lang="uk" class="active">🇬🇧 A–Z (26)</button>
          <button data-lang="it">🇮🇹 IT (21)</button>
        </div>

        <!-- Layout Orientation Switcher -->
        <div class="control-group" id="layoutGroup" title="Card orientation & columns">
          <button data-layout="landscape" class="active">🖼️ Hor (4 col)</button>
          <button data-layout="portrait">📱 Ver (6 col Kate)</button>
          <button data-layout="square">⏹️ Square (5 col)</button>
        </div>

        <button class="btn-action" id="shuffleBtn" title="Pick another random photo for letters with multiple photos">
          🎲 Shuffle
        </button>
        <button class="btn-action" id="printBtn" title="Toggle print-friendly mode">
          🖨️ Print
        </button>
      </div>
    </div>

    <div class="letter-strip" id="letterStrip"></div>
  </header>

  <main>
    <div class="story-banner">
      <p>
        💡 <strong>Born on Jan 9, 2021:</strong> Built in 24 hours when my wife told me our son Alessandro was a bit late reading letters of the alphabet —
        <em>"tranquilla, leave it with me!"</em> Click any card to inspect all pictures or hear the pronunciation! 🔊
      </p>
    </div>

    <div class="alphabet-grid" id="alphabetGrid"></div>
  </main>

  <div class="modal-backdrop" id="letterModal">
    <div class="modal-content">
      <div class="modal-header">
        <h2 id="modalTitle">Letter A</h2>
        <button class="btn-action" id="closeModalBtn">✕ Close (Esc)</button>
      </div>
      <div class="modal-grid" id="modalGrid"></div>
    </div>
  </div>

  <footer>
    AJ Alfabeto v#{VERSION} •
    GitHub: <a href="https://github.com/palladius/baby-alphabet" target="_blank" rel="noopener">palladius/baby-alphabet</a> •
    Hosted on <a href="https://palladius.github.io/baby-alphabet/">GitHub Pages</a>
  </footer>

  <script>
    const ITALIAN_LETTERS = ['A','B','C','D','E','F','G','H','I','L','M','N','O','P','Q','R','S','T','U','V','Z'];
    const UK_LETTERS = Array.from({length: 26}, (_, i) => String.fromCharCode(65 + i));

    const params = new URLSearchParams(window.location.search);
    let catalog = null;
    let state = {
      folder: ['vanilla', 'ajcarlesso', 'all'].includes(params.get('folder')) ? params.get('folder') : 'vanilla',
      lang: ['uk', 'it'].includes(params.get('lang')) ? params.get('lang') : 'uk',
      layout: ['landscape', 'portrait', 'square'].includes(params.get('layout')) ? params.get('layout') : 'landscape',
      cols: 4,
      seed: Date.now()
    };

    function syncActiveButtons() {
      document.querySelectorAll('#folderGroup button').forEach(b => b.classList.toggle('active', b.dataset.folder === state.folder));
      document.querySelectorAll('#langGroup button').forEach(b => b.classList.toggle('active', b.dataset.lang === state.lang));
      document.querySelectorAll('#layoutGroup button').forEach(b => b.classList.toggle('active', b.dataset.layout === state.layout));
    }
    syncActiveButtons();

    function highlightInitial(word, letter) {
      if (!word) return '';
      return `<span class="initial-highlight">${word[0]}</span>${word.slice(1)}`;
    }

    function speakWords(wordIt, wordEn, event) {
      if (event) event.stopPropagation();
      if (!('speechSynthesis' in window)) return;
      window.speechSynthesis.cancel();
      const u1 = new SpeechSynthesisUtterance(wordIt);
      u1.lang = 'it-IT';
      window.speechSynthesis.speak(u1);
      if (wordEn && wordEn.toLowerCase() !== wordIt.toLowerCase()) {
        const u2 = new SpeechSynthesisUtterance(wordEn);
        u2.lang = 'en-GB';
        window.speechSynthesis.speak(u2);
      }
    }

    function getActiveItems() {
      if (!catalog) return [];
      if (state.folder === 'all') {
        return [
          ...(catalog.folders['vanilla']?.items || []),
          ...(catalog.folders['ajcarlesso']?.items || []),
          ...(catalog.folders['ajcarlesso-loads']?.items || [])
        ];
      }
      return catalog.folders[state.folder]?.items || [];
    }

    function getFallbackUrl() {
      const f = state.folder === 'all' ? 'vanilla' : state.folder;
      if (state.layout === 'portrait') return `images/${f}/_portrait.jpg`;
      if (state.layout === 'landscape') return `images/${f}/_landscape.jpg`;
      return `images/${f}/_empty.jpg`;
    }

    function pickPhotoForLetter(itemsForLetter) {
      if (!itemsForLetter.length) return null;
      // Filter by preferred orientation if available, otherwise fallback to any photo for that letter
      let preferred = itemsForLetter;
      if (state.layout === 'portrait') {
        const port = itemsForLetter.filter(i => i.verticality === 'portrait' || i.verticality === 'very_tall');
        if (port.length) preferred = port;
      } else if (state.layout === 'landscape') {
        const land = itemsForLetter.filter(i => i.verticality === 'landscape' || i.verticality === 'very_wide');
        if (land.length) preferred = land;
      }
      const idx = Math.floor(Math.random() * preferred.length);
      return preferred[idx];
    }

    function createCardHTML(letter, item, totalForLetter, showFilename = false) {
      const imgUrl = item ? item.url : getFallbackUrl();
      const wordIt = item ? item.word_it : letter;
      const wordEn = item ? item.word_en : letter;
      const sameWord = wordIt.toLowerCase() === wordEn.toLowerCase();

      const wordsMarkup = sameWord
        ? `<span class="word-item">🇮🇹 🇬🇧 ${highlightInitial(wordIt, letter)}</span>`
        : `<span class="word-item">🇮🇹 ${highlightInitial(wordIt, letter)}</span>
           <span class="word-item">🇬🇧 ${highlightInitial(wordEn, letter)}</span>`;

      const countBadge = totalForLetter > 1 && !showFilename
        ? `<span class="photo-count-pill" title="${totalForLetter} photos available for ${letter}">📸 ${totalForLetter}</span>`
        : '';

      return `
        <div class="letter-card" data-letter="${letter}" onclick="openLetterModal('${letter}')">
          ${countBadge}
          <div class="letter-watermark">${letter}<span class="lowercase-sub">${letter.toLowerCase()}</span></div>
          <img src="${imgUrl}" alt="Letter ${letter}: ${wordIt}" loading="lazy" />
          <div class="card-caption">
            <div class="words-wrap">${wordsMarkup}</div>
            <button class="speak-btn" title="Pronounce ${wordIt}" onclick="speakWords('${wordIt.replace(/'/g, "\\'")}', '${wordEn.replace(/'/g, "\\'")}', event)">🔊</button>
          </div>
        </div>
      `;
    }

    function render() {
      const letters = state.lang === 'it' ? ITALIAN_LETTERS : UK_LETTERS;
      const allItems = getActiveItems();
      const byLetter = {};
      letters.forEach(l => byLetter[l] = []);
      allItems.forEach(item => {
        if (byLetter[item.letter]) byLetter[item.letter].push(item);
      });

      const grid = document.getElementById('alphabetGrid');
      if (state.layout === 'portrait') {
        grid.style.setProperty('--cols', 6);
        grid.style.setProperty('--card-aspect', '3 / 4');
      } else if (state.layout === 'square') {
        grid.style.setProperty('--cols', 5);
        grid.style.setProperty('--card-aspect', '1 / 1');
      } else {
        grid.style.setProperty('--cols', 4);
        grid.style.setProperty('--card-aspect', '4 / 3');
      }

      // Render letter strip
      const strip = document.getElementById('letterStrip');
      strip.innerHTML = letters.map(l => {
        const count = byLetter[l].length;
        return `<button class="letter-pill ${count === 0 ? 'empty-letter' : ''}" onclick="openLetterModal('${l}')" title="${l}: ${count} photos">${l}</button>`;
      }).join('');

      // Render main cards
      grid.innerHTML = letters.map(l => {
        const list = byLetter[l];
        const chosen = pickPhotoForLetter(list);
        return createCardHTML(l, chosen, list.length, false);
      }).join('');
    }

    window.openLetterModal = function(letter) {
      const allItems = getActiveItems().filter(i => i.letter === letter);
      const modal = document.getElementById('letterModal');
      const title = document.getElementById('modalTitle');
      const grid = document.getElementById('modalGrid');

      title.innerHTML = `🔤 Letter "${letter}" <span style="font-size:1rem;color:#64748b;font-weight:500;">(${allItems.length} picture${allItems.length === 1 ? '' : 's'})</span>`;
      if (allItems.length === 0) {
        grid.innerHTML = `<p style="color:#64748b;grid-column:1/-1;">No pictures starting with <strong>${letter}</strong> in this folder yet. Try switching to <strong>AJ Family</strong> or <strong>All Pics</strong> above!</p>`;
      } else {
        grid.innerHTML = allItems.map(item => createCardHTML(letter, item, 1, true)).join('');
      }
      modal.classList.add('open');
    };

    document.getElementById('closeModalBtn').addEventListener('click', () => {
      document.getElementById('letterModal').classList.remove('open');
    });
    document.getElementById('letterModal').addEventListener('click', (e) => {
      if (e.target.id === 'letterModal') e.currentTarget.classList.remove('open');
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') document.getElementById('letterModal').classList.remove('open');
    });

    // Bind button groups
    document.querySelectorAll('#folderGroup button').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#folderGroup button').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.folder = btn.dataset.folder;
        render();
      });
    });

    document.querySelectorAll('#langGroup button').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#langGroup button').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.lang = btn.dataset.lang;
        render();
      });
    });

    document.querySelectorAll('#layoutGroup button').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#layoutGroup button').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.layout = btn.dataset.layout;
        render();
      });
    });

    document.getElementById('shuffleBtn').addEventListener('click', () => render());
    document.getElementById('printBtn').addEventListener('click', () => {
      window.print();
    });

    fetch('data.json')
      .then(r => r.json())
      .then(data => {
        catalog = data;
        render();
      });
  </script>
</body>
</html>
HTML

File.write(File.join(OUT_DIR, 'index.html'), index_html)
puts "✨ Static site generated at #{OUT_DIR}/index.html"
