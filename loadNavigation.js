// loadNavigation.js

/**
 * Normalizes a given path for comparison.
 * - Ensures it starts with a slash.
 * - Appends 'index.html' if it ends with a slash or is just '/'.
 * @param {string} path The path to normalize.
 * @returns {string} The normalized path.
 */
function normalizePath(path) {
    let normalized = path;
    // Ensure it starts with a slash (pathname usually does, but good for hrefs)
    if (!normalized.startsWith('/')) {
        normalized = '/' + normalized;
    }
    // If path ends with a slash, or is just the root slash, append index.html
    if (normalized.endsWith('/') || normalized === '/') {
        normalized = (normalized === '/' ? '/' : normalized) + 'index.html';
    }
    return normalized;
}

/**
 * Sets the active state on the navigation button corresponding to the current page.
 * Compares full normalized paths to correctly handle index.html in subfolders.
 */
function setActiveButton() {
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) {
        // console.warn("setActiveButton: Navigation placeholder not found.");
        return;
    }

    const normalizedCurrentPath = normalizePath(window.location.pathname);
    const navLinks = navPlaceholder.querySelectorAll('.nav-links a'); // Get all anchor tags within .nav-links

    navLinks.forEach(link => {
        const button = link.querySelector('button.btn'); // Get the button inside the anchor
        if (button) {
            button.classList.remove('active'); // Default to inactive

            const hrefAttribute = link.getAttribute('href');
            if (hrefAttribute) {
                // Skip external links, mailto, tel, and fragment-only links for active state
                if (hrefAttribute.startsWith('http') || 
                    hrefAttribute.startsWith('mailto:') || 
                    hrefAttribute.startsWith('tel:') || 
                    (hrefAttribute.startsWith('#') && hrefAttribute.length > 1)) {
                    return; // Continue to next link, do not mark as active
                }

                // Normalize the link's href value
                // This assumes internal navigation links in navigation.html are root-relative (e.g., "/about.html", "/products/")
                const normalizedHref = normalizePath(hrefAttribute);
                
                if (normalizedCurrentPath === normalizedHref) {
                    button.classList.add('active');
                }
            }
        }
    });
}

/**
 * Sets up the toggle functionality for the responsive hamburger menu.
 */
function setupResponsiveMenu() {
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) {
        // console.warn("setupResponsiveMenu: Navigation placeholder not found.");
        return;
    }

    const hamburgerButton = navPlaceholder.querySelector('.hamburger-menu');
    const navLinksList = navPlaceholder.querySelector('.nav-links');

    if (hamburgerButton && navLinksList) {
        hamburgerButton.addEventListener('click', () => {
            navLinksList.classList.toggle('active'); // Toggles visibility of nav links
            hamburgerButton.classList.toggle('active'); // For styling the hamburger icon
            
            // Update ARIA attribute for accessibility
            const isExpanded = navLinksList.classList.contains('active');
            hamburgerButton.setAttribute('aria-expanded', isExpanded.toString());
        });
    } else {
        // console.warn("setupResponsiveMenu: Hamburger button or nav links list not found.");
    }
}

/**
 * Main function to load navigation content when the DOM is ready.
 */
document.addEventListener("DOMContentLoaded", function() {
    // Ensure this path is root-relative if navigation.html is at the root
    const navigationFilePath = '/navigation.html'; 

    fetch(navigationFilePath)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status} for ${navigationFilePath}`);
            }
            return response.text();
        })
        .then(data => {
            const navPlaceholder = document.getElementById('navigation-placeholder');
            if (navPlaceholder) {
                navPlaceholder.innerHTML = data;
                setActiveButton();     // Set the active button state
                setupResponsiveMenu(); // Set up the hamburger menu functionality
            } else {
                console.error('Navigation placeholder (id="navigation-placeholder") not found in the HTML!');
            }
        })
        .catch(error => {
            console.error('Error loading navigation:', error);
            const navPlaceholder = document.getElementById('navigation-placeholder');
            if (navPlaceholder) {
                navPlaceholder.innerHTML = "<p style='color:red; text-align:center;'>Error loading navigation menu.</p>";
            }
        });
});