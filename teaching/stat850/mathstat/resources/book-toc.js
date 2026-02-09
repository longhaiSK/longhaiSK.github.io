/* assets/book-toc.js — Overlay Book TOC for Quarto
   - Clones chapter nav from #quarto-sidebar (no in-page TOC)
   - Fallback to search.json (chapters + h2/h3)
   - Hides original sidebar only after overlay is ready (body.book-toc-ready)
   - Toggle: Cmd/Ctrl+Shift+T, closes on link click/ESC
*/

(() => {
  const CFG = {
    maxDepth: 3,          // 1=chapter, 2=h2, 3=h3 (for fallback)
    toggleHotkey: 'KeyT', // Cmd/Ctrl+Shift+T
    waitSidebarMs: 2000,  // wait up to 2s for Quarto to mount sidebar
  };

  const $  = (s, el=document) => el.querySelector(s);
  const $$ = (s, el=document) => [...el.querySelectorAll(s)];
  const on = (el, ev, fn, opts) => el && el.addEventListener(ev, fn, opts);

  /* ---------- UI shell ---------- */
  function ensureShell(){
    console.info('[book-toc] ensureShell');
    let toggle = $('#book-toc-toggle');
    if (!toggle){
      toggle = document.createElement('button');
      toggle.id = 'book-toc-toggle';
      toggle.type = 'button';
      toggle.setAttribute('aria-expanded','false');
      toggle.setAttribute('aria-controls','book-toc-panel');
      toggle.title = 'Open Table of Contents';
      toggle.textContent = '☰ TOC';
      document.body.appendChild(toggle);
    }

    let backdrop = $('#book-toc-backdrop');
    if (!backdrop){
      backdrop = document.createElement('div');
      backdrop.id = 'book-toc-backdrop';
      backdrop.setAttribute('aria-hidden','true');
      document.body.appendChild(backdrop);
    }

    let panel = $('#book-toc-panel');
    if (!panel){
      panel = document.createElement('aside');
      panel.id = 'book-toc-panel';
      panel.setAttribute('role','dialog');
      panel.setAttribute('aria-modal','true');
      panel.setAttribute('aria-label','Table of Contents');

      const head = document.createElement('div');
      head.id = 'book-toc-head';
      const h = document.createElement('h3'); h.textContent = 'Table of Contents';
      const close = document.createElement('button'); close.className = 'toc-icon-btn';
      close.id = 'book-toc-close'; close.textContent = '✕'; close.title = 'Close TOC';
      head.append(h, close);

      const content = document.createElement('div');
      content.id = 'book-toc-content';
      content.innerHTML = '<p><em>Loading…</em></p>';

      panel.append(head, content);
      document.body.appendChild(panel);
    }

    return {
      toggle: $('#book-toc-toggle'),
      backdrop: $('#book-toc-backdrop'),
      panel: $('#book-toc-panel')
    };
  }

  function openTOC(btn){ document.body.classList.add('book-toc-open'); btn?.setAttribute('aria-expanded','true'); }
  function closeTOC(btn){ document.body.classList.remove('book-toc-open'); btn?.setAttribute('aria-expanded','false'); }
  function markReady(){ document.body.classList.add('book-toc-ready'); } // CSS hides sidebar only after this

  function prepareLinksCloseOnClick(scopeEl, toggleBtn){
    $$('#book-toc-content a', scopeEl).forEach(a => {
      on(a, 'click', () => setTimeout(() => closeTOC(toggleBtn), 0));
    });
  }

  /* ---------- Clone chapter nav only (strip in-page TOC) ---------- */
  function cloneBookSidebarNow(){
    // Prefer the pure chapter nav
    let nav = document.querySelector('#quarto-sidebar nav.sidebar-navigation');
    if (!nav){
      // Fallback: any nav under the sidebar that is NOT an in-page TOC
      const cands = [...document.querySelectorAll('#quarto-sidebar nav')];
      nav = cands.find(n =>
        !n.matches('[role="doc-toc"]') &&
        !n.querySelector('#TOC') &&
        !n.classList.contains('sidebar-toc') &&
        !n.classList.contains('on-this-page')
      );
    }
    if (!nav) return null;

    const clone = nav.cloneNode(true);
    // Remove any “On this page” remnants, just in case
    clone.querySelectorAll('.toc-active, [role="doc-toc"], #TOC, .sidebar-toc, .on-this-page')
         .forEach(el => el.remove());
    return clone;
  }

  function waitForSidebar(timeoutMs){
    return new Promise((resolve) => {
      const existing = cloneBookSidebarNow();
      if (existing) return resolve(existing);

      const obs = new MutationObserver(() => {
        const found = cloneBookSidebarNow();
        if (found){
          obs.disconnect();
          resolve(found);
        }
      });
      obs.observe(document.documentElement, { childList: true, subtree: true });

      setTimeout(() => { obs.disconnect(); resolve(null); }, timeoutMs);
    });
  }

  /* ---------- Make nested lists collapsible ---------- */
  function makeCollapsible(container){
    $$('#book-toc-content li', container).forEach(li => {
      const sub = $(':scope > ul', li);
      const firstLink = $(':scope > a, :scope > div > a', li);
      if (!sub || !firstLink) return;

      let row = $(':scope > .toc-row', li);
      if (!row){
        row = document.createElement('div');
        row.className = 'toc-row';
        const caret = document.createElement('span');
        caret.className = 'toc-caret'; caret.title = 'Toggle subsections';
        li.insertBefore(row, firstLink);
        row.append(caret, firstLink);
      }
      li.classList.add('toc-collapsed'); // start collapsed
      const caretBtn = $('.toc-caret', li);
      on(caretBtn, 'click', () => li.classList.toggle('toc-collapsed'));
    });
  }

  /* ---------- Fallback: build full-book TOC from search.json ---------- */
  async function buildFromSearchJSON(){
    const content = document.createElement('div');
    content.className = 'book-toc';

    const makeList = () => document.createElement('ul');
    const makeItem = (title, href, level) => {
      const li = document.createElement('li'); li.className = `lvl-${level}`;
      const a = document.createElement('a'); a.textContent = title || '(Untitled)'; a.href = href;
      li.appendChild(a); return li;
    };
    const safeURL = (href) => { try { return new URL(href, document.baseURI); } catch { return null; } };

    async function loadSearch(){
      const url = new URL('search.json', document.baseURI);
      const r = await fetch(url.href);
      if (!r.ok) throw new Error('search.json not found');
      return r.json();
    }
    const entriesArray = (data) => Array.isArray(data) ? data : (data.docs || data.items || []);

    function buildIndex(entries){
      const byFile = new Map();
      for (const e of entries){
        if (!e || !e.href) continue;
        const u = safeURL(e.href); if (!u) continue;
        if (!/\.html?$/i.test(u.pathname)) continue;
        const file = u.pathname.replace(/^\//,'');
        const hash = u.hash || '';
        const level = (typeof e.headingLevel === 'number') ? e.headingLevel :
                      (typeof e.sectionLevel === 'number') ? e.sectionLevel : null;
        if (!byFile.has(file)) byFile.set(file, { title:null, href:file, headings:[] });
        const rec = byFile.get(file);
        if (!hash && !rec.title) rec.title = e.title || e.text || file;
        if (level !== null) rec.headings.push({ id: hash, title: e.title || e.text || '', level });
      }
      return byFile;
    }

    function orderBySidebar(files){
      const links = Array.from(document.querySelectorAll('nav.sidebar-navigation a[href]'));
      const order = links.map(a => {
        const u = safeURL(a.getAttribute('href'));
        return u ? u.pathname.replace(/^\//,'') : null;
      }).filter(Boolean);
      const pos = new Map(order.map((p,i)=>[p,i]));
      return files.sort((a,b) => {
        const pa = pos.has(a) ? pos.get(a) : Infinity;
        const pb = pos.has(b) ? pos.get(b) : Infinity;
        return (pa!==pb) ? pa - pb : a.localeCompare(b);
      });
    }

    function nestH2H3(rec){
      const hs = rec.headings.filter(h => h.level >= 2 && h.level <= CFG.maxDepth);
      const nested = []; let curH2 = null;
      for (const h of hs){
        if (h.level === 2){ curH2 = { ...h, children: [] }; nested.push(curH2); }
        else if (h.level === 3){
          if (!curH2){ curH2 = { title: '(Untitled section)', id:'', level:2, children:[] }; nested.push(curH2); }
          curH2.children.push(h);
        }
      }
      return nested;
    }

    const data = await loadSearch();
    const entries = entriesArray(data);
    if (!entries.length) return null;

    const byFile = buildIndex(entries);
    let files = Array.from(byFile.keys());
    files = orderBySidebar(files);

    const rootUL = makeList();
    for (const file of files){
      const rec = byFile.get(file);
      if (!rec?.title || /search\.html?$/i.test(rec.href)) continue;
      const li1 = makeItem(rec.title, rec.href, 1);

      const h2h3 = nestH2H3(rec);
      if (h2h3.length){
        const ul2 = makeList();
        for (const h2 of h2h3){
          const href2 = h2.id ? `${rec.href}${h2.id}` : rec.href;
          const li2 = makeItem(h2.title || 'Section', href2, 2);
          if (h2.children?.length){
            const ul3 = makeList();
            for (const h3 of h2.children){
              const href3 = h3.id ? `${rec.href}${h3.id}` : rec.href;
              ul3.appendChild(makeItem(h3.title || 'Subsection', href3, 3));
            }
            li2.appendChild(ul3);
          }
          ul2.appendChild(li2);
        }
        li1.appendChild(ul2);
      }
      rootUL.appendChild(li1);
    }

    content.appendChild(rootUL);
    return content;
  }

  /* ---------- Build flow ---------- */
  async function buildTOC(){
    console.info('[book-toc] buildTOC start');
    const { toggle, backdrop, panel } = ensureShell();
    // Ensure toggle is visible immediately (CSS sets huge z-index)
    if (toggle) toggle.style.visibility = 'visible';

    const closeBtn = $('#book-toc-close', panel);
    const content = $('#book-toc-content', panel);

    // Open/close wiring
    on(toggle, 'click', () => openTOC(toggle));
    on(closeBtn, 'click', () => closeTOC(toggle));
    on(backdrop, 'click', () => closeTOC(toggle));
    on(document, 'keydown', (e) => {
      if (e.key === 'Escape') closeTOC(toggle);
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.code === CFG.toggleHotkey){
        e.preventDefault();
        document.body.classList.contains('book-toc-open') ? closeTOC(toggle) : openTOC(toggle);
      }
    });

    // 1) Try to clone the book's chapter nav (preferred)
    let cloned = await waitForSidebar(CFG.waitSidebarMs);

    if (cloned){
      console.info('[book-toc] cloned book chapter nav');
      content.innerHTML = '';
      content.appendChild(cloned);
      // Ensure any "On this page" remnants are removed
      content.querySelectorAll('.toc-active, [role="doc-toc"], #TOC, .sidebar-toc, .on-this-page')
             .forEach(el => el.remove());
      makeCollapsible(content);
      prepareLinksCloseOnClick(panel, toggle);
      markReady(); // hide original sidebar via CSS now
      return;
    }

    // 2) Fallback: build from search.json (chapters + h2 + h3)
    try{
      console.info('[book-toc] using search.json fallback');
      const built = await buildFromSearchJSON();
      if (built){
        content.innerHTML = '';
        content.appendChild(built);
        prepareLinksCloseOnClick(panel, toggle);
        markReady();
        return;
      }
    }catch(err){
      console.warn('book-toc: search.json fallback failed:', err);
    }

    // 3) Give up gracefully (leave original sidebar visible)
    console.warn('[book-toc] could not build overlay TOC; leaving default sidebar');
    content.innerHTML = '<p><em>Could not build the book TOC (no sidebar and no search.json). The default sidebar remains visible.</em></p>';
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', buildTOC);
  else buildTOC();
})();
