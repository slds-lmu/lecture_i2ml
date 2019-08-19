# find all relevant files
files <- unlist(sapply(c("\\.R$","\\.Rnw$","\\.Rmd$"),
       function(pattern) list.files(pattern = pattern, recursive = TRUE)))

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

# install missing packages 
for(pkg in matches){
  if (!(pkg %in% rownames(installed.packages()))){
    install.packages(pkg)
  }
}
