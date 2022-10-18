# SET CURRENT WORKING DIRECTORY TO THE ONE CONTAINING THIS SCRIPT
# e.g. setwd("D:/Work/I2ML/lecture_i2ml/exercises")

install.packages(c("stringr", "readr", "magrittr"))
library(magrittr)

# Get all R and Rnw files from the folder recursively
get_all_eligible_files <- function() {
  return(list.files(path = ".", pattern = "R|Rnw", recursive = TRUE))
}

res <- NULL
files <- get_all_eligible_files()

for (file in files) {
  # Read each file
  text <- readr::read_file(file)

  # Process the raw text to have the list of dependencies
  preprocessed <- stringr::str_extract_all(text, "library\\(\\w+\\)")[[1]] %>%
    stringr::str_replace_all("library\\(|\\)", "") %>%
    stringr::str_replace_all("'", "") %>%
    stringr::str_replace_all('"', "")

  res <- c(res, preprocessed)
}

# Format the resulting list of dependencies
res <- res %>% unique() %>% sort(decreasing = FALSE)

# Show the list of dependencies
print(res)

# Start installing every dependency
install.packages(res)