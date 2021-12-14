library(mlr3)

make_spam_df <- function() {
  spam <- mlr_tasks$get("spam")$data()
  spam$type <- fct_rev(spam$type)

  # cherry pick some good examples
  idx <- which(spam$type == "spam" & spam$charExclamation <= 0.5  &
                spam$charExclamation != 0.25 & spam$capitalAve <= 5 &
                spam$charExclamation > 0)
  set.seed(237)
  idx <- sample(idx)[1:10]
  idx <- c(idx, which(spam$type == "nonspam" & spam$charExclamation <= 0.5 & spam$capitalAve <= 5 & spam$charExclamation > 0)[5:15])

  df <- spam[idx, ]
  df
}