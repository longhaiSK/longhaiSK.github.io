// loadtoc.js — namespaced, self-contained TOC (right side, collapsible)
// - Injects its own CSS (namespaced with "my-")
// - Right-docked slide-in panel + toggle button (chevron flips for right side)
// - Collapsible subsections with chevrons
// - Default: ONLY H1 expanded initially; H2 shown (collapsed), H3+ hidden
// - Uniform alignment: caret/bullet share the same icon column
// - Robust (no Array.prototype.at), Quarto/Bootstrap friendly

document.addEventListener('DOMContentLoaded', function () {
  // ---------- 1) Inject CSS ----------
  const css = `
  :root{
    --my-toc-width: 300px;
    --my-navbar-height: 56px;
  }

  /* Panel (right-docked) */
  #my-toc-container {
    position: fixed;
    top: var(--my-navbar-height, 56px);
    right: 0;
    left: auto;
    width: var(--my-toc-width);
    max-height: calc(100vh - var(--my-navbar-height, 56px) - 24px);
    transform: translateX(calc(100% + 10px)); /* hidden offscreen to the right */
    overflow-y: auto;
    z-index: 999;
    background-color: #f9f9f9;
    border: 1px solid #ddd;
    border-right: none;
    border-radius: 8px 0 0 8px;
    padding: 14px 16px;
    font-family: Arial, sans-serif;
    box-sizing: border-box;
    box-shadow: -2px 0 5px rgba(0,0,0,0.1);
    transition: transform 0.35s ease-in-out;
  }
  #my-toc-container.my-active { transform: translateX(0); }

  /* Push page content when open (desktop) */
  body.my-toc-open {
    margin-right: var(--my-toc-width);
    transition: margin-right 0.35s ease-in-out;
  }

  /* Toggle button (right edge) */
  #my-toc-toggle-button {
    position: fixed;
    top: var(--my-navbar-height, 56px);
    right: 0;
    left: auto;
    z-index: 1001;
    background-color: #e0e0e0;
    border: 1px solid #ccc;
    border-right: none;
    border-radius: 8px 0 0 8px;
    padding: 2px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-shadow: -2px 0 5px rgba(0,0,0,0.1);
    transition: background-color 0.25s ease-in-out, transform 0.35s ease-in-out;
  }
  #my-toc-toggle-button:hover { background-color: #d0d0d0; }
  #my-toc-toggle-button:focus-visible {
    outline: 2px solid royalblue;
    outline-offset: 2px;
  }
  /* Chevron: CLOSED points LEFT (◀) for right-docked panel */
  #my-toc-toggle-button svg {
    width: 40px; height: 40px; color: royalblue; display: block;
    transition: transform 0.25s ease-in-out;
    transform: rotate(180deg);
  }
  /* When open: slide button left & point RIGHT (▶) */
  #my-toc-toggle-button[aria-expanded="true"] { transform: translateX(calc(-1 * var(--my-toc-width))); }
  #my-toc-toggle-button[aria-expanded="true"] svg { transform: rotate(0deg) scale(0.9); }

  /* Title */
  .my-toc-title {
    margin: 0 0 10px 0;
    font-size: 1.05em;
    font-weight: 700;
    color: #000;
  }

  /* --- Lists: remove native bullets so we control alignment --- */
  .my-toc-list, .my-toc-sublist {
    list-style: none;
    padding-left: 0;
    margin: 0;
  }
  /* Indentation for nested lists */
  .my-toc-sublist { margin-left: 1.1rem; }

  /* --- Rows: two-column grid [icon][text] for perfect alignment --- */
  .my-toc-row {
    display: grid;
    grid-template-columns: 1.25em 1fr; /* icon rail, then text */
    align-items: center;
    column-gap: 6px;
  }

  /* Links (text column) */
  .my-toc-link {
    grid-column: 2;
    text-decoration: none;
    color: royalblue;
    display: block;
    padding: 3px 0; /* slightly tighter rhythm */
    font-size: 1em;
  }
  .my-toc-link:hover, .my-toc-link:focus { text-decoration: underline; }
  .my-toc-link:focus-visible {
    outline: 2px solid royalblue;
    outline-offset: 2px;
  }

  /* Caret button (icon column) */
  .my-toc-caret-btn {
    grid-column: 1;
    width: 1.25em;
    height: 1.25em;
    appearance: none;
    background: none;
    border: none;
    padding: 0;
    margin: 0;
    cursor: pointer;
    line-height: 1;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
  }
  .my-toc-caret-btn:hover { background: rgba(0,0,0,0.05); }
  .my-toc-caret-btn:focus-visible {
    outline: 2px solid royalblue;
    outline-offset: 2px;
  }
  .my-toc-caret {
    width: 1em;
    height: 1em;
    transition: transform 0.2s ease;
  }
  /* Branch collapsed: caret points RIGHT (▶) */
  .my-toc-item.my-has-children:not(.my-is-open) > .my-toc-row .my-toc-caret { transform: rotate(-90deg); }

  /* Leaf rows (no children): draw a pseudo-bullet in the icon column for alignment */
  .my-toc-item:not(.my-has-children) > .my-toc-row::before {
    content: "";
    grid-column: 1;
    width: 0.5em;
    height: 0.5em;
    border-radius: 50%;
    background: currentColor; /* matches link color (royalblue / dark-mode variant) */
    opacity: 0.6;
    justify-self: center;
  }
  /* Ensure branches don't get pseudo-bullets */
  .my-toc-item.my-has-children > .my-toc-row::before { content: none; }

  /* Hide children when collapsed */
  .my-toc-item.my-has-children:not(.my-is-open) > .my-toc-sublist { display: none; }
  /* Optional: emphasize parent link when open */
  .my-toc-item.my-has-children.my-is-open > .my-toc-row > .my-toc-link { font-weight: 600; }

  /* Up link above the title */
  .my-toc-up-link { display: inline-flex; align-items: center; gap: 6px; margin-bottom: 8px; color: inherit; text-decoration: none; }
  .my-toc-up-link.icon-only svg { width: 22px; height: 22px; }
  .my-toc-up-link.my-disabled { opacity: 0.4; pointer-events: none; }

  /* Small screens: overlay (don’t push content) */
  @media (max-width: 800px) {
    body.my-toc-open { margin-right: 0; }
    #my-toc-toggle-button[aria-expanded="true"] { transform: translateX(0); }
    #my-toc-container { max-width: min(85vw, var(--my-toc-width)); width: min(85vw, var(--my-toc-width)); }
  }

  /* Dark mode */
  @media (prefers-color-scheme: dark) {
    #my-toc-container { background-color: #1f1f1f; border-color: #333; box-shadow: -2px 0 6px rgba(0,0,0,0.6); }
    #my-toc-toggle-button { background-color: #2a2a2a; border-color: #3a3a3a; }
    #my-toc-toggle-button:hover { background-color: #333; }
    .my-toc-title { color: #fff; }
    .my-toc-link { color: #9ab6ff; }
    .my-toc-caret-btn:hover { background: rgba(255,255,255,0.06); }
  }

  /* Reduced motion */
  @media (prefers-reduced-motion: reduce) {
    #my-toc-container, #my-toc-toggle-button, body.my-toc-open { transition: none !important; }
  }

  /* Print */
  @media print {
    #my-toc-container, #my-toc-toggle-button { display: none !important; }
  }`;

  const style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  // ---------- 2) Collect headings ----------
  const headings = Array.prototype.slice.call(
    document.querySelectorAll('h1,h2,h3,h4,h5,h6')
  ).filter(function(h){
    return !h.closest('#my-toc-container') && !h.closest('.my-no-toc');
  });

  if (!headings || headings.length === 0) return;

  // ---------- 3) Build container + toggle ----------
  const toc = document.createElement('nav');
  toc.id = 'my-toc-container';

  const toggleBtn = document.createElement('button');
  toggleBtn.id = 'my-toc-toggle-button';
  toggleBtn.type = 'button';
  toggleBtn.setAttribute('aria-expanded', 'false');
  toggleBtn.setAttribute('aria-label', 'Toggle Table of Contents');
  toggleBtn.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6z"/></svg>';

  // Up link helpers
  function getParentDir(p){
    var path = p;
    if (path.slice(-11) === '/index.html') path = path.slice(0, -11);
    if (path.slice(-1) !== '/') path = path.slice(0, path.lastIndexOf('/') + 1);
    var noTrail = path.slice(-1) === '/' ? path.slice(0, -1) : path;
    var cut = noTrail.lastIndexOf('/');
    return (cut <= 0) ? '/' : noTrail.substring(0, cut + 1);
  }
  var parentHref = getParentDir(location.pathname);
  var atRoot = (location.pathname === '/' || location.pathname === '' || location.pathname === '/index.html');

  const up = document.createElement('a');
  up.className = 'my-toc-up-link icon-only';
  if (atRoot) {
    up.classList.add('my-disabled');
    up.setAttribute('aria-disabled', 'true');
    up.setAttribute('tabindex', '-1');
  } else {
    up.href = parentHref;
    up.setAttribute('target', '_self');
  }
  up.innerHTML = '<svg viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2.5" aria-hidden="true"><polyline points="18 14 12 8 6 14"></polyline><polyline points="18 18 12 12 6 18"></polyline></svg>';
  toc.appendChild(up);

  const title = document.createElement('h3');
  title.className = 'my-toc-title';
  title.textContent = 'Table of Contents';
  toc.appendChild(title);

  // ---------- 4) Build nested list & tag levels ----------
  const list = document.createElement('ul');
  list.className = 'my-toc-list';
  var stack = [list];

  headings.forEach(function(h, i){
    var li = document.createElement('li');
    li.className = 'my-toc-item';

    var a = document.createElement('a');
    a.className = 'my-toc-link';
    if (!h.id) h.id = 'my-toc-heading-' + i;
    var text = (h.textContent || '').trim();
    a.textContent = text;
    a.href = '#' + h.id;
    a.title = text;

    // Row wrapper for caret/bullet + link
    var row = document.createElement('div');
    row.className = 'my-toc-row';
    row.appendChild(a);
    li.appendChild(row);

    var level = parseInt(h.tagName.substring(1), 10);
    li.dataset.level = String(level);

    if (i > 0) {
      var prevLevel = parseInt(headings[i - 1].tagName.substring(1), 10);
      if (level > prevLevel) {
        // attach sublist to last LI in current top of stack
        var parentList = stack[stack.length - 1];
        var parentLi = parentList ? parentList.lastElementChild : null;
        if (parentLi) {
          var sub = document.createElement('ul');
          sub.className = 'my-toc-list my-toc-sublist';
          parentLi.appendChild(sub);
          stack.push(sub);
        }
      } else if (level < prevLevel) {
        var upCount = prevLevel - level;
        while (upCount-- > 0 && stack.length > 1) stack.pop();
      }
    }

    var currentList = stack[stack.length - 1] || list;
    currentList.appendChild(li);
  });

  toc.appendChild(list);
  document.body.appendChild(toc);
  document.body.appendChild(toggleBtn);

  // ---------- 5) Collapsible with chevrons; default H1 expanded, H2+ collapsed ----------
  var uid = 0;
  function nextId(prefix){ uid += 1; return (prefix || 'my-sub-') + uid; }

  Array.prototype.forEach.call(toc.querySelectorAll('li'), function(li){
    var sub = li.querySelector(':scope > .my-toc-sublist');
    var link = li.querySelector(':scope > .my-toc-row > .my-toc-link');
    if (!sub || !link) return; // leaf: uses pseudo-bullet via CSS

    li.classList.add('my-has-children');
    if (!sub.id) sub.id = nextId('my-sub-');

    var btn = document.createElement('button');
    btn.className = 'my-toc-caret-btn';
    btn.type = 'button';
    btn.setAttribute('aria-controls', sub.id);
    btn.setAttribute('aria-expanded', 'false');
    btn.innerHTML = '<svg class="my-toc-caret" viewBox="0 0 24 24" aria-hidden="true"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg>';

    var rowEl = li.querySelector(':scope > .my-toc-row');
    if (rowEl) rowEl.insertBefore(btn, link);

    function toggleSub(){
      var open = li.classList.toggle('my-is-open');
      btn.setAttribute('aria-expanded', String(open));
    }
    btn.addEventListener('click', toggleSub);
    btn.addEventListener('keydown', function(e){
      if (e.key === 'ArrowRight' && btn.getAttribute('aria-expanded') === 'false') { e.preventDefault(); toggleSub(); }
      if (e.key === 'ArrowLeft'  && btn.getAttribute('aria-expanded') === 'true')  { e.preventDefault(); toggleSub(); }
    });

    // Default: expand ONLY H1; collapse H2+ (so H3+ are hidden)
    var lvl = parseInt(li.dataset.level || '999', 10);
    if (lvl <= 1) {
      li.classList.add('my-is-open');
      btn.setAttribute('aria-expanded', 'true');
    } else {
      li.classList.remove('my-is-open');
      btn.setAttribute('aria-expanded', 'false');
    }
  });

  // ---------- 6) Panel open/close ----------
  function setExpanded(expanded){
    toggleBtn.setAttribute('aria-expanded', String(expanded));
    toc.classList.toggle('my-active', expanded);
    document.body.classList.toggle('my-toc-open', expanded);
  }
  toggleBtn.addEventListener('click', function(){
    var expanded = toggleBtn.getAttribute('aria-expanded') === 'true';
    setExpanded(!expanded);
  });
  document.addEventListener('click', function(e){
    var expanded = toggleBtn.getAttribute('aria-expanded') === 'true';
    if (!expanded) return;
    if (!toc.contains(e.target) && !toggleBtn.contains(e.target)) setExpanded(false);
  });

  // ---------- 7) Smooth in-page scroll ----------
  Array.prototype.forEach.call(toc.querySelectorAll('.my-toc-link[href^="#"]'), function(anchor){
    anchor.addEventListener('click', function(e){
      var href = anchor.getAttribute('href');
      if (!href || href.length <= 1) return;
      var target = document.getElementById(href.substring(1));
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      if (history.pushState) history.pushState(null, '', href);
    });
  });

  // ---------- 8) Auto-measure navbar height ----------
  requestAnimationFrame(function(){
    var nav = document.querySelector('.responsive-nav, .navbar, header.navbar, .quarto-navbar, nav.navbar');
    var h = Math.ceil((nav && nav.getBoundingClientRect().height) || 56);
    document.documentElement.style.setProperty('--my-navbar-height', h + 'px');
  });
});
