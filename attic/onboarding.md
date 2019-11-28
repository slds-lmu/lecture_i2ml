# Info for Student Assistants 

We coordinate the work of all student assistants via [Github project boards](https://help.github.com/en/articles/about-project-boards). 
Bernd or Fabian will set up the project board initially and show you how it's used.  
After that it is your responsibility  

- to add any new issues or topics assigned to you to your board and
- to keep the time-tracking card (see below) up-to-date

Please read this document and the material at the links carefully and let us know right away if you have questions or can't get the technical set-up right.

## Technical Skills

You'll need to work with

- Latex
- **Git**, including Git branches and Github pull requests. 
- **`R`**, and specifically `mlr` and `knitr`/`Rmarkdown`
- **Google Slides** (... maybe)

Knowing how a `Makefile` works would be good as well, but is not strictly necessary.

## Getting started

Please read and understand the [internal README](https://github.com/compstat-lmu/lecture_i2ml/blob/master/README_intern.md) and set up your local copy of the `i2ml` repo accordingly. To be able to contribute quality content, it's probably also a good idea to first have a look at the material we already have, so please do take the time to read through the slides and have a look at the code demos and exercises if you haven't taken the course already.

## Using Git and Github the right way

To contribute to the course, please create issue-specific branches off the **`devel`** branch in the main repo in order to work on your assigned issues. A more detailed explanation of this collaboration model is [here](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow), there you also find the Git commands used to accomplish this.  

Commit early, commit often, take the time to [write informative, well-formatted commit messages](https://juffalow.com/other/write-good-git-commit-message) and [reference the issue(s)](https://guides.github.com/features/issues/#notifications) your commit is addressing in your commit message by including `#<issuenumber>` in your commit.  
At least once a week, write down how much time you spent on what topics on the *time-tracking card* in your Github project board. This might be easier if you also note the time spent on creating a commit in the body of the respective commit messages. What's important is that you keep the time-tracking card in your project board up-to-date. 

## Getting help

If you get stuck, either contact us on Slack or via the discussion section of the respective Github issue (ping one of us by including `@fabian-s` or `@bbischl` in your message) to request more info, feedback, a meeting, whatever you need.  
Some of the Github issues we assign to you may not include a very detailed description of the problem or what the solution should look like. If that's the case and you're not sure what it is you're supposed to be working on, please do insist that we give you a better description of the problem/solution instead of a) doing nothing or b) doing something that's not useful.


## Getting it done 

Once your feel you're done, [open a pull request](https://help.github.com/en/articles/creating-a-pull-request) (PR) and we'll review your changes, give feedback and eventually merge it into the main branches. If you don't get any feedback from us within a couple of days, please remind us via Slack or via the discussion section of the PR (ping one of us by including `@fabian-s` or `@bbischl` in your message).  
You can include PDF files and images in the description of your pull request, and doing so makes it a little easier for us to give you feedback on your work -- if you add them to your PR directly, we don't have to make a local copy of your work and re-create these files ourselves.  

Before you open a pull request, please do check that 

- your pull request contains all necessary files but no superfluous files
- the relevant `Makefiles`have been updated to reflect your changes as well

If your PR contains modified slides, please check that

-  the files you have modified can be rendered to PDF without Latex errors
-  the files you have modified are formatted well 
-  the slides you have modified do not contain typos (please use a spell checker!) or bad grammar
-  the slides you have modified use notation that is consistent with the rest of the slides, preferably commands/terms already defined in `latex-math`.

If your PR contains modified code, please check that

-  the code is structured well (see ["Code Smells & Feels"](https://github.com/jennybc/code-smells-and-feels) by Jenny Bryant for bad patterns to avoid)
-  the code follows the style guide (easiest to do by using `lintr` and `styler`)
-  code that is meant to be read/worked on by students is well documented
-  code that is meant to be read/worked on by students is as simple, legible and clear as possible
