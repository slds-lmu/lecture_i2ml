# Exercise Sheet Spec (Quarto)

This document defines the format of the exercise sheets: what a sheet contains, how its source is written, which notebooks belong to it and which outputs are built from it. Part 1 is written as rules. Authors and LLM agents follow it when they write a new sheet or convert an existing one from LaTeX, Rnw or Rmd.

- **Status:** draft for review, 2026-10-20
- **See it live:** CART sheet as [HTML](https://html-preview.github.io/?url=https://raw.githubusercontent.com/slds-lmu/lecture_i2ml/refs/heads/master/exercises/trees/trees.html), [exercise PDF](https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/trees/trees_ex.pdf), [PDF with solutions](https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/trees/trees_all.pdf) and [source](https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/trees/trees.qmd)
- **Structure:** Part 1 (§1 to §10) defines the format as rules; Part 2 (§11 to §13) collects proposals and open points and contains no rules.
- **How to apply:** the rules in Part 1 are binding. Where existing sheets differ from them, the rules win; do not copy deviations. If a sheet has to deviate, give the reason in the PR description.
- **For review:** comments on Part 1, and the decisions D1 and D2 in §13.

## Part 1: Format and rules

### 1. Scope, goals and sheet structure

- Covers the weekly exercise sheets. I2ML is the reference implementation; intended as the standard for SL, Optimization, AdvML/IML and AppML (D2).
- In-class sheets: migration not decided (D1, §12).
- Out of scope: slides (stay LaTeX/beamer), exams.
- Goals:
  - one source file per sheet
  - print-quality PDF
  - interactive HTML with collapsible solutions
  - R and Python side by side
  - for I2ML: group A/B variants from the same source
- Sheet structure (I2ML):
  - Four exercises: Exercises 1 and 2 for both groups, Exercise 3 for group B, Exercise 4 for group A. So far, group A exercises tend to be more mathematical (derivations, proofs), group B exercises more applied.
  - Each exercise: heading `## Exercise N: <Title>`, a "Learning goals" callout, subtasks a), b), c), ...
  - Every subtask is directly followed by its (collapsible) solution; collapsible hints are optional.

### 2. General functionality

One `.qmd` produces an interactive HTML and two PDFs.

