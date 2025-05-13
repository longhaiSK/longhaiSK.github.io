// loadNavigation.js
document.addEventListener("DOMContentLoaded", function() {
    // Path to your navigation HTML file
    const navFile = '/navigation.html';

    fetch(navFile)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(data => {
            const navPlaceholder = document.getElementById('navigation-placeholder');
            if (navPlaceholder) {
                navPlaceholder.innerHTML = data;
                setActiveButton();
            } else {
                console.error('Navigation placeholder not found!');
            }
        })
        .catch(error => {
            console.error('Error loading navigation:', error);
            // Optionally, display a message to the user in the placeholder
            const navPlaceholder = document.getElementById('navigation-placeholder');
            if (navPlaceholder) {
                navPlaceholder.innerHTML = "<p>Error loading navigation menu.</p>";
            }
        });
});

function setActiveButton() {
    // Get the filename of the current page (e.g., "index.html")
    const path = window.location.pathname;
    const currentPage = path.substring(path.lastIndexOf('/') + 1) || 'index.html'; // Default to index.html if path is '/'

    // Get all navigation links from the loaded navigation
    const navPlaceholder = document.getElementById('navigation-placeholder');
    if (!navPlaceholder) return;

    const navLinks = navPlaceholder.querySelectorAll('.topnav a'); // Select links within the .topnav table

    navLinks.forEach(link => {
        const button = link.querySelector('button');
        if (button) {
            const linkHref = link.getAttribute('href');
            if (linkHref === currentPage) {
                button.classList.add('active');
                // Optional: If 'btn' class has styles you want to override or remove when active
                // button.classList.remove('btn');
            } else {
                button.classList.remove('active');
                // Ensure 'btn' class is present if it's not active and was potentially removed
                // if (!button.classList.contains('btn')) {
                //     button.classList.add('btn');
                // }
            }
        }
    });
}