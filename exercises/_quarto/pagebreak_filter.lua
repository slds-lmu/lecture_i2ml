-- pagebreak_filter.lua
--
-- Avoids ugly page breaks in the PDF output of the exercise sheets by
-- requiring free vertical space (via \needspace, loaded in
-- pdf-preamble.tex) in front of blocks that must not be separated from
-- what follows them. Headings themselves are handled in
-- pdf-preamble.tex via LaTeX cmd hooks, because Quarto generates the
-- R/Python tab headings of flattened panel-tabsets only after the Lua
-- filters have run.
--
-- HTML output is not affected.

-- Is this Para/Plain the lone italic "Hint" / bold "Solution" label that
-- a <details><summary> block of the HTML version renders to in PDF?
local function is_hint_or_solution_label(block)
  if #block.content ~= 1 then
    return false
  end
  local inline = block.content[1]
  return (inline.t == "Emph" and pandoc.utils.stringify(inline):match("Hint"))
    or (inline.t == "Strong" and pandoc.utils.stringify(inline) == "Solution")
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
    local lines = nil
    if b.t == "Para" or b.t == "Plain" then
      -- next significant block, skipping raw HTML such as </summary>
      local nxt = nil
      for j = i + 1, #blocks do
        local c = blocks[j]
        if not (c.t == "RawBlock" and c.format:match("html")) then
          nxt = c
          break
        end
      end
      if is_hint_or_solution_label(b) then
        -- a code chunk or (opaque) tabset follows: room for the label plus
        -- the tab heading's own 14-line requirement; plain text follows:
        -- the label plus a few lines suffice
        if nxt and (nxt.t == "Div" or nxt.t == "CodeBlock") then
          lines = 16
        else
          lines = 6
        end
      elseif nxt and is_code_like(nxt) then
        local text = pandoc.utils.stringify(b)
        if #text > 0 and #text < 80 and not text:match("[%.%?!:]%s*$") then
          lines = 8
        end
      end
    end
    if lines then
      out:insert(pandoc.RawBlock("tex", "\\needspace{" .. lines .. "\\baselineskip}"))
    end
    out:insert(b)
  end
  return out
end
