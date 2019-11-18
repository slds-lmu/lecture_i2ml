[![Build Status](https://travis-ci.com/compstat-lmu/lecture_i2ml.svg?token=yiXTK7TFAHiwv8cwsQus&branch=master)](https://travis-ci.com/compstat-lmu/lecture_i2ml)

## Introduction to Machine Learning

This repository contains the slides for the "Introduction to machine learning" course.
[See also the moodle page](https://moodle.lmu.de/course/view.php?id=3001).

## Contributing

We are happy about new contributors. If you contribute something, please feel
free to add your name to the [team](vignettes/team.Rmd).

### Git-Workflow

- Access to the `master` branch is protected, please make your own, issue-/task-specific branch **off the  `devel` branch** to work in and do a pull request once you're done. 
- Do many **small, focused, single-issue commits** with **descriptive commit messages**: each commit message should refer the issue it adresses or fixes, i.e. include something like `adresses #<issuenumber>`, `closes #<issuenumber>` or similar, where applicable.

### Slides:

- Notation on the slides uses [`latex-math`](https://github.com/compstat-lmu/latex-math). Please do read the accompanying ReadMe and clone [`latex-math`](https://github.com/compstat-lmu/latex-math) into this repo (otherwise you will not be able to render the slides).
- Use the commands defined there, don't define your own. 
- If you have to introduce new notation/symbols you should add it to `latex-math`, after doublechecking that  
   - it is consistent with what we already have 
   - you do not use symbols we have already defined differently
- We write slides for beginners: keep it simple, keep it short
- Never put code on the slides, we want them to be orthogonal to issues of implementation. These are for the exercises/ practice sessions. 
- We recommend usage of tinytex (install via `tinytex::install_tinytex()`)
- Compiling the slides is easiest by using the Makefile: just type `make` in the specific folder and it will render all slidesets in the folder, or `make <SLIDES>.pdf` to render `<SLIDES>.Rnw`

### Code Snippets:

- Please follow this [style guide](https://style.tidyverse.org)
- We write code that is meant to be read/worked on by beginners: 
   - simple and legible is better than complex and elegant
   - add a lot of explanatory comments
   - use base-R as much as possible
   - choose variable names and code designs to maximize legibility and comprehension

### Code Demos

now in `/code-demos`. Originals at [this link](https://github.com/compstat-lmu/lecture_intro_to_ml_notebooks)

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




