// loadtoc.js (ToC + compact "Up" icon above the title)
document.addEventListener('DOMContentLoaded', function () {
  const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
    .filter(heading => !heading.closest('#toc-container') && !heading.closest('.no-toc'));

  if (headings.length === 0) {
    console.log("ToC: No headings found, ToC will not be generated.");
    return;
  }

  // --- Helper: compute parent directory URL safely ---
  function getParentDirUrl() {
    const { pathname } = window.location;
    let path = pathname;

    if (path.endsWith('/index.html')) path = path.slice(0, -('index.html'.length));
    if (!path.endsWith('/')) path = path.slice(0, path.lastIndexOf('/') + 1);

    const withoutTrailing = path.endsWith('/') ? path.slice(0, -1) : path;
    const cut = withoutTrailing.lastIndexOf('/');
    if (cut <= 0) return '/';
    return withoutTrailing.substring(0, cut + 1);
  }

  const parentUrl = getParentDirUrl();
  const atRoot = parentUrl === '/';

  // --- Build containers ---
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

  // --- NEW: compact "Up" icon link ABOVE the title ---
  const upLink = document.createElement('a');
  upLink.classList.add('toc-up-link', 'icon-only');
  upLink.setAttribute('role', 'button');
  upLink.setAttribute('aria-label', atRoot ? 'Already at site root' : 'Go to parent directory');
  upLink.innerHTML = `
    <!-- Small up icon (chevron-up) -->
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
         viewBox="0 0 24 24" fill="none" stroke="currentColor"
         stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
         aria-hidden="true">
      <polyline points="18 15 12 9 6 15"></polyline>
    </svg>
  `;

  if (atRoot) {
    upLink.classList.add('disabled');
    upLink.setAttribute('aria-disabled', 'true');
    upLink.setAttribute('tabindex', '-1');
    upLink.addEventListener('click', (e) => e.preventDefault());
  } else {
    upLink.href = parentUrl; // open parent in same tab
    upLink.setAttribute('target', '_self');
  }
  tocContainer.appendChild(upLink);
  // --- end new "Up" control ---

  const tocTitle = document.createElement('h3');
  tocTitle.textContent = 'Table of Contents';
  tocTitle.classList.add('toc-title');
  tocContainer.appendChild(tocTitle);

  const tocList = document.createElement('ul');
  tocList.classList.add('toc-list');

  // Build nested headings
  const levelStack = [tocList];
  headings.forEach((heading, index) => {
    const listItem = document.createElement('li');
    listItem.classList.add('toc-item');

    const link = document.createElement('a');
    link.classList.add('toc-link');

    if (!heading.id) heading.id = `toc-heading-${index}`;
    const text = heading.textContent.trim();
    link.textContent = text;
    link.href = `#${heading.id}`;
    link.title = text;
    listItem.appendChild(link);

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
    levelStack[levelStack.length - 1].appendChild(listItem);
  });

  tocContainer.appendChild(tocList);
  document.body.appendChild(tocContainer);
  document.body.appendChild(toggleButton);

  toggleButton.addEventListener('click', () => {
    tocContainer.classList.toggle('active');
    toggleButton.classList.toggle('active');
  });

  document.addEventListener('click', function (event) {
    if (!tocContainer.classList.contains('active')) return;
    const insideToc = tocContainer.contains(event.target);
    const onButton = toggleButton.contains(event.target);
    if (!insideToc && !onButton) {
      tocContainer.classList.remove('active');
      toggleButton.classList.remove('active');
    }
  });

  // Match top offset to your nav bar
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

  // Smooth-scroll for in-page ToC links
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
