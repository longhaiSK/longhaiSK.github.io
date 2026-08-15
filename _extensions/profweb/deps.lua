function Pandoc(doc)
  quarto.doc.add_html_dependency({
    name = "profweb",
    version = "1.0.0",
    scripts = {"rendernav.js", "loadtoc.js"},
    stylesheets = {"mystyles.css", "iconstyles.css"},
    resources = {"logo.png"},
    links = {
      { href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css", rel = "stylesheet" },
      { href = "https://cdn.jsdelivr.net/gh/jpswalsh/academicons@1/css/academicons.min.css", rel = "stylesheet" }
    }
  })
  return doc
end
