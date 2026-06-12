-- colwidths.lua: column widths + tighter row spacing for .course-tables divs
local widths = {19.23, 7.69, 42.31, 7.69, 7.69, 7.69, 7.69}

function Div(div)
  if not div.classes:includes("course-tables") then
    return nil
  end

  -- 1) force column widths on the tables inside
  div.content = div.content:walk({
    Table = function(tbl)
      for i, cs in ipairs(tbl.colspecs) do
        if widths[i] then
          tbl.colspecs[i] = {cs[1], widths[i] / 100}
        end
      end
      return tbl
    end
  })

  -- 2) for Typst output, wrap content in a scoped block with tighter insets
  if quarto.doc.is_format("typst") then
    local blocks = pandoc.Blocks({})
    blocks:insert(pandoc.RawBlock("typst",
      "#[\n#set table(inset: (x: 5pt, y: 2.5pt))\n#set par(leading: 0.45em)"))
    blocks:extend(div.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    div.content = blocks
  end

  return div
end