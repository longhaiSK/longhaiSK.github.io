// loadtoc.js (ToC + "Up" icon above the title; fixed order & vars)
document.addEventListener('DOMContentLoaded', function () {
  const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
    .filter(h => !h.closest('#toc-container') && !h.closest('.no-toc'));

  if (headings.length === 0) {
    console.log("ToC: No headings found, ToC will not be generated.");
    return;
  }

  // --- Create core elements *before* using them ---
  const tocContainer = document.createElement('nav');
  tocContainer.id = 'toc-container';

  const toggleButton = document.createElement('button');
  toggleButton.id = 'toc-toggle-button';
  toggleButton.setAttribute('aria-label', 'Toggle Table of Contents');
  toggleButton.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"
         viewBox="0 0 24 24" fill="none" stroke="currentColor"
         stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="9" y1="6" x2="20" y2="6"></line>
      <line x1="9" y1="12" x2="20" y2="12"></line>
      <line x1="9" y1="18" x2="20" y2="18"></line>
      <circle cx="5" cy="6" r="1"></circle>
      <circle cx="5" cy="12" r="1"></circle>
      <circle cx="5" cy="18" r="1"></circle>
    </svg>`;

  // --- Helpers for Up link ---
  function getParentDirUrlFrom(pathname) {
    let path = pathname;
    if (path.endsWith('/index.html')) path = path.slice(0, -('index.html'.length));
    if (!path.endsWith('/')) path = path.slice(0, path.lastIndexOf('/') + 1);
    const withoutTrailing = path.endsWith('/') ? path.slice(0, -1) : path;
    const cut = withoutTrailing.lastIndexOf('/');
    if (cut <= 0) return '/';
    return withoutTrailing.substring(0, cut + 1);
  }
  function isCurrentAtRoot(pathname) {
    return pathname === '/' || pathname === '' || pathname === '/index.html';
  }

  const parentUrl = getParentDirUrlFrom(window.location.pathname);
  const atRootNow = isCurrentAtRoot(window.location.pathname);

  // --- Up icon ABOVE the title ---
  const upLink = document.createElement('a');
  upLink.classList.add('toc-up-link', 'icon-only');
  upLink.setAttribute('role', 'button');
  upLink.setAttribute('aria-label', atRootNow ? 'Already at site root' : 'Go to parent directory');
  upLink.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22"
         viewBox="0 0 24 24" fill="none" stroke="currentColor"
         stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
         aria-hidden="true">
      <polyline points="18 14 12 8 6 14"></polyline>
      <polyline points="18 18 12 12 6 18"></polyline>
    </svg>
  `;
  if (atRootNow) {
    upLink.classList.add('disabled');
    upLink.setAttribute('aria-disabled', 'true');
    upLink.setAttribute('tabindex', '-1');
    upLink.addEventListener('click', (e) => e.preventDefault());
  } else {
    upLink.href = parentUrl;
    upLink.setAttribute('target', '_self');
  }
  tocContainer.appendChild(upLink);

  // --- Title ---
  const tocTitle = document.createElement('h3');
  tocTitle.textContent = 'Table of Contents';
  tocTitle.classList.add('toc-title');
  tocContainer.appendChild(tocTitle);

  // --- Build ToC list ---
  const tocList = document.createElement('ul');
  tocList.classList.add('toc-list');
  const levelStack = [tocList];

  headings.forEach((heading, index) => {
    const li = document.createElement('li');
    li.classList.add('toc-item');
    const a = document.createElement('a');
    a.classList.add('toc-link');

    if (!heading.id) heading.id = `toc-heading-${index}`;
    const text = heading.textContent.trim();
    a.textContent = text;
    a.href = `#${heading.id}`;
    a.title = text;
    li.appendChild(a);

    const level = parseInt(heading.tagName.substring(1));
    if (index > 0) {
      const prev = parseInt(headings[index - 1].tagName.substring(1));
      if (level > prev) {
        const parentLi = levelStack[levelStack.length - 1].lastChild;
        if (parentLi) {
          const sub = document.createElement('ul');
          sub.classList.add('toc-list', 'toc-sublist');
          parentLi.appendChild(sub);
          levelStack.push(sub);
        }
      } else if (level < prev) {
        for (let i = 0; i < (prev - level); i++) {
          if (levelStack.length > 1) levelStack.pop();
        }
      }
    }
    levelStack[levelStack.length - 1].appendChild(li);
  });

  tocContainer.appendChild(tocList);
  document.body.appendChild(tocContainer);
  document.body.appendChild(toggleButton);

  // --- Interactions ---
  toggleButton.addEventListener('click', () => {
    tocContainer.classList.toggle('active');
    toggleButton.classList.toggle('active');
  });

  document.addEventListener('click', (event) => {
    if (!tocContainer.classList.contains('active')) return;
    const insideToc = tocContainer.contains(event.target);
    const onButton = toggleButton.contains(event.target);
    if (!insideToc && !onButton) {
      tocContainer.classList.remove('active');
      toggleButton.classList.remove('active');
    }
  });

  // --- Position to match nav height ---
  requestAnimationFrame(() => {
    const navBar = document.querySelector('.responsive-nav');
    let navBarHeight = 60;
    if (navBar) navBarHeight = navBar.offsetHeight;

    const finalTopOffset = navBarHeight;
    const finalMaxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`;

    tocContainer.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
    tocContainer.style.setProperty('--toc-max-height', finalMaxHeight);
    toggleButton.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
  });

  // --- Smooth-scroll for in-page anchors (skip the Up link) ---
  document.querySelectorAll('#toc-container a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      if (this.classList.contains('disabled')) return;
      const href = this.getAttribute('href');
      if (!href || href.length <= 1 || !href.startsWith('#')) return;
      e.preventDefault();

      const target = document.getElementById(href.substring(1));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        if (history.pushState) history.pushState(null, null, href);
      }
    });
  });
});
