-- indent_filter.lua
--
-- This Lua filter is used by Pandoc/Quarto to customize the rendering of specific Div blocks.
-- It intercepts Divs with classes like 'indent-1', 'indent-1-sol', etc.
--
-- When rendering to LaTeX (PDF), it wraps these blocks in the corresponding LaTeX environments
-- defined in 'pdf-preamble.tex' (e.g., \begin{indent-1} ... \end{indent-1}).
-- This allows us to apply specific LaTeX styling (like vertical lines) that isn't possible
-- with standard Markdown-to-LaTeX conversion.

function Div(div)
  if div.classes:includes("indent-1") then
    if FORMAT:match 'latex' then
      return {
        pandoc.RawBlock("tex", "\\begin{indent-1}"),
        div,
        pandoc.RawBlock("tex", "\\end{indent-1}")
      }
    end
  elseif div.classes:includes("indent-2") then
    if FORMAT:match 'latex' then
      return {
        pandoc.RawBlock("tex", "\\begin{indent-2}"),
        div,
        pandoc.RawBlock("tex", "\\end{indent-2}")
      }
    end
  elseif div.classes:includes("indent-1-sol") then
    if FORMAT:match 'latex' then
      return {
        pandoc.RawBlock("tex", "\\begin{indent-1-sol}"),
        div,
        pandoc.RawBlock("tex", "\\end{indent-1-sol}")
      }
    end
  elseif div.classes:includes("indent-2-sol") then
    if FORMAT:match 'latex' then
      return {
        pandoc.RawBlock("tex", "\\begin{indent-2-sol}"),
        div,
        pandoc.RawBlock("tex", "\\end{indent-2-sol}")
      }
    end
  end
end
