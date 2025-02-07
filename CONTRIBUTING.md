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
- If you have to introduce new notation/symbols you should add it to `latex-math`, after double-checking that  
   - it is consistent with what we already have 
   - you do not overwrite symbols we have already defined differently
- We write slides for beginners: keep it simple, keep it short
- We try to keep slides modular: slidesets should represent about 15-20 minutes of material and be moderately self-contained.
- Don't put code on the slides, the theory is orthogonal to issues of implementation (... in theory..). Code is strictly for exercises/ practice sessions. 
- Compiling the slides should be done via the **Makefile**.
  - Before compiling anything, remove auxiliary files by running `make texclean` from within the corresponding folder.
  - There are basically 3 use cases, for all of which you have the option to compile with or without a right-side **margin**. The margin is added when the slides are to be used in recording a video (the speaker's head will appear there). 
  - Use case 1a: you want to **compile a single** PDF `<SLIDES>.tex`. Run `make <SLIDES>.pdf` (`make <SLIDES>-nomargin.pdf`) to compile with (without) margin.
  - Use case 1b: you want to **copy a single** PDF to `slides-pdf`. Run `make copy F=<SLIDES>.pdf`.
  - Use case 2a: you want to **compile all** PDFs in a folder. Run `make most` (`make most-nomargin`) to compile with (without) margin. 
  - Use case 2b: you want to **copy all** PDFs to `slides-pdf`. Run `make copy-all`.
  - Use case 3: you want to **compile and copy all** PDFs in a folder and update the corresponding files in `slides-pdf`. Run `make all` (`make all-nomargin`) to compile with (without) margin. This will automatically move a copy of the compiled PDFs to the `slides-pdf` directory. The [course website repository](https://github.com/teaching-data-science/intro2ml) links to `slides-pdf`, so make sure you only update the files in there if you want to release them on the website.
  - Note that compiling without margin is handled by creating a temporary file signaling to remove the margin, so make sure to run `make texclean` after compiling for a clean slate. 
  - You can remove all PDFs in a folder with `make clean`.
  - If you use Windows we recommend that you access make via the [Ubuntu bash](https://apps.microsoft.com/store/detail/ubuntu/9PDXGNCFSCZV?hl=en-us&gl=US) (take a look at the installation tips).
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
- If you replace graphics with new files with a different file name, or if you remove slides with graphics in them, then make sure that you remove unused files. To check if there are unused files in a `figure/` or `figure_man/`-folder, do the following:
  1. Make sure you are in the folder that contains the `.tex`-files.
  2. Run `make most`, which re-compiles all `.pdf`-files while creating a log of what files were used.
  3. Run `../../scripts/check_files_used.sh figure unused slides-*.tex` to list all files in the `figure/`-folder that are unused.
  4. Do the same for the `figure_man/`-folder: `../../scripts/check_files_used.sh figure_man unused slides-*.tex`.
  5. Remove the unused files from git. The easiest way to do this is to use `git rm <file>`, but you can also delete the file first and then "add the deletion": `rm <file>` followed by `git add <the file that was deleted>`. You can then commit.
  6. If you find that you deleted a file that should not have been deleted, you can retrieve it from the git history: [through the command line](https://stackoverflow.com/questions/7203515/how-to-find-a-deleted-file-in-the-project-commit-history) or by browsing the GitHub git history.
  
### Exercises

- **Structure**. Exercises are organized chapter-wise and implemented in [quarto](https://quarto.org/) (which you need to install on your local machine). Folders typically contain
  - a subdirectory `figure` for plots,
  - `exercise.qmd`, the location of the entire exercise including solutions (we don't want exercises sourced from subfiles anymore).
  - `exercise.html`, the main HTML file used in the exercise session. Compiled from `exercise.qmd`
  - `ex_exercise_py.ipynb` / `ex_exercise_R.ipynb`, notebooks with empty code cells. Mainly for KI campus.
  - `sol_exercise_py.ipynb` / `sol_exercise_R.ipynb`, end-to-end executable notebooks. `exercise.qmd` sources notebook cells.
  
- **Editing**
  - Global
    - `exercises/_quarto/i2ml_theme.scss`: theme file, edit for global settings like colors.
    - `exercises/_quarto/latex-math.qmd`: copy of `latex-math` commands wrapping macros in dollar signs so file can be sourced by `exercise.qmd`. Feel free to come up with better option and/or automatic update rule for `latex-math` updates. 
    - `exercises/_quarto.yml`: theme file, edit for global header options.
  - Chapter-specific
    - `exercises/chapter/exercise.qmd`: edit in text editor or RStudio. Key block types: code chunks, callouts, conditional blocks (controlled by options added to `quarto render`, see below).
    - `exercises/chapter/sol_exercise_py.ipynb`: edit and run on Jupyter server via `jupyter notebook sol_exercise_py.ipynb`. :warning: Make sure to operate from within virtual environment (use/update `exercises/python-i2ml.yml` / `exercises/python-i2ml-requirements.txt`); better solution with, e.g., `poetry` might be worth considering). NB: `exercises/chapter/exercise.qmd` sources cell output w/o executing the notebook again, so you need to run corresponding cells in Jupyter for them to appear correctly.
    - `exercises/chapter/sol_exercise_R.ipynb`: same as Python notebook but with specific kernel. From within virtual environment, run `R -e "install.packages('IRkernel')"`, then `R -e "IRkernel::installspec()"`, then `jupyter notebook sol_exercise_py.ipynb --kernel=ir`. :construction: You might need to install additional packages via `R -e "install.packages('package')"`; ideally, the kernel should be created using `exercises/R-i2ml.yml`--making this work (and updating the requirements) is an open issue.
    - Remember to update `exercises/chapter/ex_exercise_py.ipynb` after editing `exercises/chapter/sol_exercise_py.ipynb` (KI campus demands these empty exercise notebooks; feel free to come up with an automated process to create them from the full ones).
  
- **Compilation**. Compiling the exercises should be done via the **Makefile**.
  - Remove auxiliary files by running `make clean` from within the corresponding folder.
  - Use case 1: you want to **compile a single** exercise. Run `quarto render exercise.qmd`, possibly adding `--profile=solution` if you want solutions to be included. 
    - 1a: the above command renders to **HTML**.
    - 1b: adding `--to=pdf` renders to **PDF**.
  - Use case 2: you want to **compile all** exercises in a folder.
    - 2a: use `make exhtml` (w/o solutions) or `make solhtml` (incl. solutions).
    - 2b: use `make expdf` (w/o solutions) or `make solpdf` (incl. solutions). The resulting PDFs will be suffixed with `_ex.pdf` or `_all.pdf`.
  - Use case 3: you want to **copy all** PDFs in a folder to update the corresponding files in `exercises-pdf`. Use `make copy-all`. :warning: The [course website](https://slds-lmu.github.io/i2ml/) links to `exercises-pdf`, so make sure you only update the files in there if you want to release them on the website.
  - Use case 4: you want to **compile and copy all** exercises in a folder to update the corresponding files in `exercises-pdf`. Use `make all`. :warning: The [course website](https://slds-lmu.github.io/i2ml/) links to `exercises-pdf`, so make sure you only update the files in there if you want to release them on the website.

- **Current issues with quarto** :bug:
  - Compiling exercises w/o solution (single or all) might fail: solution notebooks are included in the YAML header but won't be used in conditional compilation, causing an error :arrow_right: wait for quarto option to handle conditionals in header / manually remove notebook from header before compilation
  - Sourcing two notebook cells in direct succession doesn't work :arrow_right: place some text in between
  - Some comments in `latex-math` files contain explanations like "theta^[t]" which quarto interprets as footnote :arrow_right: remove those in `exercises/_quarto/latex-math.qmd`

### Install Necessary R packages
- Please refer to the file `scripts/libraries_installer.R` to install the R packages necessary for running successfully some folders.

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


