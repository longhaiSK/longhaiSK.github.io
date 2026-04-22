// renderNavigation.js: A single script to create and manage the entire navigation bar.

function setupNavigation() {
    
    function normalizePath(path) {
        let normalized = path;
        if (!normalized.startsWith('/')) normalized = '/' + normalized;
        if (normalized.endsWith('/') || normalized === '/') {
            normalized = (normalized === '/' ? '/' : normalized) + 'index.html';
        }
        return normalized;
    }

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

    // --- NEW: Unified function to clip BOTH the mobile menu and the ToC ---
    function adjustHeightsForFooter() {
        const navLinksList = document.querySelector('#navigation-placeholder .nav-links');
        const tocContainer = document.getElementById('toc-container');
        const footer = document.querySelector('footer');
        const windowHeight = window.innerHeight;
        
        let footerTop = windowHeight; // Default to bottom of screen if no footer
        if (footer) {
            footerTop = footer.getBoundingClientRect().top;
        }

        // 1. Adjust Mobile Navigation Menu
        if (navLinksList && navLinksList.classList.contains('active')) {
            const navTop = navLinksList.getBoundingClientRect().top;
            if (footerTop < windowHeight) {
                navLinksList.style.maxHeight = `${footerTop - navTop}px`;
            } else {
                navLinksList.style.maxHeight = `${windowHeight - navTop}px`;
            }
        }

        // 2. Adjust Table of Contents (ToC)
        if (tocContainer) {
            const tocTop = tocContainer.getBoundingClientRect().top;
            if (footerTop < windowHeight) {
                // Footer is visible, stop ToC exactly where footer begins
                tocContainer.style.maxHeight = `${footerTop - tocTop}px`;
            } else {
                // Footer is off-screen, let ToC span the remaining window height
                tocContainer.style.maxHeight = `${windowHeight - tocTop}px`;
            }
        }
    }

    function setupResponsiveMenu() {
        const hamburgerButton = document.querySelector('#navigation-placeholder .hamburger-menu');
        const navLinksList = document.querySelector('#navigation-placeholder .nav-links');
        
        if (hamburgerButton && navLinksList) {
            hamburgerButton.addEventListener('click', (event) => {
                event.stopPropagation(); 
                navLinksList.classList.toggle('active');
                hamburgerButton.classList.toggle('active');
                
                if (navLinksList.classList.contains('active')) {
                    adjustHeightsForFooter();
                }
                
                const isExpanded = navLinksList.classList.contains('active');
                hamburgerButton.setAttribute('aria-expanded', isExpanded.toString());
            });

            // Adjust heights on scroll and resize for both Nav and ToC
            window.addEventListener('scroll', adjustHeightsForFooter, { passive: true });
            window.addEventListener('resize', adjustHeightsForFooter);

            document.addEventListener('click', function(event) {
                if (!navLinksList.classList.contains('active')) return;
                const isClickInsideMenu = navLinksList.contains(event.target);
                const isClickOnHamburger = hamburgerButton.contains(event.target);

                if (!isClickInsideMenu && !isClickOnHamburger) {
                    navLinksList.classList.remove('active');
                    hamburgerButton.classList.remove('active');
                    hamburgerButton.setAttribute('aria-expanded', 'false');
                    navLinksList.style.maxHeight = ''; // Reset
                }
            });
        }
        
        // Trigger initial ToC sizing on load
        setTimeout(adjustHeightsForFooter, 100);
    }

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

    setActiveButton();
    setupResponsiveMenu();
    activateSearchForm();
}

// --- Main execution block ---
document.addEventListener('DOMContentLoaded', function() {
    const navigationHTML = `
        <nav class="responsive-nav">
            <div class="nav-brand">
                <div class="nav-logo-container">
                     <img src="/resources/logo.png" class="nav-logo" alt="LOGO">
                </div>
                <button class="btn"><span class="nav-prof-name">Prof. Longhai Li</span></button>

            </div>
            <button class="hamburger-menu" aria-label="Toggle menu" aria-expanded="false">
             <span class="hamburger-bar"></span>
             <span class="hamburger-bar"></span>
             <span class="hamburger-bar"></span>
            </button>
            <ul class="nav-links">
                <li class="nav-li"><a href="/index.html"><button class="btn">About Me</button></a></li>
                <li class="nav-li"><a href="/research.html"><button class="btn">Research Projects</button></a></li>
                <li class="nav-li"><a href="/team.html"><button class="btn">Lab Members</button></a></li>
                <li class="nav-li"><a href="/publications.html"><button class="btn">Publications</button></a></li>
                <li class="nav-li"><a href="/teaching.html"><button class="btn">Courses</button></a></li>
                <li class="nav-li">
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

    const navPlaceholder = document.createElement('div');
    navPlaceholder.id = 'navigation-placeholder';
    navPlaceholder.innerHTML = navigationHTML;

    document.body.prepend(navPlaceholder);
    setupNavigation();
});
