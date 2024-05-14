## Slides folder

**This is still WIP** but aims to explain the most important components and workflows.

## General structure

**Slides** are located at

```
slides/<topic>/<slide-name>.tex
```

where `<slide-name>` starts with `slide-` or `slide01`

**Figures** are created either manually and live in

```
slides/<topic>/figure_man/
```

or created with an R script, with the outputs located in

```
slides/<topic>/rsrc/
slides/<topic>/figure/
```

respectively.

## Important files:

- `tex.mk`: Used as `Makefile` in topic subdirectories. Used to render files for which the source has changed.
  You can try it locally by editing a `.tex` file of a subchapter and then call `make most` in the `slides/<topic>` directory.
- `R.mk`: Analogously, but this attempts to execute all `fig-*.R` scripts to recreate figures.

### Important workflows:

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

