# latex-math

<!-- badges: start -->
[![render-preview](https://github.com/slds-lmu/latex-math/actions/workflows/render-preview.yaml/badge.svg)](https://github.com/slds-lmu/latex-math/actions/workflows/render-preview.yaml)
<!-- badges: end -->

The notation and shortcuts used in latex-files of lectures, papers, ... of the Chair of Statistical Learning and Data Science is defined and maintained in this repository. 
Notation & shortcuts are split into multiple files depending on subject and can be integrated as needed. 

- `basic-math`: Basic mathematical notation such as mathematical spaces, sums & products, linear algebra, basic probability and statistics
- `basic-ml`: Basic machine learning notation such as notation for data (x, y), prediction functions, likelihood, loss functions, generalization error
- `ml-ensembles`: Ensemble methods
- `ml-eval`: Evaluation metrics, resampling
- `ml-feature-sel`: Feature selection
- `ml-gp`: Gaussian processes
- `ml-hpo`: Hyperparameter optimization
- `ml-infotheory`: Information theory
- `ml-interpretable`: IML / xAI
- `ml-mbo`: Model-based optimization / Bayesian optimization
- `ml-multitarget`: Multi-target learning
- `ml-nn`: Neural networks
- `ml-online`:
- `ml-regu`: Regularization
- `ml-survival`: Survival analysis
- `ml-svm`: Support vector machines
- `ml-trees`: Decision trees


:warning: **Important Usage Note**: If you encounter these files within a lecture or project repository, **do not** make any changes locally.  
Go to [slds-lmu/latex-math](https://github.com/slds-lmu/latex-math) and make your changes either directly or via pull request.
Any local changes are assumed to be spurious and *will be overridden* with upstream `slds-lmu/latex-math`.

## Using the notation

- Clone this repository into the main directory of your repo.
- Add `latex-math` to the gitignore file. 
- Add `\input{../latex-math/<name>}`, for every file `<name>.tex` you need to the preamble of your (TeX/Rmd) file but not into any common preamble file

This means you have to keep this repository in sync with each client repository by also doing git pull in the latex-math sub-directory when pulling changes for the client repo. The reason we do it this way is that work on latex-math is not duplicated.

Note that some of the macros defined here may use additional Latex packages -- a good set to start with is

```
\usepackage{mathtools}
\usepackage{bm}      % basic-ml, ml-gp
\usepackage{siunitx} % basic-ml
\usepackage{dsfont}  % basic-math, note package is called `doublestroke` when installing via tlmgr
\usepackage{xspace}  % ml-mbo
\usepackage{xifthen} % ml-interpretable
```

See `latex-math.pdf` for all currently defined commands & definitions. 

Note that the file `preamble.tex` contains packages required for `latex-math.Rmd` to be rendered, which are not necessarily all packages you would need in a fresh LaTeX project, since RMarkdown by default includes various required packages already.

## Adding macros and files

- A new shortcut / notation that falls into the scope of one of the existing files should be added in the respective file with a short description.
- Multiple shortcuts / notations belonging to another major subject should be summarized in a new `.tex` file. 
- **Avoid** creating macros consisting of multiple previously defined macros. Macros should
    - be easy to remember
    - be used often enough to warrant a shortcut
    - avoid inter-dependencies between macros and `.tex` files
    - be added sparingly to avoid clutter
- **ALWAYS** check if a command is already contained in one of the files - overwriting a command might result in compiling errors.  
- **ALWAYS recompile `latex-math.Rmd` if you add new commands so it is kept up-to-date and to check that you have committed all the changes your notation requires to work.**
- If you **add a new file**, make sure it is added as an `include` in the header of `latex-math.Rmd` such that it is included in the rendered preview

## Updating `latex-math` in lectures

Refer to the [Teaching DevOps wiki entry](https://github.com/slds-lmu/lecture_service/wiki/latex-math) for detailed instructions.

## Building

Use the included `Makefile` to render `latex-math.pdf` and to create the combined .tex file `latex-math-combined.tex`:

```sh
Usage: make <target>:

  pdf:      render latex-math.Rmd to latex-math.pdf
  combined: create the combined tex file latex-math-combined.tex
  clean:    remove latex-math.pdf and latex-math-combined.tex
  all:      render latex-math.Rmd to latex-math.pdf and create the combined tex file latex-math-combined.tex
  help:     show this message
```
