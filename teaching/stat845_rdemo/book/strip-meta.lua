-- clean-chapters.lua
-- Strip per-file YAML; remove the first H1; demote all other headings by 1.

local first_h1_removed = false

return {
  {
    -- 1) Remove per-file meta so only book-level settings apply
    Meta = function(meta)
      meta.title = nil
      meta.subtitle = nil
      meta.author = nil
      meta.date = nil
      meta["title-block-style"] = "none"  -- suppress any title block
      meta["include-in-header"] = nil
      meta["include-before-body"] = nil
      meta["include-after-body"] = nil
      return meta
    end,

    -- 2) Make chapter body headings subordinate to the book chapter title
    Header = function(h)
      if h.level == 1 then
        if not first_h1_removed then
          first_h1_removed = true
          return {}            -- drop the first H1 entirely (book will supply title)
        else
          h.level = 2          -- any other H1 becomes H2
          return h
        end
      else
        if h.level < 6 then    -- demote everything else by one
          h.level = h.level + 1
        end
        return h
      end
    end
  }
}
