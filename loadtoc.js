// loadtoc.js
document.addEventListener('DOMContentLoaded', function() {
    const tocContainer = document.createElement('nav');
    tocContainer.id = 'toc-container';
    tocContainer.classList.add('toc-sidebar');

    // Essential structural/positioning styles applied via JavaScript
    // These ensure basic functionality but can be overridden by more specific CSS
    // (e.g., using #toc-container or .toc-sidebar with !important in your mystyles.css if needed)
    tocContainer.style.position = 'fixed';
    tocContainer.style.left = '20px';    // Default left position
    tocContainer.style.width = '250px';  // Default width
    tocContainer.style.overflowY = 'auto';
    tocContainer.style.zIndex = '1000';  // To keep it on top of other content

    // --- Dynamic top and maxHeight setup ---
    // These will be calculated after the page layout is stable
    let topOffset = 20; // Default top offset if .main is not found or calculation fails
    const mainElement = document.querySelector('.main'); // Attempt to find the main content area

    if (!mainElement) {
        console.log('ToC: ".main" element not found for dynamic positioning, using default top: ' + topOffset + 'px.');
    }
    // Set initial/fallback values for top and maxHeight
    tocContainer.style.top = topOffset + 'px';
    tocContainer.style.maxHeight = `calc(100vh - ${topOffset}px - 20px)`; // 20px for a bottom gap

    const tocTitle = document.createElement('h3');
    tocTitle.textContent = 'Table of Contents';
    tocTitle.classList.add('toc-title');
    tocContainer.appendChild(tocTitle);

    const tocList = document.createElement('ul'); // This is the root UL for the ToC
    tocList.classList.add('toc-list');

    // Get all headings and filter out any within the ToC container itself or marked with .no-toc
    const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'))
        .filter(heading => !heading.closest('#toc-container') && !heading.closest('.no-toc'));

    if (headings.length === 0) {
        console.log("No relevant headings found on this page to generate a table of contents.");
        // Optionally, you could hide the tocContainer or not append it
        // For now, it just means tocList will be empty if no headings.
        // The final check 'if (tocList.children.length > 0)' will prevent an empty ToC from being added.
    }

    const levelStack = [tocList]; // Stack to keep track of current UL element for nesting

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
        link.title = heading.textContent.trim(); // Tooltip for longer titles
        listItem.appendChild(link);

        const headingLevel = parseInt(heading.tagName.substring(1));

        if (index === 0) {
            // First heading, its li is always added to the main tocList.
            // levelStack already contains tocList.
        } else {
            const previousHeadingLevel = parseInt(headings[index - 1].tagName.substring(1));

            if (headingLevel > previousHeadingLevel) {
                // Current heading is deeper: create a new nested list (ul)
                // This new ul should be a child of the *previous heading's list item (li)*.
                const parentListItem = levelStack[levelStack.length - 1].lastChild;
                if (parentListItem) {
                    const newSubList = document.createElement('ul');
                    newSubList.classList.add('toc-list', 'toc-sublist'); // Add both classes
                    parentListItem.appendChild(newSubList);
                    levelStack.push(newSubList); // New sublist becomes current list for deeper items
                }
            } else if (headingLevel < previousHeadingLevel) {
                // Current heading is shallower: pop from stack to find correct parent list
                let levelsToPop = previousHeadingLevel - headingLevel;
                for (let i = 0; i < levelsToPop; i++) {
                    if (levelStack.length > 1) { // Ensure we don't pop the main tocList
                        levelStack.pop();
                    } else {
                        break;
                    }
                }
            }
            // If headingLevel === previousHeadingLevel, stack depth remains the same.
        }
        // Add the current listItem to the list at the top of the stack.
        levelStack[levelStack.length - 1].appendChild(listItem);
    });

    // Only add the ToC to the page if it has actual list items.
    if (tocList.children.length > 0) {
        tocContainer.appendChild(tocList);
        document.body.insertBefore(tocContainer, document.body.firstChild);

        // Perform measurements and final positioning adjustments after ToC is in the DOM
        // and the main layout is likely stable.
        requestAnimationFrame(() => {
            let finalTopOffset = 20; // Default if .main isn't found or gives unusual values

            if (mainElement) {
                const mainRect = mainElement.getBoundingClientRect();
                // Use .main's top position relative to the viewport for the ToC's top
                finalTopOffset = mainRect.top;
                // Ensure topOffset is not negative (e.g. if .main is scrolled partially or fully above viewport)
                // and provide a sensible minimum if it's very small.
                if (finalTopOffset < 10) finalTopOffset = 10; // Minimum top margin
            }

            tocContainer.style.top = finalTopOffset + 'px';
            // Adjust maxHeight considering the final top position and a desired bottom gap (e.g., 20px)
            tocContainer.style.maxHeight = `calc(100vh - ${finalTopOffset}px - 20px)`;

            // Adjust body margin to prevent content overlap with the ToC sidebar
            const tocWidth = tocContainer.offsetWidth;
            const bodyComputedStyle = window.getComputedStyle(document.body);

            if (bodyComputedStyle.direction === 'rtl') {
                tocContainer.style.left = 'auto'; // Clear left if RTL
                tocContainer.style.right = '20px'; // Position on the right
                const currentMarginRight = parseFloat(bodyComputedStyle.marginRight) || 0;
                if (currentMarginRight < tocWidth + 20) { // 20px for some spacing next to ToC
                    document.body.style.marginRight = `${tocWidth + 40}px`; // ToC width + padding + spacing
                }
            } else { // LTR
                const currentMarginLeft = parseFloat(bodyComputedStyle.marginLeft) || 0;
                if (currentMarginLeft < tocWidth + 20) { // 20px for some spacing next to ToC
                    document.body.style.marginLeft = `${tocWidth + 40}px`; // ToC width + padding + spacing
                }
            }
        });
    } else {
        // If tocList is empty, tocContainer won't be added to the page.
        console.log("ToC: No list items generated, ToC will not be displayed.");
    }

    // Smooth scrolling for ToC links with offset for fixed headers
    document.querySelectorAll('#toc-container a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault(); // Prevent the default jump to manage history and use scrollIntoView

            const href = this.getAttribute('href');
            if (!href || href.length <= 1 || !href.startsWith('#')) {
                return; // Not a valid internal link
            }

            const targetId = href.substring(1);
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth', // Uses 'scroll-behavior' from CSS
                    block: 'start'      // Aligns the top of the target (respecting scroll-margin-top)
                                        // with the top of the visible area of the scroller.
                });

                // Optionally, update the URL hash in a way that doesn't create multiple history entries
                // if the link is clicked repeatedly.
                if (history.pushState) {
                    history.pushState(null, null, href);
                } else {
                    // Fallback for older browsers (though less critical if e.preventDefault() is used)
                    // location.hash = href; // This line might be omitted if scrollIntoView is enough
                                          // and you don't need immediate hash update for other scripts.
                                          // If you keep it, test its interaction.
                }
            }
        });
    });
});