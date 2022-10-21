# SET CURRENT WORKING DIRECTORY TO THE ONE CONTAINING THIS SCRIPT
# e.g. setwd("D:/Work/I2ML/lecture_i2ml/exercises")

# Get all R and Rnw files from the folder recursively
get_all_eligible_files <- function() {
  return(list.files(path = ".", pattern = "R|Rnw", recursive = TRUE))
}

install_or_update_package <- function(package_name) {
  # Attempt to find the package in the file system and return a boolean
  is_package_available <- nzchar(system.file(package = package_name))

  if (is_package_available) {
    # Update package if found
    cat("Package ", package_name," is available and will possibly be updated \n")
    update.packages(oldPkgs = package_name, ask = FALSE, repos = "https://cloud.r-project.org/")
    cat("done \n")
  } else {
    # Install package if not found
    cat("Package ", package_name," is not available and will be installed \n")
    install.packages(package_name, repos = "https://cloud.r-project.org/")
    cat("done \n")
  }
}

# Install prerequisite packages
prerequisites <- c("stringr", "readr", "magrittr")
invisible(lapply(prerequisites, install_or_update_package))


library(magrittr)

package_names <- NULL
files <- get_all_eligible_files()

for (file in files) {
  # Read each file
  text <- readr::read_file(file)

  # Process the raw text to have the list of dependencies
  preprocessed <- stringr::str_extract_all(text, "library\\(\\w+\\)")[[1]] %>%
    stringr::str_replace_all("library\\(|\\)", "") %>%
    stringr::str_replace_all("'", "") %>%
    stringr::str_replace_all('"', "")

  package_names <- c(package_names, preprocessed)
}

# Format the resulting list of dependencies
package_names <- package_names %>% unique() %>% sort(decreasing = FALSE)

# Show the list of dependencies
print("The following packages will be installed/updated:")
print(package_names)

# Start installing/updating every dependency
# invisible(lapply(package_names, install_or_update_package))
lapply(package_names, install_or_update_package)
