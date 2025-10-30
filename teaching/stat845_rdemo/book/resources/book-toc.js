<script>
/* book-toc.js — use Quarto book sidebar TOC as an overlay drawer (up to h3) */

(() => {
  const CFG = {
    maxDepth: 3,               // chapter (lvl-1), h2 (lvl-2), h3 (lvl-3)
    toggleHotkey: 'KeyT',      // Cmd/Ctrl+Shift+T
  };

  const $ = (s, el=document) => el.querySelector(s);
  const $$ = (s, el=document) => [...el.querySelectorAll(s)];
  const on = (el, ev, fn, opts) => el && el.addEventListener(ev, fn, opts);

  // Shell
  function ensureShell() {
    // Toggle button
    let toggle = $('#book-toc-toggle');
    if (!toggle) {
      toggle = document.createElement('button');
      toggle.id = 'book-toc-toggle';
      toggle.type = 'button';
      toggle.setAttribute('aria-expanded','false');
      toggle.setAttribute('aria-controls','book-toc-panel');
      toggle.title = 'Open Table of Contents';
      toggle.textContent = '☰ TOC';
      document.body.appendChild(toggle);
    }

    // Backdrop
    let backdrop = $('#book-toc-backdrop');
    if (!backdrop) {
      backdrop = document.createElement('div');
      backdrop.id = 'book-toc-backdrop';
      backdrop.setAttribute('aria-hidden','true');
      document.body.appendChild(backdrop);
    }

    // Panel
    let panel = $('#book-toc-panel');
    if (!panel) {
      panel = document.createElement('aside');
      panel.id = 'book-toc-panel';
      panel.setAttribute('role','dialog');
      panel.setAttribute('aria-modal','true');
      panel.setAttribute('aria-label','Table of Contents');

      const head = document.createElement('div');
      head.id = 'book-toc-head';
      const h = document.createElement('h3'); h.textContent = 'Table of Contents';
      const close = document.createElement('button'); close.className='toc-icon-btn'; close.id='book-toc-close'; close.textContent='✕'; close.title='Close TOC';
      head.append(h, close);

      const content = document.createElement('div');
      content.id = 'book-toc-content';
      content.innerHTML = '<p><em>Loading…</em></p>';

      panel.append(head, content);
      document.body.appendChild(panel);
    }

    return { toggle: $('#book-toc-toggle'), backdrop: $('#book-toc-backdrop'), panel: $('#book-toc-panel') };
  }

  function openTOC(toggleBtn){ document.body.classList.add('book-toc-open'); toggleBtn?.setAttribute('aria-expanded','true'); }
  function closeTOC(toggleBtn){ document.body.classList.remove('book-toc-open'); toggleBtn?.setAttribute('aria-expanded','false'); }

  function prepareLinksCloseOnClick(scopeEl, toggleBtn) {
    $$('#book-toc-content a', scopeEl).forEach(a => {
      on(a, 'click', () => setTimeout(() => closeTOC(toggleBtn), 0));
    });
  }

  // Build nested (h2→h3) under each chapter if the cloned nav already provides that; if not, fallback to search.json
  function cloneBookSidebar() {
    // Quarto book sidebar: usually nav.sidebar-navigation or #quarto-sidebar > nav
    const candidates = [
      'nav.sidebar-navigation',
      '#quarto-sidebar nav',
      '.quarto-sidebar-tools + nav.sidebar-navigation'
    ];
    for (const sel of candidates) {
      const nav = document.querySelector(sel);
      if (nav) return nav.cloneNode(true);
    }
    return null;
  }

  // Optional enhancement: collapse h3 under each h2 in the cloned list
  function collapseH3(container) {
    // Find <li> that contain a nested <ul> (treat as h2 container) and make them collapsible
    $$('#book-toc-content li', container).forEach(li => {
      const sub = $('ul', li);
      if (!sub) return;
      // Wrap the first link row to add a caret
      const firstLink = $(':scope > a, :scope > div > a', li);
      if (!firstLink) return;

      let row = $(':scope > .toc-row', li);
      if (!row) {
        row = document.createElement('div'); row.className = 'toc-row';
        const caret = document.createElement('span'); caret.className = 'toc-caret'; caret.title = 'Toggle subsections';
        li.insertBefore(row, firstLink);
        row.append(caret, firstLink);
      }
      li.classList.add('toc-collapsed'); // start collapsed
      const caretBtn = $('.toc-caret', li);
      on(caretBtn, 'click', () => li.classList.toggle('toc-collapsed'));
    });
  }

  async function buildTOC() {
    const { toggle, backdrop, panel } = ensureShell();
    const closeBtn = $('#book-toc-close', panel);
    const content = $('#book-toc-content', panel);

    // Open/close
    on(toggle, 'click', () => openTOC(toggle));
    on(closeBtn, 'click', () => closeTOC(toggle));
    on(backdrop, 'click', () => closeTOC(toggle));
    on(document, 'keydown', (e) => {
      if (e.key === 'Escape') closeTOC(toggle);
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.code === CFG.toggleHotkey) {
        e.preventDefault();
        document.body.classList.contains('book-toc-open') ? closeTOC(toggle) : openTOC(toggle);
      }
    });

    // 1) Try to clone the book sidebar (preferred: preserves chapter order and links)
    const cloned = cloneBookSidebar();
    if (cloned) {
      content.innerHTML = '';
      content.appendChild(cloned);
      collapseH3(content);
      prepareLinksCloseOnClick(panel, toggle);
      return;
    }

    // 2) Fallback: build from page headings (current page only)
    // (optional; you can also import from search.json like earlier if you want full-book)
    const built = document.createElement('div');
    built.className = 'book-toc';
    const ul = document.createElement('ul');
    built.appendChild(ul);

    const heads = [...document.querySelectorAll('main :is(h2,h3)')];
    let h2Li = null;
    heads.forEach(h => {
      const lvl = Number(h.tagName.slice(1));
      if (!h.id) h.id = (h.textContent || 'section').trim().toLowerCase().replace(/\s+/g,'-');
      const a = document.createElement('a'); a.href = '#'+h.id; a.textContent = h.textContent.trim();

      if (lvl === 2) {
        const li = document.createElement('li'); li.className='lvl-2 toc-collapsed';
        const row = document.createElement('div'); row.className='toc-row';
        const caret = document.createElement('span'); caret.className='toc-caret'; caret.title='Toggle subsections';
        row.append(caret, a); li.appendChild(row); li.appendChild(document.createElement('ul'));
        ul.appendChild(li); h2Li = li;
        on(caret, 'click', () => li.classList.toggle('toc-collapsed'));
      } else if (lvl === 3) {
        if (!h2Li) return;
        const li3 = document.createElement('li'); li3.className='lvl-3';
        li3.appendChild(a); $('ul', h2Li).appendChild(li3);
      }
    });

    content.innerHTML = '';
    content.appendChild(built);
    prepareLinksCloseOnClick(panel, toggle);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', buildTOC);
  } else {
    buildTOC();
  }
})();
</script>