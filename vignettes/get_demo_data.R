library("Hmisc")

demos <- c(
  "limo", "knn", "splines",
  "logreg", "cmpclass", "genclass",
  "resampling", "overfitting", "roc",
  "cart", "randforests"
)
topics <- c(
  rep("Supervised: Regression", 3),
  rep("Supervised: Classification", 3),
  rep("Evaluation", 3),
  "CART",
  "Random Forest"
)


cddat <- data.frame(ID = seq_along(demos), Topic = topics, demo_file = demos)

## Get names of all code demo Rmd files
# rmds_link <- list.files(path = "../code-demos", pattern = "code_demo.*.Rmd$", full.names = TRUE)
# rmds <- list.files(path = "../code-demos", pattern = "code_demo.*.Rmd$", full.names = FALSE)
rmds_link <- paste0("../code-demos/code_demo_", demos, ".Rmd")
cddat$Rmd <- paste0(
  "[Rmd](https://github.com/compstat-lmu/lecture_i2ml/tree/master/code-demos/code_demo_", 
  demos, ".Rmd)")
cddat$PDF <- paste0("[pdf](https://nbviewer.jupyter.org/github/compstat-lmu/lecture_i2ml/blob/master/code-demo-pdf/code_demo_", 
                    demos, ".pdf)")



## Read the title lines from the files
lns <- lapply(rmds_link, readLines, n = 7)
titles_raw <- sapply(lns, grep, patter = "*.set_title.*", value = TRUE)

## Create a clean, capitalized title
titles_small <- gsub(pattern = '.*Code [Dd]emo [Ff]or |.*Code [Dd]emo [Aa]bout |"', replacement = "", titles_raw)
cddat$Demo <- capitalize(titles_small)



