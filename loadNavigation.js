// loadNavigation.js

/**
 * Sets the active state on the navigation button corresponding to the current page.
 */
function setActiveButton() {
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) {
        // console.warn("setActiveButton: Navigation placeholder not found.");
        return;
    }

    const currentPath = window.location.pathname;
    let currentPageFile = currentPath.substring(currentPath.lastIndexOf('/') + 1);

    // If the path is just "/" or ends with "/", consider it index.html
    if (currentPageFile === "" && (currentPath === "/" || currentPath.endsWith("/"))) {
        currentPageFile = "index.html";
    }
    // If still empty, it might be a root path without a filename, default to index.html
    if (currentPageFile === "") {
        currentPageFile = "index.html";
    }

    const navLinks = navPlaceholder.querySelectorAll('.nav-links a'); // Get all anchor tags within .nav-links

    navLinks.forEach(link => {
        const button = link.querySelector('button.btn'); // Get the button inside the anchor
        if (button) {
            const hrefValue = link.getAttribute('href');
            let linkPageFile = "";

            if (hrefValue) {
                linkPageFile = hrefValue.substring(hrefValue.lastIndexOf('/') + 1);
                // If the href is just "/" or ends with "/", consider it index.html
                if (linkPageFile === "" && (hrefValue === "/" || hrefValue.endsWith("/"))) {
                    linkPageFile = "index.html";
                }
                // If still empty (e.g. href was just a directory name without trailing slash),
                // this might need more complex logic based on server config.
                // For now, we assume simple filenames or / for index.html.
            }

            if (linkPageFile === currentPageFile) {
                button.classList.add('active');
            } else {
                button.classList.remove('active');
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
            hamburgerButton.classList.toggle('active'); // For styling the hamburger icon (e.g., to an "X")
            
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
    // Adjust this path if your navigation.html file is located elsewhere
    const navigationFilePath = 'navigation.html'; 
    // If navigation.html is in the root like other scripts, use:
    // const navigationFilePath = '/navigation.html'; 

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
            // Optionally, display an error message in the placeholder
            if (navPlaceholder) {
                navPlaceholder.innerHTML = "<p style='color:red; text-align:center;'>Error loading navigation menu.</p>";
            }
        });
});
