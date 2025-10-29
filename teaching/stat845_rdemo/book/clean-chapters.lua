-- This filter does two things:
-- 1. Demotes all Level 1 Headers (#) to Level 2 Headers (##).
-- 2. Selectively nullifies the title-block YAML metadata (title, author, etc.)
--    of each chapter file, while preserving other metadata (like 'toc').

return {
  -- This function is applied to every Header element in the document
  Header = function (elem)
    -- Check if the header's level is 1
    if elem.level == 1 then
      -- If it is, change its level to 2
      elem.level = 2
      return elem
    end
    -- For all other header levels (2, 3, etc.),
    -- return them without modification.
    return elem
  end,

  -- This function is applied to the top-level Meta block (the YAML header)
  Meta = function (meta)
    -- The previous version (return pandoc.Meta({})) was too aggressive
    -- and removed ALL metadata, including 'toc: true' which is needed
    -- to render the table of contents on each page.
    
    -- This new version *selectively* removes only the metadata
    -- related to the title block, preserving everything else.
    meta.title = nil
    meta.subtitle = nil
    meta.author = nil
    meta.date = nil
    
    -- Return the *modified* metadata object
    return meta
  end
}

