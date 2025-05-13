// page_titles.js

const siteTitles = {
    "/index.html": "Homepage of Professor Longhai Li",
    "/teaching.html": "Teaching Activities of Prof. Longhai Li",
    "/grant.html": "Research Grants Held by Prof. Longhai Li",
    "/team.html": "Trainees Supervised by Longhai Li", // Your example title
    "/publications.html": "Publications of Prof. Longhai Li",
    "/software.html": "Software Released Prof. Longhai Li",
    // Add other pages and their titles here
    "/longhaishortcv.html": "Biography of Prof. Longhai Li",
    "/longhaicontacts.html": "Contact Information of Prof. Longhai Li"
};

// You can also define a default title for pages not listed or if something goes wrong
const defaultSiteTitle = "A Page of Homepage of Prof. Longhai Li";

function applyPageTitle() {
    const path = window.location.pathname;
    // Get the filename (e.g., "index.html", "teaching.html")
    // Handles cases where the URL might be just '/' for the root page.
    let currentPageFile = path.substring(path.lastIndexOf('/') + 1);
    if (currentPageFile === "" && path.endsWith("/")) { // Handles root path like http://localhost/
        currentPageFile = "index.html";
    } else if (currentPageFile === "") { // Handles cases like http://localhost/team (no .html but implies team.html)
        // This part might need adjustment based on your server setup if you use extensionless URLs.
        // For now, assuming .html extensions are used or it's the root.
        // If you use extensionless URLs server-side, you might need a more robust way to map paths to your keys.
    }


    if (siteTitles.hasOwnProperty(currentPageFile)) {
        document.title = siteTitles[currentPageFile];
    } else {
        // Fallback for pages not explicitly listed, or if currentPageFile is empty/unexpected
        console.warn(`Title not found for page: ${currentPageFile}. Using default title.`);
        document.title = defaultSiteTitle;
    }
}

// Apply the title as soon as the script runs.
// Using DOMContentLoaded is also an option if you need to wait for DOM elements, but for document.title, it can be set early.
applyPageTitle();
