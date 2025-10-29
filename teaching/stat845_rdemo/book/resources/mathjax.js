// mathjax.js

// Your MathJax Configuration
window.MathJax = {
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']], // Delimiters for inline math
    displayMath: [['$$', '$$'], ['\\[', '\\]']] // Delimiters for display math
  },
  svg: {
    fontCache: 'global' // Improve rendering performance
  }
};

// Dynamically load the MathJax library
(function () {
  var script = document.createElement('script');
  script.id = 'MathJax-script';
  script.async = true;
  script.src = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js';
  document.head.appendChild(script);
})();
