function Div(div)
  -- Check if the div has the class 'sol'
  if div.classes:includes('sol') then
    
    -- 1. If output is LaTeX (PDF)
    if FORMAT:match 'latex' then
      local blocks = pandoc.List()
      blocks:insert(pandoc.RawBlock('latex', '\\begin{sol}'))
      blocks:extend(div.content)
      blocks:insert(pandoc.RawBlock('latex', '\\end{sol}'))
      return blocks

    -- 2. If output is Typst
    elseif FORMAT:match 'typst' then
      local blocks = pandoc.List()
      blocks:insert(pandoc.RawBlock('typst', '#sol['))
      blocks:extend(div.content)
      blocks:insert(pandoc.RawBlock('typst', ']'))
      return blocks
    end
    
  end
end
