-- Pulls a leading manual number ("1.", "12.", "9.1", ...) out of a heading's
-- text and re-emits it as <span class="header-num">, so CSS can hang wrapped
-- heading text under the text instead of under the number (see mystyles.css).

function Header(el)
  if el.level ~= 2 and el.level ~= 3 then return el end

  local first = el.content[1]
  if not first or first.t ~= "Str" then return el end

  local num = first.text:match("^(%d+%.[%d%.]*)$")
  if not num then return el end

  local content = { pandoc.Span({ pandoc.Str(num) }, pandoc.Attr("", { "header-num" })) }
  for i = 2, #el.content do
    table.insert(content, el.content[i])
  end

  el.content = content
  return el
end