- **HTML** (on screen, for the exercise session and self-study):
  - Solutions and hints are collapsed. Open them one by one, or all at once with "Show All Solutions".
  - Code appears in R and Python tabs. "Only R" / "Only Python" switches every tab on the page at once.
  - "Print" prints (or saves as PDF) exactly what is visible. Students pick their language and the solutions they want opened, then print their own version; toolbar, table of contents and sidebars are left out.
  - Table of contents and a "Notebooks" list linking to the `ex_`/`sol_` notebooks on GitHub (to work on the tasks or run the solutions).
  - A single self-contained file (`embed-resources: true`) that can be passed on as one file. Two things load when the page opens and need internet: formulas (MathJax, from jsDelivr) and interactive plotly figures (plotly.js, from plotly's CDN; so far only in `classification_1`). The text uses the reader's system font.
- **PDFs** (handout, website):
  - `_ex.pdf`: tasks and hints, no solutions.
  - `_all.pdf`: tasks, hints and all solutions, both languages one after the other.
  - Without the `solution` profile, solutions are removed from the output, not just hidden, so solution-free versions can be published before the solution release.
- **For authors:**
  - One source for tasks, hints, solutions, both languages and both groups.
  - Group-specific versions via the profiles `a`/`b`.
  - Code and output come from executable notebooks, which double as KI-Campus material (§3).

### 3. Decision: code lives in notebooks

- **Rule:** all R and Python code shown in a sheet is stored in Jupyter notebooks and embedded into the `.qmd`. Code handed out with a task comes from `ex_<stem>_R.ipynb` / `ex_<stem>_py.ipynb`, solution code from `sol_<stem>_R.ipynb` / `sol_<stem>_py.ipynb`. The `.qmd` holds text, math and tables, plus hidden `{r}` chunks that only draw figures (§6).
- **Why not code chunks in the `.qmd`:**
  - *Both languages run natively.* A `.qmd` runs one engine with one kernel. Under knitr (the engine the sheets use), Python runs through reticulate inside R. Under the Jupyter engine with a Python kernel, R chunks are not executed at all; they come out as plain text (tested with Quarto 1.7.27). Separate notebooks run R in the `ir` kernel and Python in `python-i2ml`, exactly as students run them.
  - *Students need the notebooks anyway.* They open them from the sheet's "Notebooks" list, and KI-Campus requires them. With code in the `.qmd`, a generator would have to split it back into four notebooks.
  - *Rendering does not run solution code.* Renders are fast, need neither the mlr3 nor the scikit-learn/torch environment, show the same results every time (no newly drawn random numbers), and don't repeat slow computations (tuning, nested resampling, neural networks). Quarto's `freeze` would not help, because it is skipped when single files are rendered, which is what the Makefile does.
- **Accepted costs,** handled by the rules in §7 and the checklist in §10: embedded output can be out of date (re-run notebooks before rendering), the task text is repeated in the `ex_` notebooks (keep it identical), and embeds need cell labels and indentation wrappers.

### 4. Files and naming

- Per chapter, in `exercises/<chapter>/` (`<chapter>` as in the slides, e.g. `supervised-regression`):
  - `<sheet>.qmd`: the single source (tasks, hints, solutions, embeds)
  - `ex_<stem>_R.ipynb`, `ex_<stem>_py.ipynb`: student notebooks with task text, empty code cells and the code handed out with the tasks (§7)
  - `sol_<stem>_R.ipynb`, `sol_<stem>_py.ipynb`: solution notebooks, run and saved with outputs; the sheet embeds code and output from them
  - notebooks only if the sheet has code; pen-and-paper sheets (e.g. `ml-basics`, `nn`) have none
  - `figure/`: static images used by the sheet
  - `Makefile`: one line, `include ../quarto.mk`
  - committed outputs: `<sheet>.html`, `<sheet>_ex.pdf`, `<sheet>_all.pdf` (§9)
- Names: `<sheet>` in lowercase with underscores (e.g. `classification_2`). `<stem>` equals `<sheet>` for new sheets; the evaluation sheets are an existing exception (`evaluation_1` uses `eval_1`).
- Shared per lecture, never changed for a single sheet:
  - `exercises/_quarto.yml`: formats, theme, filters
  - `exercises/_quarto/`: math macros, toolbar, CSS, LaTeX preamble, Lua filter
  - `exercises/quarto.mk`: build targets
  - `exercises/data/`: data sets, read by the notebooks as `../data/<file>`
- Layout fixes go into `_quarto/` and apply to all sheets.

### 5. Sheet template

A complete sheet looks like this. Placeholders are in `<…>`. Leave out what a sheet does not need: `notebook-view` and the libraries hint when there are no notebooks, code tabs for tasks without code, group-only exercises in lectures without groups.

```md
---
title: "Exercise <N> -- <Topic>"
subtitle: "[Introduction to Machine Learning](https://slds-lmu.github.io/i2ml/)"
notebook-view:
  - notebook: ex_<stem>_R.ipynb
    title: "Exercise sheet for R"
    url: "https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/<chapter>/ex_<stem>_R.ipynb"
  - notebook: ex_<stem>_py.ipynb
    title: "Exercise sheet for Python"
    url: "https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/<chapter>/ex_<stem>_py.ipynb"
  - notebook: sol_<stem>_R.ipynb
    title: "Solutions for R"
    url: "https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/<chapter>/sol_<stem>_R.ipynb"
  - notebook: sol_<stem>_py.ipynb
    title: "Solutions for Python"
    url: "https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/<chapter>/sol_<stem>_py.ipynb"
---

::: {.content-hidden when-format="pdf"}
::: {.hidden}
{{< include ../_quarto/latex-math.qmd >}}
:::
{{< include ../_quarto/solution-buttons.qmd >}}
:::

<details>
<summary>*Hint: Useful libraries*</summary>

::: {.panel-tabset}
### R
{{< embed ex_<stem>_R.ipynb#import echo=true >}}
### Python
{{< embed ex_<stem>_py.ipynb#import echo=true >}}
:::
</details>

## Exercise 1: <Title>

::: {.callout-note title="Learning goals" icon=false}
1. <goal>
2. <goal>
:::

<Introduction: setting, data, notation.>

a) <Task without code.>

::: {.content-visible when-profile="solution"}
::: {.indent-1-sol}
<details>
<summary>**Solution**</summary>

<Solution text and math.>

</details>
:::
:::

b) <Task that asks for code. Continuation paragraphs are indented 3 spaces.>

   <details>
   <summary>*Hint*</summary>

   <Hint text.>

   </details>

::: {.indent-1}
::: {.panel-tabset}
### R
{{< embed ex_<stem>_R.ipynb#<label> echo=true >}}
### Python
{{< embed ex_<stem>_py.ipynb#<label> echo=true >}}
:::
:::

::: {.content-visible when-profile="solution"}
::: {.indent-1-sol}
<details>
<summary>**Solution**</summary>

<Text that applies to both languages.>

::: {.panel-tabset}
### R
<What the first cell does.>
{{< embed sol_<stem>_R.ipynb#<label> echo=true >}}
<What the next cell does.>
{{< embed sol_<stem>_R.ipynb#<label-2> echo=true >}}
### Python
<What the first cell does.>
{{< embed sol_<stem>_py.ipynb#<label> echo=true >}}
<What the next cell does.>
{{< embed sol_<stem>_py.ipynb#<label-2> echo=true >}}
:::

<Interpretation of the results, valid for both languages.>

</details>
:::
:::

## Exercise 2: <Title>

<Same structure as Exercise 1.>

::: {.content-hidden when-profile="a"}

## Exercise 3: <Title>

::: {.callout-tip icon=false title="The whole exercise is only for lecture group B!"}
:::

::: {.callout-note title="Learning goals" icon=false}
1. <goal>
:::

<Introduction, subtasks and solutions as in Exercise 1.>

:::

::: {.content-hidden when-profile="b"}

## Exercise 4: <Title>

::: {.callout-tip icon=false title="The whole exercise is only for lecture group A!"}
:::

<Learning goals, introduction, subtasks and solutions as in Exercise 1.>

:::
```

The `ex_` tabset under b) is only needed when the task hands out code (e.g. data generation). Most code tasks only have the solution tabset.

