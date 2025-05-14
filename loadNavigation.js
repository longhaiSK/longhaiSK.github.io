// loadNavigation.js

// --- START: Title Setting Logic (Integrated) ---
// User-provided site titles, specifically for root-level pages
const siteTitles = {
    "/index.html": "Homepage of Professor Longhai Li",
    "/teaching.html": "Teaching Activities of Prof. Longhai Li",
    "/grant.html": "Research Activities of Prof. Longhai Li",
    "/team.html": "Trainees Supervised by Longhai Li",
    "/publications.html": "Publications of Prof. Longhai Li",
    "/software.html": "Software Released by Prof. Longhai Li",
    "/longhaishortcv.html": "Biography of Prof. Longhai Li",
    "/longhaicontacts.html": "Contact Information of Prof. Longhai Li"
};
// User-provided default title
const defaultSiteTitle = "";

/**
 * Normalizes a given path for comparison. (Helper function also used by setActiveButton)
 * - Ensures it starts with a slash.
 * - Appends 'index.html' if it ends with a slash or is just '/'.
 * @param {string} path The path to normalize.
 * @returns {string} The normalized path.
 */
function normalizePathForTitles(path) { // Renamed to avoid conflict if normalizePath has different needs elsewhere, though it's similar
    let normalized = path;
    // Ensure it starts with a slash
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
 * Sets the document title based on the current page,
 * but only if a title hasn't already been set by the HTML,
 * and only for specified root-level pages.
 */
function setPageTitleIfNotExists() {
    // Check if the HTML already provided a non-empty title
    if (document.title && document.title.trim() !== "") {
        // console.log("HTML title ('" + document.title + "') will be preserved.");
        return; // A title exists and is not empty, so do nothing
    }

    // Use the normalized full path of the current page for lookup
    const normalizedCurrentPagePath = normalizePathForTitles(window.location.pathname);

    if (siteTitles.hasOwnProperty(normalizedCurrentPagePath)) {
        document.title = siteTitles[normalizedCurrentPagePath];
        // console.log("JS set title to: " + document.title + " for path: " + normalizedCurrentPagePath);
    } else {
        // If the current path is not in siteTitles, use the default title.
        // This means even non-root pages without an HTML title will get the default.
        // console.warn(`Title not found in siteTitles for page path: ${normalizedCurrentPagePath}. Using default title.`);
        document.title = defaultSiteTitle;
        // console.log("JS set title to DEFAULT: " + document.title);
    }
}
// --- END: Title Setting Logic ---


/**
 * Normalizes a given path for comparison for active buttons.
 * - Ensures it starts with a slash.
 * - Appends 'index.html' if it ends with a slash or is just '/'.
 * @param {string} path The path to normalize.
 * @returns {string} The normalized path.
 */
function normalizePath(path) { // This is the original normalizePath for setActiveButton
    let normalized = path;
    if (!normalized.startsWith('/')) {
        normalized = '/' + normalized;
    }
    if (normalized.endsWith('/') || normalized === '/') {
        normalized = (normalized === '/' ? '/' : normalized) + 'index.html';
    }
    return normalized;
}

/**
 * Sets the active state on the navigation button corresponding to the current page.
 */
function setActiveButton() {
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) {
        return;
    }

    const normalizedCurrentPath = normalizePath(window.location.pathname); // Uses the original normalizePath
    const navLinks = navPlaceholder.querySelectorAll('.nav-links a');

    navLinks.forEach(link => {
        const button = link.querySelector('button.btn');
        if (button) {
            button.classList.remove('active'); // Default to inactive
            const hrefAttribute = link.getAttribute('href');
            if (hrefAttribute) {
                if (hrefAttribute.startsWith('http') || 
                    hrefAttribute.startsWith('mailto:') || 
                    hrefAttribute.startsWith('tel:') || 
                    (hrefAttribute.startsWith('#') && hrefAttribute.length > 1)) {
                    return; 
                }
                const normalizedHref = normalizePath(hrefAttribute); // Uses the original normalizePath
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
        return;
    }
    const hamburgerButton = navPlaceholder.querySelector('.hamburger-menu');
    const navLinksList = navPlaceholder.querySelector('.nav-links');
    if (hamburgerButton && navLinksList) {
        hamburgerButton.addEventListener('click', () => {
            navLinksList.classList.toggle('active');
            hamburgerButton.classList.toggle('active');
            const isExpanded = navLinksList.classList.contains('active');
            hamburgerButton.setAttribute('aria-expanded', isExpanded.toString());
        });
    }
}

/**
 * Main function to load navigation content and set up page elements when the DOM is ready.
 */
document.addEventListener("DOMContentLoaded", function() {
    setPageTitleIfNotExists(); 

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
                setActiveButton();
                setupResponsiveMenu();
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
