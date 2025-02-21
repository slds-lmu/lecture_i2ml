# Find all .tex files starting with `basic-` or `ml-`
# !! If new file prefixes are added, they must be added to the regex pattern
texfiles <- list.files(pattern = "(ml|basic)-.*\\.tex")

combined <- vapply(seq_along(texfiles), \(i) {
  lines <- readLines(texfiles[[i]])
  chunk <- paste(lines, collapse = "\n")
  chunk <- paste0(chunk, "\n")

  paste(
    sprintf("%% ------------- %s -------------", basename(texfiles[[i]])),
    chunk,
    sep = "\n\n"
  )
}, character(1))


writeLines(combined, "combined.tex")

# MathJax etc. don't know these commands from doublestroke (ds) and bm packages
combined <- stringr::str_replace_all(combined, pattern = r"(\\mathds\{)", replacement = r"(\\mathbb{)")
combined <- stringr::str_replace_all(combined, pattern = r"(\\bm\{)", replacement = r"(\\boldsymbol{)")

combined <- paste0(
  "$$",
  paste(combined, collapse = "\n"),
  "$$",
  sep = "\n"
)

writeLines(combined, "combined.qmd")
