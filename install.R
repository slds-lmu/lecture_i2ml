library(magrittr)
library(purrr)
library(stringr)

# find all relevant files: 
files <- unlist(sapply(c("\\.R$","\\.Rnw$","\\.Rmd$"),
       function(pattern) list.files(pattern = pattern, recursive = TRUE)))

patterns <- c('library\\(([a-zA-Z0-9]+)',
              'require\\(([a-zA-Z0-9]+)',
              '([a-zA-Z0-9]+)::')

used_packages <- map(files, function(f) {
  text <- readLines(f)
  map(patterns, ~ stringr::str_match_all(pattern = .x, text)) %>%
    flatten %>% discard( ~ nrow(.x) == 0) %>% map(~ .x[, 2]) %>% 
    unlist %>%  unique
}) %>% unlist %>%  unique %>% sort
                
message("Used packages:\n",  paste(used_packages, collapse = ", "))

installed <- rownames(installed.packages())
missing_packages <- setdiff(used_packages, installed)

message("Currently not installed:\n",  paste(missing_packages, collapse = ", "))
if (readline("Install missing packages now? (y/n)") == "y") {
  for (m in missing_packages) try(install.packages(m))
}