### 6. Markup rules

**YAML header**

- Only `title`, `subtitle` and, if the sheet embeds notebooks, `notebook-view`. No `format:` block and no other per-sheet options: a sheet-level `format:` changes what `quarto render` builds. The `format:` blocks in trees, forests and nn are known deviations.
- `title: "Exercise <N> -- <Topic>"`: `<N>` is the number of the sheet in the course; two hyphens.
- `subtitle`: the course name linked to the course website, for I2ML exactly as in §5.
- `notebook-view`:
  - What it does: `notebook-links: global` in `_quarto.yml` makes Quarto list every embedded notebook in the HTML's "Notebooks" section. `notebook-view` gives each entry its title and points its link to the notebook on GitHub.
  - Why it is needed: without it, Quarto links each entry to a generated `<notebook>-preview.html`. That file is not part of the self-contained HTML (and `make clean` deletes it), so students would get a dead link. An embedded notebook without an entry is missing from the list (e.g. `sol_tuning_py.ipynb` in `tuning.html`).
  - Entries: one per notebook the sheet embeds, in the order `ex_` R, `ex_` Python, `sol_` R, `sol_` Python, with the titles from §5 and the URL `https://github.com/slds-lmu/<repo>/blob/master/exercises/<chapter>/<notebook>`.
  - Quarto 1.7 ignores `url` and still links to the preview file; render with Quarto 1.10 (§9).

**Sheet header**

- First block after the YAML header, verbatim as in §5. It loads the math macros for the HTML (for the PDF, Pandoc expands them) and the toolbar.

**Libraries hint** (sheets with code)

- Directly after the sheet header, before Exercise 1, as in §5: summary `*Hint: Useful libraries*`, embedding the `import` cell of both `ex_` notebooks.

**Exercises**

- Heading `## Exercise <N>: <Title>`, numbered 1, 2, … in order of appearance. These are the only headings; `### R` / `### Python` inside tabsets and title lines inside callouts are not headings.
- Directly after the heading: the learning goals callout from §5 with 1 to 4 goals as a numbered list (`1.`, `2.`), each starting with a verb ("Compute …", "Explain …").
- Then the introduction (setting, data, notation), then the subtasks.
- Group-only exercise: wrap the whole exercise in `::: {.content-hidden when-profile="a"}` (group B only) or `when-profile="b"` (group A only), with the group callout directly after the heading, before the learning goals (§5).
- Bonus exercise: directly after the heading, `::: {.callout-tip icon=false title="Bonus exercise -- will not be discussed in the tutorial session"}` with one sentence on who it is for.
- Other callouts, mainly inside solutions: `callout-tip` for procedures and background, `callout-warning` for pitfalls and caveats.

