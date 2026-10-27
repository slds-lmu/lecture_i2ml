-- indent_filter.lua
--
-- The block types of the exercise sheets (EXERCISE_SPEC.md, §6):
--
--   ::: {.sol}     Solution of the preceding subtask. Kept only with the
--                  "solution" profile; collapsible in HTML (<details> with a
--                  "Solution" summary), labeled and marked by a vertical line
--                  on the left in PDF.
--   ::: {.indent}  Generated content of the preceding subtask: notebook embeds
--                  (Quarto inserts {{< embed >}} before Pandoc parses the
--                  document, without the shortcode's indentation, so an embed
--                  always ends a list item) and figure chunks (kept in the
--                  frame for the PDF page breaks), plus whatever of the
--                  subtask follows them.
--   ::: {.hint}    Hint, written where it belongs (inside a subtask: indented
--                  3 spaces like the subtask's other content). Collapsible in
--                  HTML, expanded in PDF, in both profiles. Label "Hint", or
--                  the label attribute: ::: {.hint label="Hint: Useful libraries"}
--
-- .sol and .indent start at the beginning of the line and are indented by one
-- list level: in HTML by styles.css, in PDF by the environments solution-block
-- and indent-block in pdf-preamble.tex. In PDF, the label of a solution or
-- hint is kept with the first lines of its content (needspace, loaded in
-- pdf-preamble.tex); pagebreak_filter.lua handles the other page breaks.

local function latex_env(div, env)
  return {
    pandoc.RawBlock("latex", "\\begin{" .. env .. "}"),
    div,
    pandoc.RawBlock("latex", "\\end{" .. env .. "}")
  }
end

-- first block from position i on, skipping raw HTML
local function next_significant(blocks, i)
  for j = i, #blocks do
    local c = blocks[j]
    if not (c.t == "RawBlock" and c.format:match("html")) then
      return c
    end
  end
  return nil
end

-- room for a label and the start of what follows it: a code chunk or any Div
-- (tabset, embed, callout) follows: the label plus a tab heading's own
-- 14-line requirement; plain text follows: the label plus a few lines suffice
local function label_lines(nxt)
  if nxt and (nxt.t == "Div" or nxt.t == "CodeBlock") then
    return 16
  end
  return 6
end

-- label, then content: in HTML as <details> with the label as <summary>; in
-- PDF the label is raw LaTeX, preceded by the request to keep it with the
-- first lines of the content. Strict \Needspace: it breaks only if the space
-- is really missing; \needspace would offer a cheap break in front of every
-- label, which LaTeX also takes on pages with room left.
local function collapsible(label, content)
  local blocks = pandoc.Blocks({})
  if FORMAT:match("latex") then
    local lines = label_lines(next_significant(content, 1))
    blocks:insert(pandoc.RawBlock("latex", "\\Needspace{" .. lines .. "\\baselineskip}"))
    blocks:insert(pandoc.RawBlock("latex", pandoc.write(pandoc.Pandoc({ pandoc.Plain({ label }) }), "latex")))
    blocks:extend(content)
    return blocks
  end
  blocks:insert(pandoc.RawBlock("html", "<details>\n<summary>"))
  blocks:insert(pandoc.Plain({ label }))
  blocks:insert(pandoc.RawBlock("html", "</summary>"))
  blocks:extend(content)
  blocks:insert(pandoc.RawBlock("html", "</details>"))
  return blocks
end

function Div(div)
  if div.classes:includes("sol") then
    -- Not ".solution" (Quarto reserves that class for proofs), and the
    -- profile is checked here: a content-visible div made by this filter
    -- would come too late, Quarto evaluates those before user filters.
    if not quarto.project.profile:includes("solution") then
      return {}
    end
    local blocks = collapsible(pandoc.Strong({ pandoc.Str("Solution") }), div.content)
    if FORMAT:match("latex") then
      -- the space request goes in front of the frame: inside the mdframed box
      -- a break right at the frame's start would leave the start of the
      -- vertical line alone at the bottom of a page
      local needspace = blocks:remove(1)
      div.content = blocks
      local env = latex_env(div, "solution-block")
      table.insert(env, 1, needspace)
      return env
    end
    div.content = blocks
    return div
  end
  if div.classes:includes("hint") then
    -- the label may contain Markdown (e.g. `code`); any input is safe here
    local label = pandoc.utils.blocks_to_inlines(pandoc.read(div.attributes.label or "Hint", "markdown").blocks)
    div.content = collapsible(pandoc.Emph(label), div.content)
    return div
  end
  if div.classes:includes("indent") and FORMAT:match("latex") then
    return latex_env(div, "indent-block")
  end
end
