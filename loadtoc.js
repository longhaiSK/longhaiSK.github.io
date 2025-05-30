// loadtoc.js (Simplified)
document.addEventListener('DOMContentLoaded', function() {
    const tocContainer = document.createElement('nav');
    tocContainer.id = 'toc-container'; // CSS will target this ID for major styling
    tocContainer.classList.add('toc-sidebar'); // Additional class if needed

    const mainElement = document.querySelector('.main'); // Attempt to find the main content area
    if (!mainElement) {
        console.log('ToC: ".main" element not found for dynamic positioning, CSS fallback for top/max-height will be used.');
    }

    const tocTitle = document.createElement('h3');
    tocTitle.textContent = 'Table of Contents';
    tocTitle.classList.add('toc-title');
    tocContainer.appendChild(tocTitle);

    const tocList = document.createElement('ul');
    tocList.classList.add('toc-list');

    const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
        .filter(heading => !heading.closest('#toc-container') && !heading.closest('.no-toc'));

    if (headings.length === 0) {
        console.log("No relevant headings found on this page to generate a table of contents.");
    }

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

    if (tocList.children.length > 0) {
        tocContainer.appendChild(tocList);
        document.body.insertBefore(tocContainer, document.body.firstChild);

        requestAnimationFrame(() => {
            let finalTopOffset = 20; // Default top offset for CSS variable fallback
            let finalMaxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`; // Default max-height

            if (mainElement) {
                const mainRect = mainElement.getBoundingClientRect();
                finalTopOffset = mainRect.top;
                if (finalTopOffset < 10) finalTopOffset = 10; // Minimum top margin
                finalMaxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`; // 20px for a bottom gap
            }
            
            // Set CSS Custom Properties for dynamic positioning
            tocContainer.style.setProperty('--toc-top-offset', finalTopOffset + 'px');
            tocContainer.style.setProperty('--toc-max-height', finalMaxHeight);

            // Adjust body margin (this is a page layout adjustment, so keep in JS)
            const tocWidth = tocContainer.offsetWidth;
            const bodyComputedStyle = window.getComputedStyle(document.body);
            const bodyMarginProperty = bodyComputedStyle.direction === 'rtl' ? 'marginRight' : 'marginLeft';
            const currentBodyMargin = parseFloat(bodyComputedStyle[bodyMarginProperty]) || 0;

            if (currentBodyMargin < tocWidth + 20) {
                document.body.style[bodyMarginProperty] = `${tocWidth + 40}px`;
            }
        });
    } else {
        console.log("ToC: No list items generated, ToC will not be displayed.");
    }

    // Simplified Scroll Click Handler (relies on CSS for offset and smooth behavior)
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