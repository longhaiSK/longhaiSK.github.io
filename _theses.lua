-- _theses.lua: builds a "theses supervised" list from a supervision section.
--
-- Usage in a .qmd:
--   ::: {#theses-supervised source="graduate-student-supervision"}
--   :::
--
-- Every numbered entry in the section whose heading id is `source` and that has
-- a "**Thesis:** [title](url)" sub-bullet becomes one item, e.g.
--   **Wutao Yin**, Ph.D., ..., (Defended: Dec. 17, 2021)
--       * **Thesis:** [AI Based Methods ...](https://...)
-- becomes
--   Wutao Yin, 2021, [AI Based Methods ...](https://...), Ph.D., defended on Dec. 17, 2021.
-- Items are sorted newest first, grouped under "**2021-2022**" year headings,
-- and numbered as one countdown across the groups (17, 16, ..., 1).

local months = {jan = 1, feb = 2, mar = 3, apr = 4, may = 5, jun = 6,
                jul = 7, aug = 8, sep = 9, oct = 10, nov = 11, dec = 12}

local function parse_date(s)
  local mon, day, year = s:match("^(%a+)%.?%s+(%d+),%s*(%d%d%d%d)$")
  if not mon then mon, year = s:match("^(%a+)%.?%s+(%d%d%d%d)$") end
  if not mon then return nil end
  local m = months[mon:sub(1, 3):lower()] or 0
  return {year = tonumber(year), has_day = day ~= nil,
          key = tonumber(year) * 10000 + m * 100 + tonumber(day or 0)}
end

-- The link inside a "**Thesis:** ..." sub-bullet of a list item, if any.
local function thesis_link(item)
  for _, b in ipairs(item) do
    if b.t == "BulletList" then
      for _, sub in ipairs(b.content) do
        local first = sub[1]
        if first and first.content and first.content[1]
           and first.content[1].t == "Strong"
           and pandoc.utils.stringify(first.content[1]) == "Thesis:" then
          local link
          first:walk({Link = function(l) link = link or l end})
          return link
        end
      end
    end
  end
end

local function collect(blocks, source)
  local theses, inside, level = {}, false, nil
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.identifier == source then
        inside, level = true, b.level
      elseif inside and b.level <= level then
        break
      end
    elseif inside and b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        local para, link = item[1], thesis_link(item)
        if link and (para.t == "Para" or para.t == "Plain")
           and para.content[1] and para.content[1].t == "Strong" then
          -- Pandoc puts non-breaking spaces after abbreviations like "Dec."
          local text = pandoc.utils.stringify(para):gsub("\194\160", " ")
          local degree = text:match("^[^,]+,%s*([^,]+),")
          local datestr = text:match("Defended:%s*([^%)]+)%)")
          local date = datestr and parse_date(datestr)
          if degree and date then
            table.insert(theses, {name = para.content[1].content, link = link,
                                  degree = degree, datestr = datestr, date = date,
                                  order = #theses})
          else
            io.stderr:write("theses.lua: skipped entry (no degree or defence date): "
                            .. text .. "\n")
          end
        end
      end
    end
  end
  table.sort(theses, function(a, b)
    if a.date.key ~= b.date.key then return a.date.key > b.date.key end
    return a.order < b.order
  end)
  return theses
end

local function build(theses)
  local blocks, total, year = pandoc.Blocks({}), #theses, nil
  for i, t in ipairs(theses) do
    if t.date.year ~= year then
      year = t.date.year
      blocks:insert(pandoc.Para({pandoc.Strong({pandoc.Str(year .. "-" .. (year + 1))})}))
    end
    local inlines = pandoc.Inlines({})
    inlines:extend(t.name)
    inlines:insert(pandoc.Str(", " .. t.date.year .. ", "))
    inlines:insert(t.link)
    -- keep "Dec." and "17" on one line, as Pandoc does for the hand-typed text
    local datestr = t.datestr:gsub("(%a%.) ", "%1\194\160")
    inlines:insert(pandoc.Str(", " .. t.degree .. ", defended "
                              .. (t.date.has_day and "on " or "in ") .. datestr .. "."))
    -- one single-item list per thesis, like ritem(), so numbers count down
    -- (an ordered list always counts up from its start)
    blocks:insert(pandoc.OrderedList({{pandoc.Para(inlines)}},
                                     pandoc.ListAttributes(total - i + 1, "Decimal", "Period")))
  end
  return blocks
end

function Pandoc(doc)
  local found = false
  doc.blocks = doc.blocks:walk({
    Div = function(div)
      if div.identifier ~= "theses-supervised" then return nil end
      found = true
      local source = div.attributes.source or "graduate-student-supervision"
      return build(collect(doc.blocks, source))
    end
  })
  if found then return doc end
end
