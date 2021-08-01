## Introduction to Machine Learning

This repository contains the slides for the "Introduction to machine learning" course.
[See also the moodle page](https://moodle.lmu.de/course/view.php?id=3001).

## Contributing

We are happy about new contributors. If you contribute something, please feel
free to add your name to the [team](vignettes/team.Rmd).

### Git-Workflow

- Access to the `master` branch is protected, please make your own,
  issue-/task-specific branch **off the `master` branch** to work in and do a
pull request once you're done. 
- Do many **small, focused, single-issue commits** with **descriptive commit
  messages**: each commit message should refer the issue it adresses or fixes,
i.e. include something like `adresses #<issuenumber>`, `closes #<issuenumber>`
or similar, where applicable.
- We generally work based on the [feature branch
  workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
- The person who merges the pull requests adds a note to the [changelog](CHANGELOG.md) if the changes are substantial

### Slides

- Notation on the slides uses [`latex-math`](https://github.com/compstat-lmu/latex-math). Please do read the accompanying ReadMe and clone [`latex-math`](https://github.com/compstat-lmu/latex-math) into this repo (otherwise you will not be able to render the slides).
- Use the commands defined there, don't define your own. 
- If you have to introduce new notation/symbols you should add it to `latex-math`, after doublechecking that  
   - it is consistent with what we already have 
   - you do not overwrite symbols we have already defined differently
- We write slides for beginners: keep it simple, keep it short
- We try to keep slides modular: slidesets should represent about 15-20 minutes of material and be moderately self-contained.
- Don't put code on the slides, the theory is orthogonal to issues of implementation (... in theory..). Code is strictly for exercises/ practice sessions. 
- Compiling the slides should be done via the Makefile: just type `make all` in the specific folder and it will render all slidesets in the folder, or `make <SLIDES>.pdf` to render a specific file `<SLIDES>.tex`.
- `make` will automatically move a copy of the compiled PDFs to the `slides-pdf` directory. From there, files can be copied into the [course website repository](https://github.com/teaching-data-science/intro2ml) in case of a new release.
- We try to keep a "dependency graph" between slide sets up to date so that it's easier to keep track of
what material needs to be understood before what else. Please do add appropriate `%! includes:`-comments in your slides to keep this up-to-date, see also `attic/slide-dependencies.R` and `slides/slide-dependencies.pdf`.
- We recommend usage of `{tinytex}` (install via `tinytex::install_tinytex()`)
- Use `make install` in the slides folder to automagically install **all** the `R` packages you'll need for the slides, demos and exercises. See also `attic/install.R`

### Figures Used in the Slides

- Figures not produced by us are added to the `figure-man` folder of the respective chapter
- R-files which produce figures should be named `fig-*.R`
  - The basic assumption is that you execute the R-files from the rsrc folder
  - These figure producing R-files should save their respective figures to `../figure/`. From the name of the figure it should be clear which R-file produced it.
  - If you create a new plot or change an existing plot, you need to commit your changes of the r-files as well as the corresponding pdf-files. This means in if you create a new plot, you will have to add the pdf-files with `git add -f *.pdf` since pdf-files are ignored in this repo by default.
  - Utility functions used by more than one R-file should be exported to a separate R-file (also located in the respective rsrc folder)
  - Heavy simulations should not be done in the figures producing R-files. Instead, we only load Rdata files which were produced by separate R-files (also located in the rsrc folder)
  
### Exercises

- Exercises are organized chapter-wise. Each folder will contain
  - a subdirectory `figure` for plots,
  - a subdirectory `ex_rnw` that contains .Rnw files with single exercises (prefixed with `ex_`) and associated solutions (prefixed with sol `sol_`),
  - one or multiple exercise sheets (prefixed with `ex_`) and associated solutions (prefixed with sol `sol_`), sourcing the single snippets from `ex_rnw`,
  - a collection file (prefixed with `collection_`) that assembles all exercises for the given topic (those currently used in the exercise sheets, further existing material, ideas, URLs, ...)
- Compiling the slides should be done via the Makefile: just type `make all` and it will render all exercises, solutions and collection files, or `make <FILE>.pdf` to render a specific file `<FILE>.tex`.
- `make` will automatically move a copy of the compiled PDFs to the `exercises-pdf` directory. From there, files can be copied into the [course website repository](https://github.com/teaching-data-science/intro2ml) in case of a new release.

### Code Snippets

- Please follow this [style guide](https://style.tidyverse.org)
- We write code that is meant to be read/worked on by beginners: 
   - simple and legible is better than complex and elegant
   - add a lot of explanatory comments
   - use base-R as much as possible
   - choose variable names and code designs to maximize legibility and comprehension

### Code Demos

now in `/code-demos`. Originals at [this link](https://github.com/compstat-lmu/lecture_intro_to_ml_notebooks)

### Google Figures

Google Figures are stored in the [G-Drive](https://drive.google.com/drive/folders/1JVlK94X7-h1DNaUo-gxOvIyVZph42iHj)

### Creating Lecture Videos

- Video files should have the same name as the slide set they are narrating.
- Our videos show the lecturer's head in the bottom right corner
- Make sure you minimize background noise, have good lighting and do remember to switch off your phone and to sedate or expell your pets / spouses / flatmates / office co-inhabitants for distraction-free recording.
- Make sure you record in a resolution that's high enough to easily read the slides (at least 1280 x 760, higher is better).
- We have excellent USB-Microphones to borrow in Bernd's office
- Many possible workflows, Fabian uses :
    - `mpv /dev/video0 --framedrop=no --speed=1.01 --window-scale=0.35 --no-border --ontop`
    for a borderless, low latency webcam window and `kazam` for screen capture.
   - In `kazam`, don't forget to  
      - set preferences to "USB microphone" & set loudness fairly high
      - set the frame rate to 30

### Number of slides and length of videos

The number of slides and length of videos can be found [here](https://docs.google.com/spreadsheets/d/1dPj2GAFG8ixlRTX_i3Y-DQtPkVnHAF51oimP4-jhdgo/edit#gid=0) and should be updated regularly (i.e. if a new video is published)

### Website

The website is updated whenever the master branch is pushed, via the [Github action Pkgdown](https://github.com/compstat-lmu/lecture_i2ml/actions). 
The website uses `pkgdown` via `_pkgdown.yml`, its pages are in `\vignettes`.
The automatic deployment uses a "secret" (see repository settings on Github),
which is a PAT called `DEPLOY_PAT` (created by Fabian Scheipl, Jan 30 2020).

