## Slides folder

**This is still WIP** but aims to explain the most important components and workflows.

## General structure

**Slides** are located at

```
slides/<topic>/<slide-name>.tex
```

where `<slide-name>` starts with `slide-` or `slide01-`

**Figures** are created either manually and live in

```
slides/<topic>/figure_man/
```

or created with an R script in

```
slides/<topic>/rsrc/
```

with the outputs located in

```
slides/<topic>/figure/
```

The script filename should make it obvious which figure it creates, and similarly the filename of the figure should match the script.
The figures should be saved by the script (using e.g. `ggsave()`).

### Important files:

- `tex.mk`: Used as `Makefile` in topic subdirectories. Used to render files for which the source has changed.
  You can try it locally by editing a `.tex` file of a subchapter and then call `make most` in the `slides/<topic>` directory.
- `R.mk`: Analogously, but this attempts to execute all `fig-*.R` scripts to recreate figures.

### Workflows:

- Edit files via Overleaf ("the prof workflow"), ensure changes are synced back to GitHub
  - You can not run Makefiles on Overleaf
  - All slides will be rendered with 16:9 speaker margin by default

- Create a new subchapter for `<topic>`:
  - Create the folder `slides/<topic>`
  - Copy one of the makefiles `Makefile` from another subchapter (e.g. `all`)
     - `slides/<topic>/Makefile` must contain `include ../tex.mk` and nothing else
  - __Note__ that all pdfs in the subchapter directory are ignored. PDFs in the figure folder of a subchapter on the other hand are valid.
- Locally render a subchapter:
  - Change directory into the subchapter
  - Run `make most`
  - __Note__ that a latex distro must be installed (e.g. `texlive-full`, just `texlive` is not enough) and `latexmk`.
    - For debian/ubuntu users call `sudo apt install -y texlive-full latexmk`, but this is needlessly heavy
    - [The service repo at slds-lmu/lecture-service](https://github.com/slds-lmu/lecture_service/tree/main) has instructions to install only needed packages,
      but `make install-tex` inside the service repo should be sufficient, assuming you have a working LaTeX installation via TinyTeX or TeXLive

- Locally render one `.tex` file:
  - Use `latexmk -pdf <slide-name>.tex` or your favorite editor.


- Render all slides in a subchapter with margins: `make most`
- Render all slides in a subchapter without margins: `make most-normargin`

## Slide editing

Some common parts relevant to the slide editing such as custom macros are described here and should be kept in mind by everyone working on the slides.

### Figure paths

A general issue arising when using Overleaf and local commands is that on overleaf, figure paths are autocompleted relative to the project root, i.e. `slides/<topic>/figure_man/foo.pdf`, but for local compilation, it is necessary for paths to be relative to the `<slide-name>.tex` file, e.g. `figure_man/foo.pdf`.

There is an [automated workflow](https://github.com/slds-lmu/lecture_service/blob/main/service/.github/workflows/fix-figure-paths.yaml) that checks and corrects for this installed in every lecture repo (ideally) using GitHub Actions.  
It automatically creates a pull request to apply the fixes as needed..

### Title Slide

The title slide is defined by a macro `\titlemeta`, which looks as such:

```latex
\title{Introduction to Machine Learning}

\begin{document}

\titlemeta{% Chunk title (example: CART, Forests, Boosting, ...), can be empty
  CART
  }{% Lecture title  
  Advantages \& Disadvantages
  }{% Relative path  (to slide .tex) to title page image: Can be empty and must not start with slides/
  figure_man/some_figure.pdf
  }{% Learning goals
    \item First learning goal
    \item second learning goal
}
```

This will take the title of the lecture (`\title{...}`) and the arguments of the macro to produce
a title slide with headings as such:

```
Introduction to Machine Learning  

CART  
Advantages & Disadvantages
```

And a figure (left) next to the itemized list of learning goals (right).

Other commands such as `\institute`, `\author` or `\date` are superfluous and ignored.
Command `\lecture` and `\lecturechapter` are used within `\titlemeta`, so they should not be used in the `<slide-name>.tex` file.

### Cite button

The new cite button (as of 2024-05) is called `\citelink` and supersedes the old `\citebutton` command.

In `<slide-name>.tex` files, use `\citelink{BIBREF}`, where `BIRBEF` must(!) be all-caps and a cite-key defined in a `references.bib`.

- Each `lecture_XYZ/slides/<topic>` subfolder has it's own `references.bib`. 
- Since biblatex/biber/latexmk will look for these files in the same directory as the .tex file, this is a hard requirement for now.

The preamble is set up such that package `biblatex` is only loaded if a `references.bib` is detected to avoid spurious errors.   
Note that the `biber` command must be available in `$PATH` / by `latexmk` for this to work.  
This should be the case ofr a normal LaTeX installation, but debugging is hard.
