document.addEventListener("DOMContentLoaded", function() {
  
  // --- HELPER: WRAP NUMBERS ---
  function processLink(linkElement, isChapter = false) {
    let textContainer = isChapter ? linkElement.querySelector('.menu-text') : linkElement;
    if (!textContainer) textContainer = linkElement; 

    if (textContainer.querySelector('.toc-num')) return; // Already processed

    const currentText = textContainer.innerText;
    // Regex: Match "1. Title" or "2.1. Title"
    const match = currentText.match(/^([\d\w\.]+\.?)(\s+)(.*)/);

    if (match) {
      textContainer.innerHTML = `<span class="toc-num">${match[1]}</span><span class="toc-text">${match[3]}</span>`;
    } else {
      textContainer.innerHTML = `<span class="toc-num"></span><span class="toc-text">${currentText}</span>`;
    }
  }

  // --- PART A: FORMAT CHAPTERS & ENABLE COLLAPSE ---
  function formatChapters() {
    // Select the CONTAINER (li) to find both link and toggle button
    const chapters = document.querySelectorAll('#quarto-sidebar .sidebar-item');
    
    chapters.forEach(li => {
      const link = li.querySelector('.sidebar-link');
      const toggleBtn = li.querySelector('.sidebar-item-toggle');
      
      if (link) {
        processLink(link, true);

        // If this chapter has sub-items (toggle button exists)
        if (toggleBtn) {
            link.classList.add('has-children');
            
            // Sync initial state
            if (li.classList.contains('sidebar-item-collapsed')) {
                link.classList.add('collapsed');
            } else {
                link.classList.remove('collapsed');
            }

            // PROXY CLICK: Clicking the link triggers the toggle button
            link.addEventListener('click', (e) => {
                // Check if it's the active page. 
                // If it is, we only toggle. If not, we let it navigate.
                const isActive = link.classList.contains('active');
                
                // Toggle visual class
                if (link.classList.contains('collapsed')) {
                    link.classList.remove('collapsed');
                } else {
                    link.classList.add('collapsed');
                }
                
                // Click the hidden Quarto button to trigger the slide animation
                toggleBtn.click();
            });
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
            clonedList.className = 'injected-page-toc'; // Reset classes
            
            // Format Links
            const links = clonedList.querySelectorAll('a');
            links.forEach(link => processLink(link, false));

            parentLi.appendChild(clonedList);
            
            // START SYNCING: Watch the original TOC for scroll updates
            syncActiveState(toc, clonedList);
        }
      }
    }
  }

  // --- PART C: LIVE SYNC (FIX FOR BLUE HIGHLIGHT) ---
  function syncActiveState(originalToc, injectedToc) {
    // 1. Create a map of href -> injectedLink
    const linkMap = {};
    injectedToc.querySelectorAll('a').forEach(a => {
        const href = a.getAttribute('href');
        if (href) linkMap[href] = a;
    });

    // 2. Define the Observer
    const observer = new MutationObserver((mutations) => {
        mutations.forEach(mutation => {
            if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
                const originalLink = mutation.target;
                const href = originalLink.getAttribute('href');
                const injectedLink = linkMap[href];

                if (injectedLink) {
                    if (originalLink.classList.contains('active')) {
                        injectedLink.classList.add('active');
                        // Optional: Scroll sidebar to keep it in view?
                    } else {
                        injectedLink.classList.remove('active');
                    }
                }
            }
        });
    });

    // 3. Observe every link in the ORIGINAL hidden TOC
    originalToc.querySelectorAll('a').forEach(a => {
        observer.observe(a, { attributes: true });
    });
  }

  // --- EXECUTION ---
  function run() {
    formatChapters();
    moveToc();
    document.querySelector('#quarto-sidebar .sidebar-menu-container')?.classList.add('loaded');
  }

  run();
  
  // Re-run if Quarto rebuilds the DOM (e.g. search or navigation)
  const sidebar = document.querySelector('#quarto-sidebar');
  if (sidebar) {
      new MutationObserver(() => run()).observe(sidebar, { childList: true, subtree: true });
  }
});
