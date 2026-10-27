-- pagebreak_filter.lua
--
-- Avoids ugly page breaks in the PDF output of the exercise sheets by
-- requiring free vertical space (via \needspace, loaded in pdf-preamble.tex)
-- in front of blocks that must not be separated from what follows them.
-- Headings themselves are handled in pdf-preamble.tex via LaTeX cmd hooks,
-- because Quarto generates the R/Python tab headings of flattened
-- panel-tabsets only after the Lua filters have run. The labels of solutions
-- and hints are kept with their content by indent_filter.lua.
--
-- HTML output is not affected.

-- first block from position i on, skipping raw HTML such as </summary>
local function next_significant(blocks, i)
  for j = i, #blocks do
    local c = blocks[j]
    if not (c.t == "RawBlock" and c.format:match("html")) then
      return c
    end
  end
  return nil
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
    if b.t == "Para" or b.t == "Plain" then
      local nxt = next_significant(blocks, i + 1)
      local text = pandoc.utils.stringify(b)
      if nxt and is_code_like(nxt) and #text > 0 and #text < 80 and not text:match("[%.%?!:]%s*$") then
        out:insert(pandoc.RawBlock("tex", "\\needspace{8\\baselineskip}"))
      end
    end
    out:insert(b)
  end
  return out
end
