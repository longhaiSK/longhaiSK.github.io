-- Quarto Lua filter to demote all headers by one level.
-- This will change # to ##, ## to ###, and so on.

function Header(el)
  -- Increase the level of the header by 1
  el.level = el.level + 1
  return el
end

