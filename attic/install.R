# find all relevant files
exts <- c("*.Rmd", "*.Rnw", "*.R")
files <- unlist(sapply(exts, 
                function(glob) 
                  as.character(fs::dir_ls(path = "..", recurse = TRUE, glob = glob))))


matches <- c("")
patterns <- c('(?<=library\\().*(?=\\))',
              '(?<=require\\().*(?=\\))')
# collect packages
for(file in files){
  for(pattern in patterns){
    rx <- regexpr(pattern, text=readLines(file), perl=TRUE)
    matches <- c(matches, substring(readLines(file), rx, rx+attr(rx, "match.length")-1))
  }
}

# cleanup the packages which were found
matches <- gsub( "[\'\\\"]", '', matches)
matches <- unique(matches)
matches <- matches[which(matches != "")]

missing <- sort(matches[!(matches %in% rownames(installed.packages()))])
if (length(missing)) {
  cat("missing packages:")
  print(missing)
  install.packages(missing)
} else {
  cat("seems like all packages are there...")
}



