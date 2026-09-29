document.addEventListener("DOMContentLoaded", () => {
  // 1. Patterns of link text that are references/locators rather than
  // prose (URLs, email addresses, mailing addresses, ...). Truncating
  // these with an ellipsis loses no meaning, unlike truncating a
  // sentence or a title. Add more patterns here as needed.
  const patterns = [
    /^https?:\/\//i,                     // URLs with protocol
    /^www\./i,                           // URLs without protocol
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/,        // email addresses
    /\d+.*,.*,/,                         // mailing addresses (multiple comma-separated parts)
    /[A-Za-z]\d[A-Za-z]\s?\d[A-Za-z]\d/  // Canadian postal codes
  ];

  const links = document.querySelectorAll("a");

  links.forEach(link => {
    const text = link.textContent.trim();

    // 2. Only truncate links whose visible text matches one of the patterns
    if (!patterns.some(pattern => pattern.test(text))) return;

    // 3. Truncate to a single line with an ellipsis, without forcing
    // the link onto its own line. "-webkit-box" (used for multi-line
    // clamping) generates a block-level box, which is why the whole
    // URL used to drop to the next line instead of staying inline.
    Object.assign(link.style, {
      display: "inline-block",
      maxWidth: "100%",
      verticalAlign: "bottom",
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis"
    });
  });
});
