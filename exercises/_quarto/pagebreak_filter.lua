-- pagebreak_filter.lua
--
-- Avoids ugly page breaks in the PDF output of the exercise sheets:
-- a heading (e.g. "Exercise 2: ...") must not sit orphaned in the last
-- lines of a page. Before every heading of level >= 2 we require a
-- minimum amount of free vertical space via \needspace (loaded in
-- pdf-preamble.tex); otherwise the page breaks before the heading.
-- Exercise headings (level 2) are usually followed by a learning-goals
-- callout box, so they need enough room for the heading plus the start
-- of that box.
--
-- HTML output is not affected.

function Header(h)
  if FORMAT:match 'latex' and h.level >= 2 then
    local lines = h.level == 2 and 10 or 6
    return {
      pandoc.RawBlock("tex", "\\needspace{" .. lines .. "\\baselineskip}"),
      h
    }
  end
end

-- The <details><summary>*Hint*</summary> and <summary>**Solution**</summary>
-- blocks of the HTML version render as a lone italic "Hint" / bold "Solution"
-- paragraph in PDF (Para at top level, Plain inside list items); keep that
-- label together with the first lines of its content, which is often a
-- flattened R/Python tabset heading or a code block.
local function needspace_before_label(block)
  if FORMAT:match 'latex' and #block.content == 1 then
    local inline = block.content[1]
    local is_hint = inline.t == "Emph"
      and pandoc.utils.stringify(inline):match("Hint")
    local is_solution = inline.t == "Strong"
      and pandoc.utils.stringify(inline) == "Solution"
    if is_hint or is_solution then
      return {
        pandoc.RawBlock("tex", "\\needspace{8\\baselineskip}"),
        block
      }
    end
  end
end

function Para(p)
  return needspace_before_label(p)
end

function Plain(p)
  return needspace_before_label(p)
end
