// renderNavigation.js: A single script to create and manage the entire navigation bar.


// --- Main execution block ---
// This runs when the initial HTML document has been completely loaded and parsed.
document.addEventListener('DOMContentLoaded', function() {
    
    // The complete HTML content of your navigation bar is stored here as a string.
    const navigationHTML = `
        <nav class="responsive-nav">
            <div class="nav-brand">
                <img src="/images/usask-logo-lg.png" class="nav-logo" alt="UofS Logo">
                <a href="/index.html"><button class="btn">Prof. Longhai Li</button></a>
            </div>
            <button class="hamburger-menu menu-text-button" aria-label="Toggle menu" aria-expanded="false">
                Menu
            </button>
            <ul class="nav-links">
                <li><a href="/research.html"><button class="btn">Research Projects</button></a></li>
                <li><a href="/team.html"><button class="btn">Lab Members</button></a></li>
                <li><a href="/publications.html"><button class="btn">Publications</button></a></li>
                <li><a href="/teaching.html"><button class="btn">Courses</button></a></li>
                <li>
                    <form id="site-search-form" class="search-form" role="search">
                        <input id="search-query" type="search" class="search-input" placeholder="Search this site...">
                        <button type="submit" class="search-btn" aria-label="Search">
                            <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                        </button>
                    </form>
                </li>
            </ul>
        </nav>
    `;

    // Create a placeholder div, set its ID, and inject the navigation HTML.
    const navPlaceholder = document.createElement('div');
    navPlaceholder.id = 'navigation-placeholder';
    navPlaceholder.innerHTML = navigationHTML;

    // Insert the complete navigation bar at the very top of the body.
    document.body.prepend(navPlaceholder);

    // Call the function to set up all the event listeners and dynamic features.
    setupNavigation();
});


// This function contains all the logic for setting up the navigation bar's features.
function setupNavigation() {
    
    // --- Helper function to normalize paths for consistent comparison ---
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

    // --- Logic to set the page title ---
    function setPageTitleIfNotExists() {
        const siteTitles = {
            "/index.html": "Homepage of Professor Longhai Li",
            "/teaching.html": "Teaching Activities of Prof. Longhai Li",
            "/grant.html": "Research Activities of Prof. Longhai Li",
            "/team.html": "Members of Longhai Li's Research Lab",
            "/publications.html": "Publications of Prof. Longhai Li",
            "/software.html": "Software Released by Prof. Longhai Li",
            "/longhaishortcv.html": "Biography of Prof. Longhai Li",
            "/longhaicontacts.html": "Contact Information of Prof. Longhai Li"
        };
        const defaultSiteTitle = "Homepage of Professor Longhai Li";

        if (document.title && document.title.trim() !== "") {
            return; 
        }
        const normalizedCurrentPagePath = normalizePath(window.location.pathname);
        document.title = siteTitles[normalizedCurrentPagePath] || defaultSiteTitle;
    }

    // --- Logic to highlight the active button ---
    function setActiveButton() {
        const normalizedCurrentPath = normalizePath(window.location.pathname);
        const navLinks = document.querySelectorAll('#navigation-placeholder .nav-links a');
        navLinks.forEach(link => {
            const button = link.querySelector('button.btn');
            if (button) {
                button.classList.remove('active');
                const hrefAttribute = link.getAttribute('href');
                if (hrefAttribute && !hrefAttribute.startsWith('http') && !hrefAttribute.startsWith('mailto')) {
                    if (normalizedCurrentPath === normalizePath(hrefAttribute)) {
                        button.classList.add('active');
                    }
                }
            }
        });
    }

    // --- Logic for the responsive hamburger menu ---
    function setupResponsiveMenu() {
        const hamburgerButton = document.querySelector('#navigation-placeholder .hamburger-menu');
        const navLinksList = document.querySelector('#navigation-placeholder .nav-links');
        if (hamburgerButton && navLinksList) {
            hamburgerButton.addEventListener('click', () => {
                navLinksList.classList.toggle('active');
                hamburgerButton.classList.toggle('active');
                const isExpanded = navLinksList.classList.contains('active');
                hamburgerButton.setAttribute('aria-expanded', isExpanded.toString());
            });
        }
    }

    // --- Logic for the toggleable search form ---
    function activateSearchForm() {
        const searchForm = document.getElementById('site-search-form');
        const searchInput = document.getElementById('search-query');
        if (searchForm && searchInput) {
            searchForm.addEventListener('submit', function(event) {
                event.preventDefault();
                const isVisible = searchInput.classList.contains('active');
                if (isVisible) {
                    const query = searchInput.value.trim();
                    if (query) {
                        const encodedQuery = encodeURIComponent(query);
                        const searchUrl = `https://www.google.com/search?q=site:longhaisk.github.io+${encodedQuery}`;
                        window.open(searchUrl, '_blank');
                        searchInput.classList.remove('active');
                    } else {
                        searchInput.classList.remove('active');
                    }
                } else {
                    searchInput.classList.add('active');
                    searchInput.focus();
                }
            });
        }
    }

    // Run all setup functions
    setPageTitleIfNotExists();
    setActiveButton();
    setupResponsiveMenu();
    activateSearchForm();
}


