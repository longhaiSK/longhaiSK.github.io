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
            // UPDATED: Pass only the injected list
            syncActiveState(clonedList);
        }
      }
    }
  }

  // --- PART C: LIVE SYNC (REPLACED) ---
  function syncActiveState(injectedToc) {
    // Select headers in the content area
    const headers = document.querySelectorAll('main h1, main h2, main h3, main h4, main h5, main h6');
    const tocLinks = injectedToc.querySelectorAll('a');
    
    // Create a map of ID -> Link for O(1) lookup
    const idToLink = {};
    tocLinks.forEach(link => {
        const href = link.getAttribute('href');
        if(href && href.startsWith('#')) {
             idToLink[href.substring(1)] = link;
        }
    });

    // Observer: Triggers when a header enters the top 30% of the screen
    // rootMargin: top, right, bottom, left. 
    // '-80%' bottom means the "active zone" is only the top 20% of the viewport.
    const observerOptions = {
        root: null,
        rootMargin: '0px 0px -80% 0px', 
        threshold: 0
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            // Only act when a header *enters* the zone.
            // If it leaves (scrolls up out of view), we don't clear active immediately 
            // to ensure the section stays highlighted while reading long content.
            if (entry.isIntersecting) {
                const id = entry.target.getAttribute('id');
                const activeLink = idToLink[id];
                
                if (activeLink) {
                    // Remove active from all other links
                    tocLinks.forEach(l => l.classList.remove('active'));
                    
                    // Set current active
                    activeLink.classList.add('active');
                    
                    // Auto-expand parents
                    const parentUl = activeLink.closest('ul');
                    if (parentUl && parentUl.style.display === 'none') {
                           parentUl.style.display = 'block';
                           const parentLink = parentUl.parentElement.querySelector('a.has-children');
                           if (parentLink) {
                               parentLink.classList.remove('collapsed');
                               parentLink.classList.add('expanded');
                           }
                    }
                }
            }
        });
    }, observerOptions);

    headers.forEach(header => observer.observe(header));
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
