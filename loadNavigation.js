// This script combines all navigation functionality into one file.

// --- START: Title and Active Button Logic ---

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
 * Activates the toggleable search form functionality.
 */
function activateSearchForm() {
    const searchForm = document.getElementById('site-search-form');
    const searchInput = document.getElementById('search-query');
    
    // Check if the form actually exists on the page to prevent errors
    if (searchForm && searchInput) {
        // Listen for the submit event, which is triggered by clicking the button or pressing Enter
        searchForm.addEventListener('submit', function(event) {
            // Always prevent the default form action (which is to reload the page)
            event.preventDefault();

            // Check if the search input is currently visible by looking for the 'active' class
            const isVisible = searchInput.classList.contains('active');

            if (isVisible) {
                // If the input is already visible, the user is trying to search.
                const query = searchInput.value.trim();

                if (query) {
                    // If there's text in the box, perform the search in a new tab.
                    const encodedQuery = encodeURIComponent(query);
                    const searchUrl = `https://www.google.com/search?q=site:longhaisk.github.io+${encodedQuery}`;
                    window.open(searchUrl, '_blank');
                    
                    // Hide the search bar again after the search is performed.
                    searchInput.classList.remove('active');

                } else {
                    // If the box is visible but empty, just hide it.
                    searchInput.classList.remove('active');
                }
            } else {
                // If the input is NOT visible, this is the first click. Show it.
                searchInput.classList.add('active');
                searchInput.focus(); // Automatically place the cursor in the input box.
            }
        });
    } else {
        console.error("Search form elements not found after loading navigation.html.");
    }
}


// --- END: Custom Logic Functions ---


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
            activateSearchForm(); // Activate the new toggleable search functionality
        })
        .catch(error => {
            console.error('Error fetching navigation:', error);
            navigationPlaceholder.innerHTML = '<p>Error loading navigation menu.</p>';
        });
});

