document.addEventListener("DOMContentLoaded", function() {

  // --- CONFIG ---
  const REMOVE_UNNUMBERED_FROM_TOC = true; 

  // --- HELPER: FORMAT NUMBERS ---
  function formatLinkText(link) {
    let container = link.querySelector('.menu-text') || link;
    
    // Prevent double-formatting
    if (container.querySelector('.toc-num')) return false;

    const text = container.innerText;
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

  // --- PART A: FORMAT CHAPTERS (Level 1) ---
  function formatChapters() {
    const items = document.querySelectorAll('#quarto-sidebar .sidebar-item');
    items.forEach(li => {
      const link = li.querySelector('.sidebar-link');
      const toggleBtn = li.querySelector('.sidebar-item-toggle');

      if (link) {
        formatLinkText(link);
        
        // COLLAPSE LOGIC
        if (toggleBtn) {
          link.classList.add('has-children');
          
          // Sync initial state from Quarto
          if (li.classList.contains('sidebar-item-collapsed')) {
             link.classList.add('collapsed');
          } else {
             link.classList.add('expanded');
          }

          // Proxy Click
          if (!link.dataset.hasListener) {
            link.addEventListener('click', (e) => {
               // STOP BUBBLING: This fixes the "Preface collapses everything" issue
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

  // --- PART B: INJECT PAGE TOC (Level 2+) ---
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

            // Process Links
            const links = clonedList.querySelectorAll('a');
            links.forEach(link => {
               formatLinkText(link);
            });

            // Collapse Logic for Inner Items
            const parents = clonedList.querySelectorAll('li');
            parents.forEach(li => {
                if (li.querySelector('ul')) { 
                    const link = li.querySelector('a');
                    const subList = li.querySelector('ul');
                    
                    if (link && subList) {
                        link.classList.add('has-children');
                        
                        // CHANGED: Default to Collapsed (Hidden)
                        link.classList.add('collapsed'); 
                        subList.style.display = 'none';

                        if (!link.dataset.hasListener) {
                            link.addEventListener('click', (e) => {
                                e.stopPropagation(); // Prevent parent triggers
                                
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
            syncActiveState(toc, clonedList);
        }
      }
    }
  }

  // --- PART C: LIVE SYNC ---
  function syncActiveState(originalToc, injectedToc) {
    const linkMap = {};
    injectedToc.querySelectorAll('a').forEach(a => {
        const href = a.getAttribute('href');
        if (href) linkMap[href] = a;
    });

    const observer = new MutationObserver((mutations) => {
        mutations.forEach(mutation => {
            if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
                const originalLink = mutation.target;
                const href = originalLink.getAttribute('href');
                const injectedLink = linkMap[href];
                if (injectedLink) {
                    if (originalLink.classList.contains('active')) {
                        injectedLink.classList.add('active');
                        
                        // Optional: Auto-expand parent if active child is found
                        const parentUl = injectedLink.closest('ul');
                        if (parentUl && parentUl.style.display === 'none') {
                           parentUl.style.display = 'block';
                           const parentLink = parentUl.parentElement.querySelector('a.has-children');
                           if (parentLink) {
                               parentLink.classList.remove('collapsed');
                               parentLink.classList.add('expanded');
                           }
                        }
                    } else {
                        injectedLink.classList.remove('active');
                    }
                }
            }
        });
    });

    originalToc.querySelectorAll('a').forEach(a => observer.observe(a, { attributes: true }));
  }

  // --- EXECUTION ---
  function run() {
    formatChapters();
    moveToc();
    const container = document.querySelector('#quarto-sidebar .sidebar-menu-container');
    if (container) container.classList.add('loaded');
  }

  run();
  setTimeout(run, 500);
});