**Subtasks**

- `a)`, `b)`, `c)` at the start of the line, one per task. Letters continue through the exercise, although solution blocks interrupt the list, and restart at `a)` in the next exercise.
- Everything that belongs to a subtask (further paragraphs, sub-items, tables, hints) is indented 3 spaces, aligned with the text after `a) `.
- Sub-items: `(i)`, `(ii)`, … or `-` bullets, indented 3 spaces.
- Text that introduces the following subtasks (new data, a new assumption) stands at the start of the line, between two subtasks.

**Hints**

- Inside the subtask, indented 3 spaces: `<details>`, then `<summary>*Hint*</summary>`, a blank line, the hint, a blank line, `</details>`. Without the blank lines, Markdown inside is not rendered.
- Labels: `*Hint*` for subtasks, `*Hint: Useful libraries*` for the sheet-level hint. No other labels (`*R Hint*`, `*Hint 1*`, …).
- Language-specific hint: a tabset (`### R` / `### Python`) inside the hint.
- Hints are part of the task: they appear expanded in `_ex.pdf` and must not give away the solution.

**Solutions**

- Every subtask has exactly one solution block, directly after the subtask (after its hint), starting at the beginning of the line, nested exactly as in §5: `content-visible when-profile="solution"`, then `.indent-1-sol`, then `<details>` with `<summary>**Solution**</summary>`.
- No solution content outside this block; anything outside also ends up in `_ex.pdf`.
- Do not indent text inside the block (the wrapper does that); 4 leading spaces turn Markdown into a code block.
- Text that applies to both languages (derivations, interpretation) appears once, outside the tabs; tabs hold only code and language-specific remarks.
- Optional extras inside a solution (an alternative derivation, an illustration): a nested `<details>` with a bold, descriptive summary, e.g. `<summary>**Alternative: componentwise derivation**</summary>`.

**Code**

- All code comes from notebooks (§3): `{{< embed <notebook>.ipynb#<label> echo=true >}}`. Always `echo=true`; without it only the output is shown.
- Always in a tabset, `### R` first, then `### Python`. Every task that asks for code has both tabs.
- Code handed out with a task: tabset from the `ex_` notebooks, wrapped in `::: {.indent-1}`, outside the solution block.
- Two embeds directly after each other fail; put a line of text between them that says what the next cell does.
- Nothing is executed at render; embeds show the code and output saved in the notebook.
- No `{python}` chunks. `{r}` chunks only for figures (below), never for solution code.

**Figures and tables**

- Generated figure: a hidden R chunk; load packages inside it and set a seed if it draws random numbers:

  ````md
  ```{r, echo=FALSE, message=FALSE, warning=FALSE, fig.align="center", fig.height=3.5, fig.width=3.5}
  library(ggplot2)
  <plot code>
  ```
  ````

- Static image: a PNG in `figure/`, included as `![<caption, may be empty>](figure/<name>.png){width=50%}`. Convert PDF figures to PNG; browsers do not display PDF images.
- Interactive plotly figure (HTML only; give the PDF a static image, as `classification_1` does): in the hidden chunk, `source("../_quarto/plotly.R")` and print `small_plotly(p)` instead of `p`. It shrinks the embedded data and loads plotly.js from plotly's CDN, so the figure needs internet, like formulas. All plotly figures of a sheet share one plotly.js bundle; `small_plotly()` stops with a hint if they don't fit one.
- Inside a subtask, wrap figures in `::: {.indent-1}` (plots break Markdown indentation). Inside a solution, the `.indent-1-sol` wrapper is enough.
- Tables: Markdown pipe tables; math in cells is fine.

**Math**

- Inline `$…$`; display math as `$$…$$` or `\begin{align*} … \end{align*}`, with a blank line before and after.
- Only macros defined in `_quarto/latex-math.qmd` (`\xv`, `\risk`, `\Np`, …). That file is an older copy of the slides' macros (§11): before using a macro from the slides, check that it is defined there; otherwise write it out (e.g. `\mathcal{N}`). No `\newcommand` in a sheet.
- No `\label` / `\ref`; refer to equations and figures in words ("the model from a)").

**Layout**

