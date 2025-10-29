-- strip-meta.lua : remove per-file title/author/date etc.
return {
  {
    Meta = function(meta)
      -- comment out any you want to keep
      meta.title  = nil
      meta.subtitle = nil
      meta.author = nil
      meta.date   = nil
      meta["include-in-header"] = nil
      meta["include-after-body"] = nil
      meta["include-before-body"] = nil
      -- If you also want to prevent Quarto from auto-promoting titles:
      meta["title-block-style"] = "none"
      return meta
    end
  }
}
