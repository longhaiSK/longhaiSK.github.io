document.addEventListener("DOMContentLoaded", () => {
  const BREAKPOINT = 600; // px: screens narrower than this hide the profile photo
  const imgCol = document.querySelector(".profile-img-col");
  const textCol = document.querySelector(".profile-text-col");
  if (!imgCol) return;

  // Capture the original inline width (set by Quarto from {width="80%"})
  // before we touch it, so we can restore it exactly rather than clearing
  // it to "" — an empty value falls back to Bootstrap's competing
  // `div.column { width: 50% }` rule instead of the intended 80%.
  const originalTextWidth = textCol ? textCol.style.width : null;

  function applyLayout() {
    const isSmall = window.innerWidth <= BREAKPOINT;
    imgCol.style.display = isSmall ? "none" : "";
    if (textCol) textCol.style.width = isSmall ? "100%" : originalTextWidth;
  }

  applyLayout();

  // Debounce so resize dragging doesn't thrash layout on every pixel
  let resizeTimer;
  window.addEventListener("resize", () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(applyLayout, 150);
  });
});