- Indent wrappers, only where Markdown indentation breaks (embeds and figures inside subtasks): `.indent-1`, `.indent-2` (plain), `.indent-1-sol`, `.indent-2-sol` (solutions, with a line on the left in the PDF), `.indent-1-subitem` (sub-items typed as text). No other classes; `.indent-0` does not exist. Details: [`exercises/EXERCISE_SHEETS_LAYOUT.md`](exercises/EXERCISE_SHEETS_LAYOUT.md).
- No raw LaTeX for layout (`\vspace`, `\newpage`, `\hfill`, `\\`, `\noindent`); the HTML drops it. If the PDF needs a page break, use `{{< pagebreak >}}`.
- Links: `[text](url)`. Data files link to `https://github.com/slds-lmu/lecture_i2ml/blob/master/exercises/data/<file>`.
- Language: English.

### 7. Notebooks

- **Kernels:** R notebooks use `ir`; Python notebooks use `python-i2ml` (display name "Python (I2ML)").
- **Labels:** every cell the sheet embeds starts with `#| label: <label>` (no space between `#` and `|`). Labels are lowercase with hyphens and unique within a notebook. Corresponding R and Python cells get the same label.
- **`sol_` notebooks:**
  - an import cell at the top
  - per exercise a Markdown cell `## Solution <N>: <Title>`, followed by the solution cells in the order of the sheet
  - run top to bottom and saved with outputs before the sheet is rendered, from the chapter folder with `jupyter nbconvert --to notebook --execute --inplace --config ../_quarto/compact_png.py sol_<stem>_py.ipynb`. The config stores the figures as 256-color PNGs: much smaller notebooks and HTML, no visible change. For a notebook saved from Jupyter or VS Code, run the same command without `--execute`.
- **`ex_` notebooks:**
  - a header cell with the course name and link, then `# Exercise sheet <N>: <Topic>`
  - an import cell labeled `import` (embedded by the libraries hint)
  - per exercise `## Exercise <N>: <Title>` and the task text as a quote (`> a) …`), identical to the sheet
  - after each subtask an empty code cell `# Enter your code here:` (code tasks) or a Markdown cell `Enter your answer here:` (text tasks)
  - code handed out with a task as labeled cells
  - no outputs
- **Data:** read from `../data/<file>` (relative to the notebook). R may use built-in mlr3 tasks (e.g. `tsk("bike_sharing")`). New data sets go into `exercises/data/`.
- **Randomness:** set a seed in every notebook that draws random numbers. R and Python draw different numbers even with the same seed, so both languages use the same data set and the same settings (sample sizes, grids, hyperparameters), and the solution text must not depend on exact random values. Where it does, store the data in `exercises/data/` and read it in both languages.

### 8. Converting existing sheets (LaTeX, Rnw, Rmd)

**Source layouts**

- I2ML, `exercises/<chapter>-tex/`: a sheet file `*.Rnw` with `\kopf{<N>}{<Topic>}` (`\kopfic` for in-class sheets) and `\aufgabe{<Title>}{…}` blocks that pull in exercises from `ex_rnw/ex_*.Rnw`; solutions are in `ex_rnw/sol_*.Rnw`; R code in knitr chunks.
- IML: `\aufgabe{<Title>}{…}` in `.tex` files under `ex_tex/`, solutions in `*_sol.tex`, figures in `figure/`, R code in separate files or `*_R_sol.Rmd`.
- AppML: one `.Rmd` per sheet (prettydoc HTML), solutions switched by a `show.solution` variable, Python in `<name>_py.ipynb`.

**Procedure**

1. Collect everything that belongs to the sheet: exercise text, solutions (often in a separate file), figures, data and code.
2. Convert, don't rewrite: keep the tasks, their order, the solution steps and the numbers. Fix only clear errors and list them in the PR description.
3. Build the `.qmd` from the template in §5: one `## Exercise <N>` per source exercise, subtasks as `a)`, `b)`, and each solution moved directly below its subtask.
4. Move all code into the four notebooks (§7), run them, embed the cells.
5. Add what the format requires but the source lacks: learning goals, and the second language for every code task (write it, run it, check the results agree). Add hints only if the source has them. Assign exercises to group A or B only if the source or the request says so; otherwise ask. List everything you added in the PR description so it gets reviewed.
6. Build and check (§9, §10).

**Mapping**

