# Exercise Sheet Layout Notes

This document summarizes the custom layout pieces used in the exercise sheets,
with emphasis on the indentation wrappers that replace regular Markdown
indentation in a few fragile cases.

## Why custom indentation wrappers exist

Regular Markdown indentation (e.g. nested list items or indented blocks) can
break when a block contains:
- `{{< embed ... >}}` shortcodes
- Code chunks that render plots (e.g. `ggplot` output)

Once a block breaks indentation, following blocks lose their indentation
too. The workaround is to use explicit wrapper blocks (`.indent-1`, `.indent-1-sol`,
etc.) that enforce indentation in HTML and PDF and keep solution blocks visually distinct in PDF.

## When to use `.indent-*` wrappers

Use a custom wrapper when:
- A block contains `{{< embed ... >}}` shortcodes.
- A block contains plot-generating code chunks.
- A solution block should be visually highlighted in PDF (use `-sol` variants).
- A block follows another block that already broke Markdown indentation.
- A layout edge case benefits from manual indentation for readability.

If simple Markdown indentation works (plain text without embeds/plots), you can
keep using it.

## Wrapper classes and intended meaning

The wrappers are Quarto fenced Divs:

```md
::: {.indent-1}
Indented content (no solution styling).
:::

::: {.indent-1-sol}
Solution content (indented and visually highlighted in PDF).
:::
```

Available levels:
- `indent-1`, `indent-2`: Regular indentation (no solution highlight).
- `indent-1-sol`, `indent-2-sol`: Solution indentation with PDF highlight.
- `indent-1-subitem`: Manual subitem indentation (use when `i.` / `ii.` are typed as text).

## How the wrappers are rendered

HTML:
- `exercises/_quarto/styles.css` defines the visual indentation.
  - `indent-1` / `indent-1-sol`: `margin-left: 2em`
  - `indent-1-subitem`: `margin-left: 2em` with list padding to mimic subitem indentation
  - `indent-2` / `indent-2-sol`: `margin-left: 4em`
- The same CSS file also forces list numbering to `a)`, `b)`, `c)` in HTML.

PDF:
Indentation is supported in PDF via `mdframed` left margins and hanging indents.
- `exercises/_quarto/indent_filter.lua` maps `indent-*` Divs to LaTeX
  environments (`\begin{indent-1}` etc.) only for the LaTeX/PDF format.
- `exercises/_quarto/pdf-preamble.tex` defines those environments:
  - `indent-1` / `indent-2`: indentation only (no vertical line), implemented via `mdframed` left margins.
  - `indent-1-sol` / `indent-2-sol`: indentation plus a vertical line on the left.
  - `indent-1-subitem`: manual subitem indentation with hanging indent.

Quarto wiring:
- `exercises/_quarto.yml` attaches the CSS, LaTeX preamble, and Lua filter.

## Related layout tweaks

- `exercises/_quarto/i2ml_theme.scss` adjusts the HTML theme and code font size.
- `exercises/_quarto/pdf-preamble.tex` also reduces code font size in PDF output.

## Practical example

Use wrappers around solution blocks or embedded notebooks to avoid indentation
breakage:

```md
::: {.content-visible when-profile="solution"}
::: {.indent-1-sol}
<details>
<summary>**Solution**</summary>

::: {.panel-tabset}
### R
{{< embed sol_example_R.ipynb#task echo=true >}}
### Python
{{< embed sol_example_py.ipynb#task echo=true >}}
:::
</details>
:::
:::
```

## Quick troubleshooting

- If indentation disappears after an embed or plot chunk, wrap that block in an
  `indent-*` Div (and use `-sol` if it is a solution).
- If PDF output loses a visual cue for solutions, ensure the block uses
  `indent-1-sol` or `indent-2-sol`.
