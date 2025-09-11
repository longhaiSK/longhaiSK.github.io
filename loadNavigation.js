// This script combines all navigation functionality into one file.

// --- START: Title and Active Button Logic (from old script) ---

// User-provided site titles, specifically for root-level pages
const siteTitles = {
    "/index.html": "Homepage of Professor Longhai Li",
    "/teaching.html": "Teaching Activities of Prof. Longhai Li",
    "/grant.html": "Research Activities of Prof. Longhai Li",
    "/team.html": "Members Longhai Li's Research",
    "/publications.html": "Publications of Prof. Longhai Li",
    "/software.html": "Software Released by Prof. Longhai Li",
    "/longhaishortcv.html": "Biography of Prof. Longhai Li",
    "/longhaicontacts.html": "Contact Information of Prof. Longhai Li"
};
// User-provided default title
const defaultSiteTitle = "Prof. Longhai Li, University of Saskatchewan";

/**
 * Normalizes a path for consistent comparison.
 * @param {string} path The path to normalize.
 * @returns {string} The normalized path (e.g., '/about.html').
 */
function normalizePath(path) {
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
 * Sets the document title based on the current page, if not already set.
 */
function setPageTitleIfNotExists() {
    if (document.title && document.title.trim() !== "") {
        return; // A title exists, do nothing
    }
    const normalizedCurrentPagePath = normalizePath(window.location.pathname);
    if (siteTitles.hasOwnProperty(normalizedCurrentPagePath)) {
        document.title = siteTitles[normalizedCurrentPagePath];
    } else {
        document.title = defaultSiteTitle;
    }
}

/**
 * Sets the active state on the navigation button corresponding to the current page.
 */
function setActiveButton() {
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) return;

    const normalizedCurrentPath = normalizePath(window.location.pathname);
    const navLinks = navPlaceholder.querySelectorAll('.nav-links a');

    navLinks.forEach(link => {
        const button = link.querySelector('button.btn');
        if (button) {
            button.classList.remove('active');
            const hrefAttribute = link.getAttribute('href');
            if (hrefAttribute && !hrefAttribute.startsWith('http') && !hrefAttribute.startsWith('mailto')) {
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
    if (!navPlaceholder) return;

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
 * Activates the search form functionality.
 */
function activateSearchForm() {
    const searchForm = document.getElementById('site-search-form');
    const searchInput = document.getElementById('search-query');

    if (searchForm && searchInput) {
        searchForm.addEventListener('submit', function(event) {
            event.preventDefault();
            const query = searchInput.value;
            if (!query) return;

            const encodedQuery = encodeURIComponent(query);
            const searchUrl = `https://www.google.com/search?q=site:longhaisk.github.io+${encodedQuery}`;
            window.open(searchUrl, '_blank');
        });
    } else {
        console.error("Search form elements not found after loading nav.html.");
    }
}


// --- END: Logic from old script ---


/**
 * Main function to load navigation and set up all related functionality.
 */
document.addEventListener('DOMContentLoaded', function() {
    // Set the page title first, as it doesn't depend on the nav HTML
    setPageTitleIfNotExists();

    const navigationPlaceholder = document.getElementById('navigation-placeholder');
    if (!navigationPlaceholder) {
        console.error('Fatal: Navigation placeholder (id="navigation-placeholder") not found in the HTML!');
        return;
    }

    // Fetch the navigation HTML from the navigation.html file
    fetch('/navigation.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(html => {
            // Inject the fetched HTML into the placeholder div
            navigationPlaceholder.innerHTML = html;

            // Now that the navigation is loaded, run all the setup functions
            setActiveButton();
            setupResponsiveMenu();
            activateSearchForm(); // Activate the new search functionality
        })
        .catch(error => {
            console.error('Error fetching navigation:', error);
            navigationPlaceholder.innerHTML = '<p>Error loading navigation menu.</p>';
        });
});