| Source | `.qmd` / notebooks |
|---|---|
| `\kopf{<N>}{<Topic>}`, Rmd `title`/`subtitle`/`output` | YAML header as in §5 |
| `\aufgabe{<Title>}{…}`, Rmd `# 1 <Title>` | `## Exercise <N>: <Title>` plus learning goals callout |
| Rmd "Goal" section | learning goals callout |
| `\begin{enumerate}[a)] \item`, `\item[1)]`, Rmd `## 1.1 …` | subtasks `a)`, `b)`, … |
| nested `enumerate` | `(i)`, `(ii)` or `-` bullets, indented 3 spaces |
| separate solution file (`sol_*.Rnw`, `*_sol.tex`), `\begin{loesung}`, Rmd `show.solution` blocks | one solution block per subtask, directly after it |
| `\textit{Hint:} …`, Rmd `<summary>**Hint 1**</summary>` | hint block with `*Hint*` |
| `\textbf{x}`, `\emph{x}` / `\textit{x}` | `**x**`, `*x*` |
| `\texttt{x}`, `\code{x}`, `\verb\|x\|` | `` `x` `` |
| `\url{u}`, `\href{u}{t}` | `<u>`, `[t](u)` |
| `\footnote{t}` | `^[t]` |
| `tabular` | pipe table |
| `\includegraphics{figure/x.pdf}` | `![](figure/x.png){width=…}` (convert to PNG) |
| `$…$`, `\[…\]`, `equation`, `align` | `$…$`, `$$…$$`, `\begin{align*}…\end{align*}` (check macros, §6) |
| `\label{…}`, `\ref{…}` | reference in words |
| knitr chunk that draws a figure (`<<…, echo=FALSE>>=`) | hidden `{r}` chunk (§6) |
| knitr or Rmd chunk with task code | labeled cell in `ex_<stem>_R.ipynb`, embedded |
| knitr or Rmd chunk with solution code | labeled cell in `sol_<stem>_R.ipynb`, embedded |
| Rmd `setup.R` / package chunk | `import` cell in the notebooks |
| Python notebook with tasks and solutions | split into `ex_<stem>_py.ipynb` and `sol_<stem>_py.ipynb` |
| `\Sexpr{expr}` | the computed value, written out |
| `\\`, `\vspace`, `\lz`, `\dlz`, `\newpage`, `\hfill`, `\noindent`, `center` | drop; `{{< pagebreak >}}` only if the PDF needs it |

### 9. Outputs and build

- Profiles (`quarto render --profile ...`; no profile files needed):
  - none: tasks and hints, both groups
  - `solution`: adds solutions and the "Show All Solutions" button
  - `a` / `b`: hides the other group's exercise
  - combinable, e.g. `solution,a`
- Committed outputs per sheet:
  - `<sheet>.html` (`make solhtml`): tasks, hints, collapsible solutions, toolbar; for the session on screen
  - `<sheet>_ex.pdf` (`make expdf`): tasks and hints; handout, website before solution release
  - `<sheet>_all.pdf` (`make solpdf`): with solutions; website after release
- Build in `exercises/<chapter>/` (targets in [`exercises/quarto.mk`](exercises/quarto.mk)):
  - `make all` builds everything and copies the PDFs to `exercises-pdf/`, which the course website links to
  - `make <sheet>` renders one solution HTML for a quick check; `make clean` removes temporary files
- Before rendering, re-run every notebook that changed (§7).
- Render with Quarto 1.10 (committed HTMLs: 1.10.15 to 1.10.19).
- `embed-resources` downloads the scripts a page links to and embeds them. If that fails (e.g. an antivirus scanning HTTPS connections), Pandoc keeps the link and the render log says "Could not fetch resource"; the HTML still works but is not fully self-contained.
- HTML must keep all features listed in §2.
- PDF must print as a handout without manual fixes (no cut-off code, no orphaned headings). Check both PDFs by eye before committing them.
- Toolchain: Quarto, R with knitr, LaTeX; Python and Jupyter to re-run the notebooks. Sheets use the knitr or markdown engine, so rendering starts no Jupyter kernel.

### 10. Checklist before committing

