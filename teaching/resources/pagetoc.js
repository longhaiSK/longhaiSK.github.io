<script>
/* loadtoc.js — overlay TOC drawer (no layout shift, up to h3)
   - Creates a fixed-position overlay panel + backdrop
   - Clones existing Quarto TOC if found; else builds from <main> h2/h3
   - Collapses h3 under h2 initially; click to toggle
   - Closes on link click, backdrop click, or ESC
   - Prevents body scroll when open; does NOT push page content
*/

(() => {
  // ===== Config =====
  const CFG = {
    side: 'right',            // 'right' | 'left'
    fontSize: '14px',
    width: 400,               // px
    maxWidthVw: 92,           // %
    headerOffset: 80,         // px: scroll margin for headings
    zBase: 2000,              // base z-index for overlay/backdrop
    buildFromHeadingsIfMissingSidebar: true, // fallback builder
    headingSelector: 'main :is(h2,h3)',      // used if building fallback
    maxDepth: 3,              // up to h3
    toggleHotkey: 'KeyT',     // Cmd/Ctrl+Shift+T toggles
  };

  // ===== Utilities =====
  const $ = (sel, el=document) => el.querySelector(sel);
  const $$ = (sel, el=document) => [...el.querySelectorAll(sel)];
  const on = (el, ev, fn, opts) => el && el.addEventListener(ev, fn, opts);

  const slugify = (txt) =>
    txt.toLowerCase()
       .trim()
       .replace(/[\s\.\,\/:\;\?\!\(\)\[\]\{\}"'`]+/g, '-')
       .replace(/-+/g, '-')
       .replace(/^-|-$/g, '');

  function ensureId(el) {
    if (!el.id) el.id = slugify(el.textContent || 'section');
    return el.id;
  }

  function injectStyles() {
    const style = document.createElement('style');
    style.setAttribute('data-toc-style', 'overlay');
    style.textContent = `
      :root { 
        --toc-width:${CFG.width}px; 
        --toc-offset:${CFG.headerOffset}px; 
        --toc-z:${CFG.zBase}; 
        --toc-font-size:${CFG.fontSize};
      }
      main :is(h1,h2,h3,h4,h5,h6){ scroll-margin-top: var(--toc-offset); }

      #toc-toggle-btn {
        position: fixed; top: 50px; ${CFG.side}: 10px;
        z-index: calc(var(--toc-z) + 2);
        padding: 0.1rem 0.6rem; border: 1px solid #ddd; border-radius: 999px;
        background: #fff; cursor: pointer; box-shadow: 0 8px 24px rgba(0,0,0,.10);
        font: 1000 32px system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
      }

      #toc-backdrop {
        position: fixed; inset: 0; background: rgba(0,0,0,.25);
        opacity: 0; pointer-events: none; transition: opacity .2s ease;
        z-index: var(--toc-z);
      }
      body.toc-open #toc-backdrop { opacity: 1; pointer-events: auto; }

      #toc-panel {
        position: fixed; top: 0; ${CFG.side}: 0; height: 100vh;
        width: var(--toc-width); max-width: ${CFG.maxWidthVw}vw;
        background: #fff; box-shadow: ${CFG.side==='right' ? '-16px' : '16px'} 0 32px rgba(0,0,0,.08);
        transform: translateX(${CFG.side==='right' ? '100%' : '-100%'});
        transition: transform .22s ease;
        z-index: calc(var(--toc-z) + 1);
        display: flex; flex-direction: column;
      }
      body.toc-open #toc-panel { transform: translateX(0); }
      body.toc-open { overflow: hidden; }

      #toc-head {
        display:flex; align-items:center; justify-content:space-between;
        gap:0.5rem; padding:.75rem .9rem; border-bottom:1px solid #eee;
      }
      #toc-head h3{ margin:0; font:600 16px system-ui,-apple-system,Segoe UI,Roboto,sans-serif; }

      #toc-content { 
        overflow:auto; 
        padding:.6rem .85rem 1rem; 
        font-size: var(--toc-font-size);  
      }
      #toc-content nav, #toc-content .book-toc { line-height:1.5; }
      #toc-content ul { list-style:none; margin:.25rem 0; padding-left:1rem; }
      #toc-content li { margin:.1rem 0; }
      #toc-content a { text-decoration:none; }
      #toc-content .lvl-1 > a { font-weight:600; }
      #toc-content .lvl-2 > a { font-weight:500; }
      #toc-content .lvl-3 > a { font-weight:400; }

      .toc-icon-btn{
        border:1px solid #ddd; border-radius:8px; padding:.35rem .55rem; background:#fff; cursor:pointer;
      }

      /* collapsible h3 under h2 */
      .toc-caret { margin-right:.35rem; user-select:none; cursor:pointer; }
      .toc-collapsed > ul { display:none; }
      .toc-caret::before { content: '▾'; display:inline-block; transform: rotate(0deg); transition: transform .12s linear; }
      .toc-collapsed > .toc-row .toc-caret::before { transform: rotate(-90deg); }
      .toc-row { display:flex; align-items:center; gap:.25rem; }
    `;
    document.head.appendChild(style);
  }

  // Create skeleton (toggle button, backdrop, panel)
  function createShell() {
    // Toggle button (if user already has one with #toc-toggle-btn, reuse)
    let toggle = document.getElementById('toc-toggle-btn');
    if (!toggle) {
      toggle = document.createElement('button');
      toggle.id = 'toc-toggle-btn';
      toggle.type = 'button';
      toggle.setAttribute('aria-expanded','false');
      toggle.setAttribute('aria-controls','toc-panel');
      toggle.title = 'Open Table of Contents';
      toggle.textContent = '☰';
      document.body.appendChild(toggle);
    }

    // Backdrop
    let backdrop = document.getElementById('toc-backdrop');
    if (!backdrop) {
      backdrop = document.createElement('div');
      backdrop.id = 'toc-backdrop';
      backdrop.setAttribute('aria-hidden','true');
      document.body.appendChild(backdrop);
    }

    // Panel
    let panel = document.getElementById('toc-panel');
    if (!panel) {
      panel = document.createElement('aside');
      panel.id = 'toc-panel';
      panel.setAttribute('role','dialog');
      panel.setAttribute('aria-modal','true');
      panel.setAttribute('aria-label','Table of Contents');

      const head = document.createElement('div');
      head.id = 'toc-head';
      const h = document.createElement('h3'); h.textContent = 'Table of Contents';
      const close = document.createElement('button'); close.className='toc-icon-btn'; close.id='toc-close'; close.textContent='✕'; close.title='Close TOC';
      head.append(h, close);

      const content = document.createElement('div');
      content.id = 'toc-content';
      content.innerHTML = '<p><em>Loading…</em></p>';

      panel.append(head, content);
      document.body.appendChild(panel);
    }

    return { toggle, backdrop, panel };
  }

  function openTOC(toggleBtn) {
    document.body.classList.add('toc-open');
    toggleBtn?.setAttribute('aria-expanded','true');
  }
  function closeTOC(toggleBtn) {
    document.body.classList.remove('toc-open');
    toggleBtn?.setAttribute('aria-expanded','false');
  }

  // Build TOC DOM: either clone Quarto sidebar TOC or build from headings
  function findExistingTOC() {
    // Try common Quarto TOC containers
    return (
      $('nav[role="navigation"].toc-active') ||
      $('#TOC') ||
      $('nav.sidebar-navigation .toc-active') ||
      null
    );
  }

  function buildFromHeadings() {
    const container = document.createElement('div');
    container.className = 'book-toc';
    const ul1 = document.createElement('ul');

    const heads = $$(CFG.headingSelector).filter(h => {
      const level = Number(h.tagName.slice(1));
      return level >= 2 && level <= CFG.maxDepth;
    });

    let currentH2LI = null;
    heads.forEach(h => {
      const level = Number(h.tagName.slice(1));
      const id = '#' + ensureId(h);
      const a = document.createElement('a');
      a.href = id;
      a.textContent = h.textContent.trim() || (level === 2 ? 'Section' : 'Subsection');

      if (level === 2) {
        const li = document.createElement('li'); li.className = 'lvl-2';
        const row = document.createElement('div'); row.className = 'toc-row';
        const caret = document.createElement('span'); caret.className = 'toc-caret'; caret.title = 'Toggle subsections';
        row.append(caret, a);
        li.appendChild(row);

        const ul2 = document.createElement('ul'); // for h3 children
        li.appendChild(ul2);
        li.classList.add('toc-collapsed'); // start collapsed
        ul1.appendChild(li);
        currentH2LI = li;

        on(caret, 'click', () => li.classList.toggle('toc-collapsed'));
      } else if (level === 3) {
        if (!currentH2LI) {
          // Create a dummy h2 wrapper if needed
          const dummy = document.createElement('li'); dummy.className = 'lvl-2 toc-collapsed';
          const row = document.createElement('div'); row.className = 'toc-row';
          const caret = document.createElement('span'); caret.className = 'toc-caret'; caret.title = 'Toggle subsections';
          const label = document.createElement('a'); label.href = '#'; label.textContent = '(Untitled section)';
          row.append(caret, label);
          dummy.appendChild(row);
          const ul2 = document.createElement('ul'); dummy.appendChild(ul2);
          ul1.appendChild(dummy);
          currentH2LI = dummy;
          on(caret, 'click', () => dummy.classList.toggle('toc-collapsed'));
        }
        const ul2 = currentH2LI.querySelector('ul') || (() => { const u=document.createElement('ul'); currentH2LI.appendChild(u); return u; })();
        const li3 = document.createElement('li'); li3.className = 'lvl-3';
        li3.appendChild(a);
        ul2.appendChild(li3);
      }
    });

    // Wrap under a fake lvl-1 “This page”
    const li1 = document.createElement('li'); li1.className = 'lvl-1';
    const aTop = document.createElement('a'); aTop.href = '#'; aTop.textContent = document.title || 'This page';
    li1.appendChild(aTop);
    li1.appendChild(ul1);

    const rootUL = document.createElement('ul'); rootUL.appendChild(li1);
    container.appendChild(rootUL);
    return container;
  }

  function prepareLinksCloseOnClick(scopeEl, toggleBtn) {
    $$('#toc-content a', scopeEl).forEach(a => {
      on(a, 'click', () => {
        // let the browser jump first, then close to avoid covering target
        setTimeout(() => closeTOC(toggleBtn), 0);
      });
    });
  }

  // ===== Init =====
  function init() {
    injectStyles();
    const { toggle, backdrop, panel } = createShell();

    const closeBtn = $('#toc-close', panel);
    const content = $('#toc-content', panel);

    // Open/close wiring
    on(toggle, 'click', () => openTOC(toggle));
    on(closeBtn, 'click', () => closeTOC(toggle));
    on(backdrop, 'click', () => closeTOC(toggle));
    on(document, 'keydown', (e) => {
      if (e.key === 'Escape') closeTOC(toggle);
      // Cmd/Ctrl+Shift+T hotkey
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.code === CFG.toggleHotkey) {
        e.preventDefault();
        document.body.classList.contains('toc-open') ? closeTOC(toggle) : openTOC(toggle);
      }
    });

    // Fill content
    const existing = findExistingTOC();
    if (existing) {
      const cloned = existing.cloneNode(true);
      // If the cloned nav already has nested lists, just drop it in
      content.innerHTML = '';
      content.appendChild(cloned);
      // Optional: start with h3 collapsed if structure resembles h2>ul>li>ul
      // (Skip auto-collapse for cloned Quarto TOC to avoid fighting its JS)
      prepareLinksCloseOnClick(panel, toggle);
    } else if (CFG.buildFromHeadingsIfMissingSidebar) {
      const built = buildFromHeadings();
      content.innerHTML = '';
      content.appendChild(built);
      prepareLinksCloseOnClick(panel, toggle);
    } else {
      content.innerHTML = '<p><em>No TOC found on this page.</em></p>';
    }
  }

  // Run after DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

</script>