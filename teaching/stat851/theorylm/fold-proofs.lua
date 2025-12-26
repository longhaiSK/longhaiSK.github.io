function Div(div)
  -- Only affect HTML output
  if not quarto.doc.is_format("html") then
    return nil
  end

  -- Detect if it is a proof or solution
  local is_proof = div.classes:includes("proof")
  local is_solution = div.classes:includes("solution")

  if is_proof or is_solution then
    -- 1. Determine Title
    local label = is_solution and "Solution" or "Proof"
    if div.attributes["name"] then
      label = label .. " (" .. div.attributes["name"] .. ")"
    end

    -- 2. Remove the original class so Quarto doesn't double-label it
    -- We replace it with a custom class we can style if needed
    div.classes = pandoc.List()
    div.classes:insert("folded-environment")

    -- 3. Wrap content in <details>
    -- Create the summary button
    local summary_html = "<summary style='cursor:pointer; font-weight:bold; font-style:italic;'>" .. label .. ".</summary>"
    local summary_block = pandoc.RawBlock("html", summary_html)
    
    local details_open = pandoc.RawBlock("html", "<details>")
    local details_close = pandoc.RawBlock("html", "</details>")

    -- Insert tags around the content
    table.insert(div.content, 1, details_open)
    table.insert(div.content, 2, summary_block)
    table.insert(div.content, details_close)

    return div
  end
end