- [ ] The sheet follows the template (§5) and the rules in §6; YAML has no `format:` block.
- [ ] Every subtask has exactly one solution block; `_ex.pdf` contains no solution text.
- [ ] Every code task has an R and a Python tab, R first; all code comes from embeds.
- [ ] All notebooks use the right kernel, were run top to bottom with the command in §7 and saved; `sol_` notebooks with outputs, `ex_` notebooks without.
- [ ] Task text in the `ex_` notebooks matches the sheet.
- [ ] Every embedded cell has a `#| label:`; every embedded notebook has a `notebook-view` entry.
- [ ] Every math macro is defined in `_quarto/latex-math.qmd`.
- [ ] `<sheet>.html`, `<sheet>_ex.pdf` and `<sheet>_all.pdf` are re-rendered; both PDFs checked by eye.
- [ ] The PR description lists everything added or fixed during a conversion (§8).

## Part 2: Open points

### 11. Math notation (latex-math)

- Now: sheets include a hand-made copy of the macros, `exercises/_quarto/latex-math.qmd`, which drifts from the slides' `latex-math/*.tex`.
- Spec: sheets use the same macros as the slides, taken from the `latex-math/*.tex` files, with no hand-maintained copy.
- What it takes to use the `.tex` macros in a sheet:
  - **Reach both renderers.** Math is rendered by MathJax in the HTML and by LaTeX in the PDF (Pandoc first expands the macros it can parse). The definitions must reach both, e.g. as a hidden `$$ … $$` block that every sheet includes.
  - **Use only commands MathJax understands.** MathJax covers only part of LaTeX: it has no `dsfont` (`\mathds`) and no `bm` (`\bm`). These are mapped to supported equivalents (`\mathbb`, `\boldsymbol`) or avoided in the `.tex` files. TeX conditionals such as `\ifdefined` are not supported by MathJax either, and Pandoc warns about them.
  - **Generate instead of copy.** A script turns the `.tex` files into the included file (apply the mappings, wrap in `$$ … $$`). It reruns whenever latex-math changes, and its output is synced to the lectures together with the `.tex` files.
  - **Avoid clashes.** Each macro is defined once, and no name collides with a command that LaTeX, Pandoc or MathJax already defines.
  - **Check after every change.** Re-render all sheets in HTML and PDF and look for unrendered commands.
- Including the raw `.tex` does not work: the include pastes the file into the Markdown as is, so `\mathds{R}` and `\bm{\theta}` stay unrendered in the HTML. Loading it into the LaTeX preamble works for the PDF only (Appendix).
- latex-math already generates such a file, `latex-math/combined.qmd`. Proposal: include it instead of the copy (`{{< include ../../latex-math/combined.qmd >}}`), then re-render all sheets and compare. The switch changes a few definitions, all compatibly (Appendix).

### 12. In-class sheets (D1)

- Now: `.Rnw` in `exercises/<chapter>-tex/` (`ic_<topic>.Rnw`, `ic_sol_<topic>.Rnw`), built with knitr and `style/preamble_ueb.Rnw`; PDF only, A4; printed and handed out; no code, no notebooks.
- Options:
  - migrate, so there is one infrastructure for slides and one for sheets
  - keep the Rnw sheets, since in-class sheets differ (no code, no solutions); migration is acceptable if the printed result is equivalent
- If migrated, same format as Part 1, except:
  - no notebooks, no language buttons
  - solutions via the `solution` profile instead of separate `ic_sol_` files
  - header shows course, "Live Session N" and topic, as `\kopfic` does today
  - acceptance: printed PDF equivalent to the Rnw version (same page count, no extra page breaks, side-by-side elements stay side by side; explicit breaks via `{{< pagebreak >}}`)
<!-- - The pilot (`ml-basics_ic_0.qmd`, `ml-basics_ic_1.qmd`) does not pass yet; the Rnw PDFs stay published:
  - `ic_0` gives 4 pages instead of 2 (figure pushed to page 2, confusion matrices stacked, "Model C" alone on page 4)
  - the two titles are swapped; `ic_1` has an older text than `ic_ml-basics-concepts.Rnw` -->

### 13. Status, decisions and open items

