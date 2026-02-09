-- List of environments to handle
local envs = {
  'theorem', 
  'definition', 
  'example', 
  'proof', 
  'sol', 
  'solution', 
  'algorithm', 
  'remark'
}

function Div(div)
  -- Iterate through our list of environments
  for _, env in ipairs(envs) do
    if div.classes:includes(env) then
      
      -- Get the title from attributes (e.g. ::: {.theorem title="My Title"})
      local title = div.attributes['title']
      
      -- 1. If output is LaTeX (PDF)
      if FORMAT:match 'latex' then
        local blocks = pandoc.List()
        
        -- Construct the opening command
        local open_cmd = '\\begin{' .. env .. '}'
        if title then
          open_cmd = open_cmd .. '[' .. title .. ']'
        end
        
        blocks:insert(pandoc.RawBlock('latex', open_cmd))
        blocks:extend(div.content)
        blocks:insert(pandoc.RawBlock('latex', '\\end{' .. env .. '}'))
        return blocks

      -- 2. If output is Typst
      elseif FORMAT:match 'typst' then
        local blocks = pandoc.List()
        
        -- Construct the opening command
        -- Maps to #env(title: "Title")[ or #env[
        local open_cmd = '#' .. env
        if title then
          -- We need to quote the title for Typst
          open_cmd = open_cmd .. '(title: "' .. title .. '")['
        else
          open_cmd = open_cmd .. '['
        end
        
        blocks:insert(pandoc.RawBlock('typst', open_cmd))
        blocks:extend(div.content)
        blocks:insert(pandoc.RawBlock('typst', ']'))
        return blocks
      end
      
    end
  end
end
