library("Hmisc")

## Get demo order from Makefile
mlns <- readLines("../code-demos/Makefile")
demos_raw <- grep(pattern = "SLOT*.=", mlns, value = TRUE)
demos <- gsub(pattern = "SLOT*.=", replacement = "", demos_raw)
cddat <- data.frame(ID = seq_along(demos), demo_file = demos)

## Get names of all code demo Rmd files
# rmds_link <- list.files(path = "../code-demos", pattern = "code_demo.*.Rmd$", full.names = TRUE)
# rmds <- list.files(path = "../code-demos", pattern = "code_demo.*.Rmd$", full.names = FALSE)
rmds_link <- paste0("https://github.com/compstat-lmu/lecture_i2ml/tree/master/code-demos/", demos, ".Rmd")
cddat$Rmd <- paste0("[Rmd](../", rmds_link, ")")


## Read the title lines from the files
lns <- lapply(rmds_link, readLines, n = 7)
titles_raw <- sapply(lns, grep, patter = "*.set_title.*", value = TRUE)

## Create a clean, capitalized title
titles_small <- gsub(pattern = '.*Code demo for |.*Code demo about |"', replacement = "", titles_raw)
cddat$Demo <- capitalize(titles_small)



