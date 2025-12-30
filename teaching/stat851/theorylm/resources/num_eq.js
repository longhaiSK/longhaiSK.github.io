window.MathJax = {
  tex: {
    tags: 'all',  // 1. Force numbering ON immediately
    packages: {'[+]': ['tagformat']} // 2. Request the formatting package
  },
  loader: {
    load: ['[tex]/tagformat'] // 3. Load the package
  },
  startup: {
    ready: () => {
      // 4. Safely configure the chapter prefix logic
      const tex = MathJax.config.tex;
      tex.tagformat = {
        number: function (n) {
          // Find the section number in the HTML
          var section = document.querySelector('.header-section-number');
          // Extract the main chapter number (e.g., "2" from "2.1")
          var block = section ? section.textContent.split('.')[0] : '';
          // Return "2.1" if chapter exists, otherwise just "1"
          return block ? block + '.' + n : n;
        }
      };
      // 5. Run MathJax startup
      MathJax.startup.defaultReady();
    }
  }
};