- **Done:** template and layout (PR #1316); A/B structure in 8 of 12 sheets; HTMLs re-rendered with the solution profile and `make all` order fixed (PR #1328).
- **Decisions needed:**
  - **D1** Migrate the in-class sheets (§12)?
  - **D2** Rollout to SL, Optimization, AdvML/IML, AppML: scope and timing? Today the setup exists only in `lecture_i2ml/exercises/` (AppML and IML use Rmd exercises; SL and Optimization not checked). Proposal: move `_quarto.yml`, `_quarto/` and `quarto.mk` to `lecture_service/service/exercises/` and sync them via `scripts/update-service.sh` like `style/`, with course name and URL set per lecture.
<!-- - **Open: outputs** (proposed fix after the arrow):
  1. Toolbar buttons read Python | R, tabs are R | Python (Ludwig) → swap the buttons in `_quarto/solution-buttons.qmd`.
  2. `exhtml`/`solhtml` run `quarto render` without `--to html`, so Quarto renders every format: trees, forests and nn (sheet-level `format: pdf:`) never get an HTML (Ludwig); the other sheets also write an unsuffixed `<sheet>.pdf` that `copy-all` would publish → add `--to html` to `exhtml`, `solhtml` and the `%` rule; remove sheet-level `format:` blocks.
  3. `exhtml` and `solhtml` write the same `<sheet>.html`, so `make ex` leaves one without solutions that must not be committed → drop `exhtml` from `all` or name its output `<sheet>_ex.html`.
  4. PDF engine not pinned: `latex_engine: pdflatex` sits under `html:` and has no effect, so the engine depends on who renders (committed PDFs: pdfTeX; local test: XeLaTeX) → `pdf-engine: pdflatex` under `pdf:`.
  5. Small PDF layout glitches, e.g. an empty bar under the group callout → fix.
  6. "Show All Solutions" also opens hints → decide on hints.
- **Open: content:**
  7. tuning and nested_resampling have 3 exercises each, no group split → rework.
  8. 7 different hint labels → standardize on `*Hint*` and `*Hint: Useful libraries*`.
- **Open: infrastructure and maintenance:**
  9. latex-math copy → include `combined.qmd` (§11).
  10. 4 notebooks declare the wrong kernel; cell labels mix `# | label` and `#| label` → fix kernels (`update-kernel_py.py` for Python), standardize on `#| label`.
  11. Environment files disagree (e.g. scikit-learn 1.1.3 vs 1.5.0) → one source of truth per language.
  12. `ex_` notebooks are maintained by hand → generate them by stripping code and outputs from the `sol_` notebooks.
  13. No CI renders the exercises → render all sheets, with and without `solution`, on PRs touching `exercises/`.
  14. Quarto version not pinned (committed HTMLs: 1.10.15 to 1.10.19) → pin one.
  15. Unused `jupyter: python3` in `_quarto.yml` → remove.
  16. Wiki page "Exercises" says plain `quarto render` gives HTML; its known-issues list is unverified → update after items 1 and 2. -->
<!-- 
## Appendix: details

- **Changed latex-math definitions (§11):** `\argmin`/`\argmax` use `\mathop` instead of `\operatorname`; `\muk`, `\pixii`, `\pixit` gain an optional argument whose default is the old behavior.
- **latex-math warnings:** Pandoc warns about `\N`, `\C` (`\ifdefined` pattern) and `\fh`, `\sl` (defined twice in latex-math itself). Harmless; fix the duplicates upstream.
- **Native `.tex` for the PDF only:** possible via `include-in-header`, but works only with pdfLaTeX (`bm` clashes with `unicode-math` under XeLaTeX) and only if Pandoc's macro expansion is turned off (`from: markdown-latex_macros`, untested). Only gain: dsfont glyphs for `\R` etc., as in the slides.
- **PDF glitches (item 5):** the group callout prints an empty body bar under its title (give it a body or use a title-less style); trees.qmd uses an undefined `.indent-0`; forests and nn include `pdf-preamble.tex` a second time.
- **Hint labels (item 8):** `*Hint*`, `*Hint: Useful libraries*`, `*R Hint*`, `*Python Hint*`, `*mlr3 Hint*`, `*Hint: Useful libraries for this exercise sheet*`, ``*Hint: useful `Python` libraries*``.
- **Kernels (item 10):** `ex_trees_R.ipynb`, `ex_tuning_R.ipynb` declare a Python kernel (should be `ir`); `sol_eval_2_py.ipynb`, `sol_classification_2_py.ipynb` use `python3` instead of `python-i2ml`.
- **Environments (item 11):** `python-i2ml.yml` pins scikit-learn 1.1.3 / numpy 1.21.5, `python-i2ml-requirements.txt` pins scikit-learn 1.5.0 / numpy ≥ 1.22; `R-i2ml.yml` pins R 4.1. -->
