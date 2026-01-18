function Div(el)
  if el.classes:includes("proof") then
    -- Create the callout structure
    local header = "Proof"
    
    -- If there's a header in the block, use it as the title
    if el.content[1] and el.content[1].t == "Header" then
      header = table.remove(el.content, 1).content
    end

    return quarto.Callout({
      type = "note",
      title = header,
      content = el.content,
      collapse = true,
      appearance = "simple",
      attributes = {class = "proof-callout"}
    })
  end
end
