document.addEventListener("DOMContentLoaded", () => {
  // 1. Get all anchor tags on the page
  const links = document.querySelectorAll("a");

  links.forEach(link => {
    // 2. Truncate every link to a single line with an ellipsis, without
    // forcing the link onto its own line. "-webkit-box" (used for
    // multi-line clamping) generates a block-level box, which is why the
    // whole link text used to drop to the next line instead of staying
    // inline.
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