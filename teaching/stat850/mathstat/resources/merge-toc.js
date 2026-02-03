document.addEventListener("DOMContentLoaded", function() {

  // --- CONFIG ---
  const REMOVE_UNNUMBERED_FROM_TOC = true; 

  // --- HELPER: FORMAT NUMBERS ---
  function formatLinkText(link) {
    let container = link.querySelector('.menu-text') || link;
    if (container.querySelector('.toc-num')) return false;

    const text = container.innerText;
    if (!text) return false;

    const match = text.match(/^([\d\w\.]+\.?)(\s+)(.*)/);

    if (match) {
      container.innerHTML = `<span class="toc-num">${match[1]}</span><span class="toc-text">${match[3]}</span>`;
      link.classList.add('is-numbered');
      return true;
    } else {
      if (REMOVE_UNNUMBERED_FROM_TOC && link.closest('.injected-page-toc')) {
          const li = link.closest('li');
          if (li) li.remove();
          return false; 
      }
      link.classList.add('is-unnumbered');
      return true;
    }
  }

  // --- PART A: FORMAT CHAPTERS ---
  function formatChapters() {
    const items = document.querySelectorAll('#quarto-sidebar .sidebar-item');
    items.forEach(li => {
      const link = li.querySelector('.sidebar-link');
      const toggleBtn = li.querySelector('.sidebar-item-toggle');

      if (link) {
        formatLinkText(link);
        
        if (toggleBtn) {
          link.classList.add('has-children');
          if (li.classList.contains('sidebar-item-collapsed')) {
             link.classList.add('collapsed');
          } else {
             link.classList.add('expanded');
          }

          if (!link.dataset.hasListener) {
            link.addEventListener('click', (e) => {
               e.stopPropagation(); 
               if (link.classList.contains('collapsed')) {
                   link.classList.remove('collapsed');
                   link.classList.add('expanded');
               } else {
                   link.classList.add('collapsed');
                   link.classList.remove('expanded');
               }
               toggleBtn.click();
            });
            link.dataset.hasListener = "true";
          }
        }
      }
    });
  }

  // --- PART B: INJECT PAGE TOC ---
  function moveToc() {
    const toc = document.querySelector('nav[role="doc-toc"]');
    const activeLink = document.querySelector('.sidebar-link.active');

    if (toc && activeLink) {
      const parentLi = activeLink.closest('.sidebar-item');
      if (parentLi && !parentLi.querySelector('.injected-page-toc')) {
        const tocList = toc.querySelector('ul');
        if (tocList) {
            const clonedList = tocList.cloneNode(true);
            clonedList.className = 'injected-page-toc';

            const links = clonedList.querySelectorAll('a');
            links.forEach(link => formatLinkText(link));

            const parents = clonedList.querySelectorAll('li');
            parents.forEach(li => {
                if (li.querySelector('ul')) { 
                    const link = li.querySelector('a');
                    const subList = li.querySelector('ul');
                    if (link && subList) {
                        link.classList.add('has-children');
                        link.classList.add('collapsed'); 
                        subList.style.display = 'none';

                        if (!link.dataset.hasListener) {
                            link.addEventListener('click', (e) => {
                                e.stopPropagation();
                                if (subList.style.display === 'none') {
                                    subList.style.display = 'block';
                                    link.classList.remove('collapsed');
                                    link.classList.add('expanded');
                                } else {
                                    subList.style.display = 'none';
                                    link.classList.remove('expanded');
                                    link.classList.add('collapsed');
                                }
                            });
                            link.dataset.hasListener = "true";
                        }
                    }
                }
            });
            parentLi.appendChild(clonedList);
            syncActiveState(clonedList); 
        }
      }
    }
  }

  // --- PART C: LIVE SYNC (Title Priority Fix) ---
  function syncActiveState(injectedToc) {
    // 1. Clean Slate: Remove any 'active' class that Quarto might have auto-injected into the sub-toc
    const tocLinks = injectedToc.querySelectorAll('a');
    tocLinks.forEach(l => l.classList.remove('active')); // Remove default active
    tocLinks.forEach(l => l.classList.remove('toc-active')); 

    const headers = document.querySelectorAll('main h1, main h2, main h3, main h4, main h5, main h6');
    const idToLink = {};
    
    // Map IDs to Links
    tocLinks.forEach(link => {
        const href = link.getAttribute('href');
        if(href && href.startsWith('#')) {
            const id = href.substring(1);
            idToLink[id] = link;
            idToLink[decodeURIComponent(id)] = link; 
        }
    });

    // --- STRATEGY: TWO OBSERVERS ---

    // Observer 1: The "Cleaner" (Watches the Main Title H1)
    // If H1 is visible, we force-clear all sub-section highlights.
    const titleObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // If Title is visible, CLEAR all sub-highlights
                tocLinks.forEach(l => l.classList.remove('toc-active'));
            }
        });
    }, { rootMargin: '0px 0px -50% 0px' }); // Aggressive: Title must be in top half

    const mainTitle = document.querySelector('main h1');
    if (mainTitle) titleObserver.observe(mainTitle);


    // Observer 2: The "Highlighter" (Watches H2-H6)
    // Triggers only when headers cross a "read line" near the top
    const contentObserverOptions = {
        root: null,
        rootMargin: '0px 0px -80% 0px', // Trigger only when element is near top
        threshold: 0
    };

    const contentObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Double Check: If we are effectively at the top of the page, ignore this trigger
                // (This prevents the first H2 from "winning" on page load if H1 is also there)
                if (window.scrollY < 100) return; 

                const id = entry.target.getAttribute('id');
                const activeSubLink = idToLink[id];
                
                if (activeSubLink) {
                    // 1. Clear others
                    tocLinks.forEach(l => l.classList.remove('toc-active'));
                    
                    // 2. Activate this one
                    activeSubLink.classList.add('toc-active');
                    
                    // 3. Auto-expand parents
                    const parentUl = activeSubLink.closest('ul');
                    if (parentUl && parentUl.style.display === 'none') {
                           parentUl.style.display = 'block';
                           const pLink = parentUl.parentElement.querySelector('a.has-children');
                           if (pLink) {
                               pLink.classList.remove('collapsed');
                               pLink.classList.add('expanded');
                           }
                    }
                }
            }
        });
    }, contentObserverOptions);

    // Only observe H2+ for highlighting (H1 is handled by the Cleaner)
    headers.forEach(header => {
        if (header.tagName !== 'H1') {
            contentObserver.observe(header);
        }
    });
  }

  // --- PART D: SIDEBAR TOGGLE ---
  function createSidebarToggle() {
    if (document.getElementById('custom-sidebar-toggle')) return;
    const btn = document.createElement("button");
    btn.id = "custom-sidebar-toggle";
    btn.innerHTML = '&#9776;'; 
    btn.title = "Toggle Sidebar";
    document.body.insertAdjacentElement('afterbegin', btn);
    btn.addEventListener("click", function() {
      document.body.classList.toggle("sidebar-closed");
    });
  }

  // --- EXECUTION ---
  function run() {
    try { createSidebarToggle(); } catch(e) { console.error(e); }
    try { formatChapters(); } catch(e) { console.error(e); }
    try { moveToc(); } catch(e) { console.error(e); }
    document.querySelector('#quarto-sidebar .sidebar-menu-container')?.classList.add('loaded');
  }

  run();
  setTimeout(run, 500); 
});
