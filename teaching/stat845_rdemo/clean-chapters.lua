-- clean-chapters.lua
local first_h1_removed = false
local chapter_titles = nil
local input_rel = nil

-- helper: normalize path to use forward slashes
local function normpath(p)
  return (p or ""):gsub("\\", "/")
end

return {
  {
    Meta = function(meta)
      -- read the mapping from _quarto.yml (stored at top level as 'chapter-titles')
      if meta["chapter-titles"] then
        chapter_titles = {}
        for k, v in pairs(meta["chapter-titles"]) do
          chapter_titles[normpath(k)] = pandoc.utils.stringify(v)
        end
      else
        chapter_titles = {}
      end

      -- strip per-file meta so only our injected title shows
      meta.title = nil
      meta.subtitle = nil
      meta.author = nil
      meta.date = nil
      meta["title-block-style"] = "none"
      meta["include-in-header"] = nil
      meta["include-before-body"] = nil
      meta["include-after-body"] = nil

      return meta
    end,

    Pandoc = function(doc)
      -- determine the current input file path relative to the book dir
      -- Quarto exposes a single input file (the chapter); Pandoc keeps it in doc.meta['quarto-input-file']
      local qif = doc.meta["quarto-input-file"]
      if qif then
        input_rel = normpath(pandoc.utils.stringify(qif))
      else
        -- fallback: best-effort (may be empty with some versions)
        input_rel = normpath(PANDOC_STATE.input_files[1] or "")
      end

      -- inject the chapter title from the map, if present
      if chapter_titles and input_rel and chapter_titles[input_rel] then
        doc.meta.title = pandoc.MetaInlines({ pandoc.Str(chapter_titles[input_rel]) })
      end

      return doc
    end,

    Header = function(h)
      -- drop the first H1; demote everything else by one level
      if h.level == 1 then
        if not first_h1_removed then
          first_h1_removed = true
          return {}                      -- remove first H1 entirely
        else
          h.level = 2                    -- subsequent H1 -> H2
          return h
        end
      else
        if h.level < 6 then
          h.level = h.level + 1          -- Hk -> H(k+1)
        end
        return h
      end
    end
  }
}
