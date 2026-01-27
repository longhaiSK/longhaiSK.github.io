/* loadtoc-fixed-nav-expanded.js
   - Sidebar TOC respecting Top Nav
   - Defaults to EXPANDED (shows H2 and H3 immediately)
   - Supports <main> tag or .main class
   - Grey/Blue gradient background
*/

(() => {
  // ===== Config =====
  const CFG = {
    width: 300,             
    navbarHeight: 60,       
    breakpoint: 1100,       
    headerOffset: 80,       
    zBase: 950,             
    buildFromHeadingsIfMissingSidebar: true,
    // Updated selector to support <div class="main">
    headingSelector: ':is(main, .main) :is(h2,h3)', 
    maxDepth: 3,
    startCollapsed: false 
  };

  // ===== Utilities =====
  const $ = (sel, el=document) => el.querySelector(sel);
  const $$ = (sel, el=document) => [...el.querySelectorAll(sel)];

  const slugify = (txt) =>
    txt.toLowerCase().trim()
       .replace(/[\s\.\,\/:\;\?\!\(\)\[\]\{\}"'`]+/g, '-')
       .replace(/-+/g, '-')
       .replace(/^-|-$/g, '');

  function ensureId(el) {
    if (!el.id) el.id = slugify(el.textContent || 'section');
    return el.id;
  }

  function injectStyles() {
    const style = document.createElement('style');
    style.setAttribute('data-toc-style', 'permanent-sidebar');
    // CHANGED: Updated --toc-bg to a gradient below
    style.textContent = `
      :root { 
        --toc-width: ${CFG.width}px; 
        --toc-nav-height: ${CFG.navbarHeight}px;
        /* CHANGED Background to Grey/Blue Gradient */
        --toc-bg: linear-gradient(to bottom, #f8f9fa, #e6f0ff);
        --toc-border: #dae0e5; /* Slightly darker border to match new bg */
      }

      :is(main, .main) :is(h1,h2,h3,h4,h5,h6){ scroll-margin-top: ${CFG.headerOffset}px; }

      /* Panel Positioning */
      #toc-panel {
        position: fixed; 
        top: var(--toc-nav-height); 
        right: 0; 
        height: calc(100vh - var(--toc-nav-height)); 
        width: var(--toc-width); 
        max-width: 85vw;
        background: var(--toc-bg); 
        border-left: 1px solid var(--toc-border);
        z-index: ${CFG.zBase};
        display: flex; flex-direction: column;
        transform: translateX(100%); 
        transition: transform 0.3s cubic-bezier(0.25, 1, 0.5, 1);
        box-shadow: -10px 0 30px rgba(0,0,0,0.15);
      }

      /* Mobile Toggle */
      #toc-toggle-btn {
        position: fixed; 
        top: calc(var(--toc-nav-height) + 15px); 
        right: 15px;
        z-index: ${CFG.zBase + 10};
        display: flex; align-items: center; justify-content: center;
        width: 44px; height: 44px;
        border: 1px solid #ccc; border-radius: 8px;
        /* Slight gradient on mobile button too */
        background: linear-gradient(to bottom, #fff, #f0f2f5); 
        cursor: pointer; 
        font-size: 24px; line-height: 1;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        color: #333;
      }

      body.toc-mobile-open #toc-panel { transform: translateX(0); }
      body.toc-mobile-open { overflow: hidden; }

      /* Desktop State */
      @media (min-width: ${CFG.breakpoint}px) {
        body {
          margin-right: var(--toc-width);
          transition: margin-right 0.3s ease;
        }
        #toc-panel {
          transform: translateX(0) !important;
          box-shadow: none; 
          /* Use the variable border */
          border-left: 1px solid var(--toc-border);
        }
        #toc-toggle-btn { display: none !important; }
        #toc-close { display: none !important; }
        body.toc-mobile-open { overflow: auto; }
      }

      /* Content Styling */
      #toc-head {
        padding: 1rem 1.2rem; 
        border-bottom: 1px solid var(--toc-border);
        display: flex; justify-content: space-between; align-items: center;
        /* Make header slightly darker/bluer transparent to show gradient beneath or set solid */
        background: rgba(230, 240, 255, 0.5);
      }
      #toc-head h3 { margin:0; font-size:16px; font-weight:600; text-transform:uppercase; letter-spacing:0.5px; color: #2c3e50; }
      
      #toc-close {
        background: none; border: none; font-size: 20px; cursor: pointer; padding: 0 5px; color: #555;
      }

      #toc-content { 
        flex: 1; overflow-y: auto; 
        padding: 1rem 1.2rem 3rem; 
        font-family: system-ui, -apple-system, sans-serif;
        font-size: 14px;
      }
      #toc-content ul { list-style:none; margin: 0; padding-left: 1rem; }
      #toc-content li { margin: 6px 0; line-height: 1.4; }
      #toc-content a { text-decoration:none; color: #444; display: block; transition: color 0.2s;}
      #toc-content a:hover { color: #0056b3; } /* Slightly darker blue hover */

      #toc-content .lvl-1 > a { font-weight: 700; color: #000; margin-top: 15px; margin-bottom: 5px; }
      #toc-content .lvl-2 > a { font-weight: 600; color: #2c3e50; } /* Dark blue-grey for H2 */
      #toc-content .lvl-3 > a { font-weight: 400; color: #546e7a; font-size: 13px; } /* Lighter blue-grey for H3 */

      /* Caret Logic */
      .toc-caret { 
        display:inline-block; width:12px; margin-right:4px; 
        cursor:pointer; color:#78909c; /* Blue-grey caret */
        transition: transform 0.2s;
      }
      .toc-row { display: flex; align-items: baseline; }
      
      /* Only hide UL if class 'toc-collapsed' is present */
      .toc-collapsed > ul { display: none; }
      
      /* Rotate caret: Default (expanded) is Down. Collapsed is Right (-90deg) */
      .toc-collapsed .toc-caret { transform: rotate(-90deg); }
      .toc-caret::before { content: '▼'; font-size: 10px; }
    `;
    document.head.appendChild(style);
  }

  function createShell() {
    let toggle = document.getElementById('toc-toggle-btn');
    if (!toggle) {
      toggle = document.createElement('button');
      toggle.id = 'toc-toggle-btn';
      toggle.innerHTML = '☰'; 
      document.body.appendChild(toggle);
    }

    let panel = document.getElementById('toc-panel');
    if (!panel) {
      panel = document.createElement('aside');
      panel.id = 'toc-panel';
      
      const head = document.createElement('div');
      head.id = 'toc-head';
      head.innerHTML = `<h3>Contents</h3><button id="toc-close">✕</button>`;

      const content = document.createElement('div');
      content.id = 'toc-content';
      content.innerHTML = '<p><em>Loading…</em></p>';

      panel.append(head, content);
      document.body.appendChild(panel);
    }

    return { toggle, panel };
  }

  function toggleMobileTOC() {
    document.body.classList.toggle('toc-mobile-open');
  }

  function findExistingTOC() {
    return $('nav[role="navigation"].toc-active') || $('#TOC') || $('nav.sidebar-navigation .toc-active');
  }

  function buildFromHeadings() {
    const container = document.createElement('div');
    const ul1 = document.createElement('ul');
    const heads = $$(CFG.headingSelector).filter(h => {
      const lvl = Number(h.tagName[1]);
      return lvl >= 2 && lvl <= CFG.maxDepth;
    });

    let lastH2 = null;

    heads.forEach(h => {
      const lvl = Number(h.tagName[1]);
      const id = '#' + ensureId(h);
      const a = document.createElement('a');
      a.href = id;
      a.textContent = h.textContent.trim();
      a.onclick = () => document.body.classList.remove('toc-mobile-open'); 

      if (lvl === 2) {
        const li = document.createElement('li'); li.className = 'lvl-2';
        const row = document.createElement('div'); row.className = 'toc-row';
        const caret = document.createElement('span'); caret.className = 'toc-caret';
        
        row.append(caret, a);
        li.append(row);
        
        const ul2 = document.createElement('ul');
        li.append(ul2);
        
        // CONFIG CHECK: Start collapsed?
        if (CFG.startCollapsed) {
          li.classList.add('toc-collapsed');
        }

        caret.onclick = (e) => { e.stopPropagation(); li.classList.toggle('toc-collapsed'); };

        ul1.appendChild(li);
        lastH2 = li;
      } else if (lvl === 3 && lastH2) {
        const li = document.createElement('li'); li.className = 'lvl-3';
        li.append(a);
        lastH2.querySelector('ul').appendChild(li);
      }
    });

    container.appendChild(ul1);
    return container;
  }

  function init() {
    injectStyles();
    const { toggle, panel } = createShell();
    
    toggle.onclick = toggleMobileTOC;
    $('#toc-close', panel).onclick = toggleMobileTOC;
    
    const content = $('#toc-content', panel);
    const existing = findExistingTOC();
    
    if (existing) {
      content.innerHTML = '';
      content.appendChild(existing.cloneNode(true));
      $$('a', content).forEach(a => a.onclick = () => document.body.classList.remove('toc-mobile-open'));
    } else if (CFG.buildFromHeadingsIfMissingSidebar) {
      content.innerHTML = '';
      content.appendChild(buildFromHeadings());
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

})();