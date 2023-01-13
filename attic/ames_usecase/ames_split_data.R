# read data
housing = read.csv("data/AmesHousing.csv")
# impute data
housing_numeric = housing[, !sapply(housing, is.factor)]
housing_numeric = mlr::impute(housing_numeric,
  classes = list(
  # factor = mlr::imputeMode(),
  numeric = mlr::imputeMean(),
  integer = mlr::imputeMedian()
))$data

# write.csv(housing_imputed, "data/AmesHousing_preprocessed.csv", row.names = FALSE)
# housing = read.csv("data/AmesHousing_preprocessed.csv", na.string = "")

n = nrow(housing_numeric)
# set seed and sample 2/3 for train data
set.seed(20190924)
train_ids = sort(sample(1:n, 2/3 * n))
test_ids = setdiff(1:n, train_ids)

# save train data
train = housing[train_ids, ]
train = BBmisc::dropNamed(train, "Order")
train_numeric = housing_numeric[train_ids, ]
train_numeric = BBmisc::dropNamed(train_numeric, "Order")
rownames(train) = NULL
rownames(train_numeric) = NULL
write.csv(train, "data/ames_housing_train_original.csv", row.names = FALSE)
write.csv(train_numeric, "data/ames_housing_train_numeric.csv", row.names = FALSE)

# save test data
test_df = housing[test_ids, ]
test_df_numeric = housing_numeric[test_ids, ]
test = BBmisc::dropNamed(test_df, "Order")
test_numeric = BBmisc::dropNamed(test_df_numeric, "Order")
test = BBmisc::dropNamed(test, c("SalePrice"))
test_numeric = BBmisc::dropNamed(test_numeric, c("SalePrice"))
rownames(test) = (nrow(train)+1):n
rownames(test_numeric) = (nrow(train_numeric)+1):n
write.csv(test, "data/ames_housing_test_original.csv", row.names = FALSE)
write.csv(test_numeric, "data/ames_housing_test_numeric.csv", row.names = FALSE)

# save solution file with ids
solution = test_df[, "SalePrice", drop = FALSE]
solution_numeric = test_df_numeric[, "SalePrice", drop = FALSE]
solution = cbind(row_id = (nrow(train)+1):n, response = solution)
solution_numeric = cbind(row_id = (nrow(train_numeric)+1):n, response = solution_numeric)
rownames(solution) = (nrow(train)+1):n
rownames(solution_numeric) = (nrow(train_numeric)+1):n
write.csv(solution, "data/ames_housing_solution_original.csv", row.names = FALSE)
write.csv(solution_numeric, "data/ames_housing_solution_numeric.csv", row.names = FALSE)

example_submission = solution
example_submission_numeric = solution_numeric
example_submission$SalePrice = sample(example_submission$SalePrice)
example_submission_numeric$SalePrice = sample(example_submission_numeric$SalePrice)
colnames(example_submission) = c("row_id", "response")
colnames(example_submission_numeric) = c("row_id", "response")
write.csv(example_submission, "data/ames_housing_example_submission_original.csv", row.names = FALSE)
write.csv(example_submission_numeric, "data/ames_housing_example_submission_numeric.csv", row.names = FALSE)
