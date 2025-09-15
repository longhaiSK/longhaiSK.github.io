// loadtoc.js (Modified for a custom ToC Icon Button)
document.addEventListener('DOMContentLoaded', function() {
    const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
        .filter(heading => !heading.closest('#toc-container') && !heading.closest('.no-toc'));

    if (headings.length === 0) {
        console.log("ToC: No headings found, ToC will not be generated.");
        return;
    }

    const tocContainer = document.createElement('nav');
    tocContainer.id = 'toc-container';

    const toggleButton = document.createElement('button');
    toggleButton.id = 'toc-toggle-button';
    toggleButton.setAttribute('aria-label', 'Toggle Table of Contents');
    
    // SVG for the hierarchical list icon
    toggleButton.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="9" y1="6" x2="20" y2="6"></line>
        <line x1="9" y1="12" x2="20" y2="12"></line>
        <line x1="9" y1="18" x2="20" y2="18"></line>
        <circle cx="5" cy="6" r="1"></circle>
        <circle cx="5" cy="12" r="1"></circle>
        <circle cx="5" cy="18" r="1"></circle>
    </svg>`;

    const tocTitle = document.createElement('h3');
    tocTitle.textContent = 'Table of Contents';
    tocTitle.classList.add('toc-title');
    tocContainer.appendChild(tocTitle);

    const tocList = document.createElement('ul');
    tocList.classList.add('toc-list');

    const levelStack = [tocList];

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

    tocContainer.appendChild(tocList);
    document.body.appendChild(tocContainer);
    document.body.appendChild(toggleButton);

    toggleButton.addEventListener('click', () => {
        tocContainer.classList.toggle('active');
        toggleButton.classList.toggle('active');
    });

    document.addEventListener('click', function(event) {
        const isTocActive = tocContainer.classList.contains('active');
        if (!isTocActive) {
            return;
        }
        const isClickInsideToc = tocContainer.contains(event.target);
        const isClickOnButton = toggleButton.contains(event.target);
        if (!isClickInsideToc && !isClickOnButton) {
            tocContainer.classList.remove('active');
            toggleButton.classList.remove('active');
        }
    });

    // This part dynamically sets the top position to match your nav bar's height.
    requestAnimationFrame(() => {
        const navBar = document.querySelector('.responsive-nav');
        let navBarHeight = 60; // Default height if nav bar isn't found
        if (navBar) {
            navBarHeight = navBar.offsetHeight;
        }
        
        const finalTopOffset = navBarHeight;
        const finalMaxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`;
        
        // Use CSS variables to position the elements, matching the CSS file.
        tocContainer.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
        tocContainer.style.setProperty('--toc-max-height', finalMaxHeight);
        toggleButton.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
    });

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

