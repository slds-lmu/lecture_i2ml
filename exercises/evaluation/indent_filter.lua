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
