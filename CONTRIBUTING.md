[![Build Status](https://travis-ci.com/compstat-lmu/lecture_i2ml.svg?token=yiXTK7TFAHiwv8cwsQus&branch=master)](https://travis-ci.com/compstat-lmu/lecture_i2ml)

## Introduction to Machine Learning

This repository contains the slides for the "Introduction to machine learning" course.
[See also the moodle page](https://moodle.lmu.de/course/view.php?id=3001).

## Contributing

We are happy about new contributors. If you contribute something, please feel
free to add your name to the [team](vignettes/team.Rmd).

### Git-Workflow
- Access to the `master` branch is protected, please make your own, issue-/task-specific branch **off the  `devel` branch** to work in and do a pull request once you're done. 
- Do many **small, focused, single-issue commits** with **descriptive commit messages**: each commit message should
    - refer the issue it adresses or fixes, i.e. include something like `adresses #<issuenumber>`, `closes #<issuenumber>` or similar
    - for student helpers, could/should also include the approximate amount of time spent on the work being comitted (i.e. include something like `time spent: <XX> hours`) to help with time tracking.

### Slides:

- Notation on the slides uses [`latex-math`](https://github.com/compstat-lmu/latex-math). Please do read the accompanying ReadMe and clone [`latex-math`](https://github.com/compstat-lmu/latex-math) into this repo (otherwise you will not be able to render the slides).
- Use the commands defined there, don't define your own. 
- If you have to introduce new notation/symbols you should add it to `latex-math`, after doublechecking that  
   - it is consistent with what we already have 
   - you do not use symbols we have already defined differently
- We write slides for beginners: keep it simple, keep it short
- We recommend usage of tinytex (install via `tinytex::install_tinytex()`)




### Code Snippets:

- Please follow this [style guide](https://style.tidyverse.org)
- We write code that is meant to be read/worked on by beginners: 
   - simple and legible is better than complex and elegant
   - add a lot of explanatory comments
   - use base-R as much as possible
   - choose variable names and code designs to maximize legibility and comprehension

## Code Demos

now in `/code-demos`. Originals at [this link](https://github.com/compstat-lmu/lecture_intro_to_ml_notebooks)

## Creating Lecture Videos

- Software: vokoscreen (Linux)
- Format: mkv
- Frames:25
- Videocodec: H.264 (High Profile)    (in vokoscreen: libx264)  
  (Day 1/2: H264 MPEG-4 AVC)
- Audiocodec: MPEG-1 Layer 3 (MP3) (in vokoscreen: libmp3lame)  
  (Day 1/2: MPEG Audio Layer 1/2 (mp4a) from kazam)
- Resolution: 1920 x 1080 (Day 1/2: 1280 x 760 from kazam)




