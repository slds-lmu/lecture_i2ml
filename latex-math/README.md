# latex-math

<!-- badges: start -->
[![render-preview](https://github.com/slds-lmu/latex-math/actions/workflows/render-preview.yaml/badge.svg)](https://github.com/slds-lmu/latex-math/actions/workflows/render-preview.yaml)
<!-- badges: end -->

The notation and shortcuts used in latex-files of lectures, papers, ... of the Chair of Statistical Learning and Data Science is defined and maintained in this repository. 
Notation & shortcuts are split into multiple files depending on subject and can be integrated as needed. 

+ `basic-math`: basic mathematical notation such as mathematical spaces, sums & products, linear algebra, basic probability and statistics
+ `basic-ml`: basic machine learning notation such as notation for data (x, y), prediction functions, likelihood, loss functions, generalization error
+ `ml-nn`: neural networks
+ `ml-svm`: support vector machines
+ `ml-trees`: decision trees
+ `ml-interpretable`: IML / xAI

:warning: **Important Usage Note**: If you encounter these files within a lecture or project repository, do not make any changes locally. Go to [slds-lmu/latex-math](https://github.com/slds-lmu/latex-math) and make your changes either directly or via pull request.
Any local changes are assumed to be spurious and *will be overridden* with upstream `slds-lmu/latex-math`.

## Using the notation

- Clone this repository into the main directory of your repo.
- Add `latex-math` to the gitignore file. 
- Add \input{../latex-math/\*}, for every file /\* you need to the preamble of your (TeX/Rmd) file but not into any common preamble file

This means you have to keep this repository in sync with each client repository by also doing git pull in the latex-math subdirectory when pulling changes for the client repo. The reason we do it this way is that work on latex-math is not duplicated.

Note that some of the macros defined here may use additional Latex packages -- a good set to start with is

```
\usepackage{mathtools}
\usepackage{bm}      % basic-ml, ml-gp
\usepackage{siunitx} % basic-ml
\usepackage{dsfont}  % basic-math
\usepackage{xspace}  % ml-mbo
\usepackage{xifthen} % ml-interpretable
```

See `latex-math.pdf` for all currently defined commands & definitions. 

## Updating / adding files

- A new shortcut / notation that falls into the scope of one of the existing files should be added in the respective file with a short description.
- Multiple shortcuts / notations belonging to another major subject should be summarized in a new .tex file. 
- **ALWAYS** check if a command is already contained in one of the files - overwriting a command might result in compiling errors.  
- **ALWAYS recompile `latex-math.Rmd` if you add new commands so it is kept up-to-date and to check that you have committed all the changes your notation requires to work.**

To ensure recompilation is not forgotten, please install the pre-commit hook:

```sh
cp service/pre-commit-check-pdf .git/hooks/pre-commit
```
