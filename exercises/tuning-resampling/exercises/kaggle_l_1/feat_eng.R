task_eng = task$clone()

task_eng$col_roles$feature = c(task_eng$feature_names, c("Cabin", "Name", "Ticket"))

po_ftextract = po("mutate", param_vals = list(
  mutation = list(
    fare_per_person = ~ Fare / (Parch + SibSp + 1),
    deck = ~ factor(stri_sub(Cabin, 1, 1)),
    title = ~ factor(stri_match(Name, regex = ", (.*)\\.")[, 2]),
    surname = ~ factor(stri_match(Name, regex = "(.*),")[, 2]),
    ticket_prefix = ~ factor(stri_replace_all_fixed(stri_trim(stri_match(Ticket, regex = "(.*) ")[, 2]), ".", ""))
  )
))

task_eng = po_ftextract$train(list(task_eng))[[1]]
task_eng$select(cols = setdiff(task_eng$feature_names, c("Cabin", "Name", "Ticket")))
task_eng$id = "titanic (engineered)"
