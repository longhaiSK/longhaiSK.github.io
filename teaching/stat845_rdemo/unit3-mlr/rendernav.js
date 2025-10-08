// --- Helper: load CSS once, and as late as possible so it beats Bootstrap ---
function ensureCssLoaded(href) {
  const exists = Array.from(document.querySelectorAll('link[rel="stylesheet"]'))
    .some(l => (l.getAttribute('href') || '').split('?')[0] === href);
  if (exists) return;
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.type = 'text/css';
  link.href = href + '?v=' + Date.now(); // cache-bust while iterating
  // Append at the very end of <head> so it overrides theme styles
  document.head.appendChild(link);
}

// --- Path normalization robust to /page, /page/, /page.html, and <base> tags ---
function getBasePath() {
  const b = document.querySelector('base[href]');
  if (!b) return '';
  try { return new URL(b.getAttribute('href'), window.location.origin).pathname.replace(/\/+$/, ''); }
  catch { return ''; }
}

function normalizePathLikeQuarto(pathname) {
  // Remove base path if present
  const base = getBasePath();
  let p = pathname;
  if (base && p.startsWith(base)) p = p.slice(base.length) || '/';

  // If root or directory-like, assume index.html
  if (p === '/') return '/index.html';
  if (p.endsWith('/')) p = p + 'index.html';

  // Add .html if no extension
  if (!/\.[a-zA-Z0-9]+$/.test(p)) p = p + '.html';
  return p;
}

// --- Setup all behaviors ---
function setupNavigation() {
  // 1) Set page title (only if empty)
  (function setPageTitleIfNotExists() {
    const siteTitles = {
      "/index.html": "Homepage of Professor Longhai Li",
      "/teaching.html": "Teaching Activities of Prof. Longhai Li",
      "/grant.html": "Research Activities of Prof. Longhai Li",
      "/team.html": "Members of Longhai Li's Research Lab",
      "/publications.html": "Publications of Prof. Longhai Li",
      "/software.html": "Software Released by Prof. Longhai Li",
      "/longhaishortcv.html": "Biography of Prof. Longhai Li",
      "/longhaicontacts.html": "Contact Information of Prof. Longhai Li"
    };
    const defaultSiteTitle = "Homepage of Professor Longhai Li";
    if (document.title && document.title.trim() !== "") return;
    const cur = normalizePathLikeQuarto(window.location.pathname);
    document.title = siteTitles[cur] || defaultSiteTitle;
  })();

  // 2) Active link highlight
  (function setActiveButton() {
    const cur = normalizePathLikeQuarto(window.location.pathname);
    const links = document.querySelectorAll('#navigation-placeholder .nav-links a.nav-link');
    links.forEach(a => {
      a.classList.remove('active');
      const href = a.getAttribute('href');
      if (!href || href.startsWith('http') || href.startsWith('mailto')) return;
      const norm = normalizePathLikeQuarto(new URL(href, window.location.origin).pathname);
      if (norm === cur) a.classList.add('active');
    });
  })();

  // 3) Hamburger open/close + click-away
  (function setupResponsiveMenu() {
    const hamburger = document.querySelector('#navigation-placeholder .hamburger-menu');
    const menu = document.querySelector('#navigation-placeholder .nav-links');
    if (!hamburger || !menu) return;

    hamburger.addEventListener('click', (e) => {
      e.stopPropagation();
      menu.classList.toggle('active');
      hamburger.classList.toggle('active');
      hamburger.setAttribute('aria-expanded', menu.classList.contains('active') ? 'true' : 'false');
    });

    document.addEventListener('click', (e) => {
      if (!menu.classList.contains('active')) return;
      if (menu.contains(e.target) || hamburger.contains(e.target)) return;
      menu.classList.remove('active');
      hamburger.classList.remove('active');
      hamburger.setAttribute('aria-expanded', 'false');
    });

    // Close on Escape for accessibility
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && menu.classList.contains('active')) {
        menu.classList.remove('active');
        hamburger.classList.remove('active');
        hamburger.setAttribute('aria-expanded', 'false');
        hamburger.focus();
      }
    });
  })();

  // 4) Search form behavior
  (function activateSearchForm() {
    const form = document.getElementById('site-search-form');
    const input = document.getElementById('search-query');
    if (!form || !input) return;

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const open = input.classList.contains('active');
      if (open) {
        const q = input.value.trim();
        input.classList.remove('active');
        if (q) {
          const url = `https://www.google.com/search?q=site:longhaisk.github.io+${encodeURIComponent(q)}`;
          window.open(url, '_blank');
        }
      } else {
        input.classList.add('active');
        input.focus();
      }
    });
  })();
}

// --- Main mount ---
document.addEventListener('DOMContentLoaded', function () {
  // Load your CSS LAST so it overrides Bootstrap/Cosmo.
  ensureCssLoaded('mystyles.css');

  // Build nav HTML
  const navigationHTML = `
    <nav class="responsive-nav" aria-label="Site navigation">
      <div class="nav-brand">
        <img src="/images/usask-logo-lg.png" class="nav-logo" alt="UofS Logo">
      </div>
      <button class="hamburger-menu" aria-label="Toggle menu" aria-expanded="false" aria-controls="site-nav-links">
        <span class="hamburger-bar"></span>
        <span class="hamburger-bar"></span>
        <span class="hamburger-bar"></span>
      </button>
      <ul id="site-nav-links" class="nav-links">
        <li><a href="/index.html" class="btn nav-link">About Me</a></li>
        <li><a href="/research.html" class="btn nav-link">Research Projects</a></li>
        <li><a href="/team.html" class="btn nav-link">Lab Members</a></li>
        <li><a href="/publications.html" class="btn nav-link">Publications</a></li>
        <li><a href="/teaching.html" class="btn nav-link">Courses</a></li>
        <li>
          <form id="site-search-form" class="search-form" role="search">
            <input id="search-query" type="search" class="search-input" placeholder="Search this site...">
            <button type="submit" class="search-btn" aria-label="Search">
              <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
              </svg>
            </button>
          </form>
        </li>
      </ul>
    </nav>
  `;

  // Create placeholder
  const navPlaceholder = document.createElement('div');
  navPlaceholder.id = 'navigation-placeholder';
  navPlaceholder.innerHTML = navigationHTML;

  // Prefer mounting near Quarto's header so your CSS interacts predictably
  const quartoHeader = document.querySelector('header#quarto-header');
  if (quartoHeader) {
    // insert AFTER the Quarto navbar so your nav sits just beneath it
    quartoHeader.insertAdjacentElement('afterend', navPlaceholder);
  } else {
    document.body.prepend(navPlaceholder);
  }

  setupNavigation();
});
