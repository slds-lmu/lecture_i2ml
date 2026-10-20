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

-- Pandoc writes pipe tables as longtable, which breaks between any two
-- rows; require enough space for the whole table so small tables (the
-- typical hand-computation tables of the sheets) stay on one page.
function Table(t)
  if FORMAT:match 'latex' then
    local nrows = 0
    for _, body in ipairs(t.bodies) do
      nrows = nrows + #body.body
    end
    if nrows <= 10 then
      return {
        pandoc.RawBlock("tex", "\\needspace{" .. (nrows + 5) .. "\\baselineskip}"),
        t
      }
    end
  end
end

-- A short caption-like line directly above a code chunk ("Inspect",
-- "Get data", "Train and evaluate", ...) belongs to that chunk: request
-- the space in front of the label, not just in front of the code block
-- (the Shaded hook in pdf-preamble.tex alone would orphan the label).
local function is_code_like(block)
  return block.t == "CodeBlock"
    or (block.t == "Div"
        and (block.classes:includes("cell")
             or block.classes:includes("quarto-embed-nb-cell")))
end

function Blocks(blocks)
  if not FORMAT:match 'latex' then
    return nil
  end
  local out = pandoc.List()
  for i, b in ipairs(blocks) do
    local nxt = blocks[i + 1]
    if nxt and is_code_like(nxt) and (b.t == "Para" or b.t == "Plain") then
      local text = pandoc.utils.stringify(b)
      if #text > 0 and #text < 80 and not text:match("[%.%?!:]%s*$") then
        out:insert(pandoc.RawBlock("tex", "\\needspace{8\\baselineskip}"))
      end
    end
    out:insert(b)
  end
  return out
end
