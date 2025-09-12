// loadtoc.js (Modified for Toggleable Sidebar with Click-Away-to-Close)
document.addEventListener('DOMContentLoaded', function() {
    // Find headings to determine if a ToC is needed.
    const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
        .filter(heading => !heading.closest('#toc-container') && !heading.closest('.no-toc'));

    // If there are no headings, do nothing.
    if (headings.length === 0) {
        console.log("ToC: No headings found, ToC will not be generated.");
        return;
    }

    // --- Create ToC Container and Toggle Button ---
    const tocContainer = document.createElement('nav');
    tocContainer.id = 'toc-container';

    const toggleButton = document.createElement('button');
    toggleButton.id = 'toc-toggle-button';
    toggleButton.setAttribute('aria-label', 'Toggle Table of Contents');
    // Simple SVG for the arrow icon
    toggleButton.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>`;

    const tocTitle = document.createElement('h3');
    tocTitle.textContent = 'Table of Contents';
    tocTitle.classList.add('toc-title');
    tocContainer.appendChild(tocTitle);

    const tocList = document.createElement('ul');
    tocList.classList.add('toc-list');

    const levelStack = [tocList];

    // --- Populate ToC List (same logic as before) ---
    headings.forEach((heading, index) => {
        const listItem = document.createElement('li');
        listItem.classList.add('toc-item');
        const link = document.createElement('a');
        link.classList.add('toc-link');
        if (!heading.id) {
            heading.id = `toc-heading-${index}`;
        }
        link.textContent = heading.textContent.trim();
        link.href = `#${heading.id}`;
        link.title = heading.textContent.trim();
        listItem.appendChild(link);
        const headingLevel = parseInt(heading.tagName.substring(1));
        if (index > 0) {
            const previousHeadingLevel = parseInt(headings[index - 1].tagName.substring(1));
            if (headingLevel > previousHeadingLevel) {
                const parentListItem = levelStack[levelStack.length - 1].lastChild;
                if (parentListItem) {
                    const newSubList = document.createElement('ul');
                    newSubList.classList.add('toc-list', 'toc-sublist');
                    parentListItem.appendChild(newSubList);
                    levelStack.push(newSubList);
                }
            } else if (headingLevel < previousHeadingLevel) {
                let levelsToPop = previousHeadingLevel - headingLevel;
                for (let i = 0; i < levelsToPop; i++) {
                    if (levelStack.length > 1) { levelStack.pop(); } else { break; }
                }
            }
        }
        levelStack[levelStack.length - 1].appendChild(listItem);
    });

    // --- Append to Body and Set Up Functionality ---
    tocContainer.appendChild(tocList);
    document.body.appendChild(tocContainer);
    document.body.appendChild(toggleButton); // Add the button to the page

    // Event listener for the toggle button
    toggleButton.addEventListener('click', () => {
        tocContainer.classList.toggle('active');
        toggleButton.classList.toggle('active');
    });

    // --- NEW: Add Click-Away-to-Close Functionality ---
    document.addEventListener('click', function(event) {
        // Check if the ToC is currently active/visible
        const isTocActive = tocContainer.classList.contains('active');
        
        // If the ToC is not active, there's nothing to do
        if (!isTocActive) {
            return;
        }

        // Check if the click was inside the ToC panel or on the toggle button
        const isClickInsideToc = tocContainer.contains(event.target);
        const isClickOnButton = toggleButton.contains(event.target);

        // If the click was *outside* both the panel and the button, close the ToC
        if (!isClickInsideToc && !isClickOnButton) {
            tocContainer.classList.remove('active');
            toggleButton.classList.remove('active');
        }
    });


    // Dynamically set top offset and max height (same logic as before)
    requestAnimationFrame(() => {
        const mainElement = document.querySelector('.main');
        let finalTopOffset = 20; // Default
        let finalMaxHeight = `calc(100vh - 40px)`; // Default

        if (mainElement) {
            const mainRect = mainElement.getBoundingClientRect();
            finalTopOffset = mainRect.top;
            if (finalTopOffset < 10) finalTopOffset = 10;
            finalMaxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`;
        }
        
        tocContainer.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
        tocContainer.style.setProperty('--toc-max-height', finalMaxHeight);
    });

    // Scroll click handler (same as before)
    document.querySelectorAll('#toc-container a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const href = this.getAttribute('href');
            if (!href || href.length <= 1 || !href.startsWith('#')) { return; }
            const targetId = href.substring(1);
            const targetElement = document.getElementById(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
                if (history.pushState) {
                    history.pushState(null, null, href);
                }
            }
        });
    });
});

