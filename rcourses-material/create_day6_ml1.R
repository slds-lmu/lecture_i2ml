# ============================================================================ #
#                                MUNICH RE DAY 6                               #
#                                                                              #
#     - Lecture 1: Machine Learning Basics                                     #
#        * (20 min) Introduction, Classification and Regression                #
#        * (20 min) ML as Black-Box Modeling, ML = Representation + Loss +     #
#                   Optimization                                               #
#        * (20 min) KNN                                                        #
#        * (20 min) LM                                                         #
#        * (20 min) Differences between Machine Learning and Statistics        #
#                                                                              #
#     - Lecture 2: Trees and Forest (each 45 min)                              #
#                                                                              #
#     - Lecture 3: Model Evaluation                                            #
#        * (15 min) Performance Metrics                                        #
#        * (30 min) Train and Test Error,                                      #
#                                                                              #
# ============================================================================ #

# Source some functions:
source(file = "courses/_setup/create_course_functions.R")

# Structure:
# --------------------

# Lecture 1:
day6_lec1 = list(
  "What is Machine Learning" = list(
    "intro_ml_1"
    # , "intro_ml_2"
    , "question_data_task"
    , "intro_tasks_regr"
    # , "boston_housing_data"
    # , "iris_data"
    , "model_inducer_hypospace"
    # , "intro_ml_workflow"
    , "domingo"
  )
  , "Supervised Learning" = list(
    "suplearn_lossmin"
  )
  , "The Linear Model" = list(
    "sm_lm_01_intro"
    , "sm_lm_02_risk_minimization"
  )
  , "Classification" = list(
     "intro_tasks_classif"
    , "what_is_classif"
  )
  , "K-Nearest Neighbors" = list(
    "suplearn_geometric"
    , "sm_knn"
  )
  , "ML vs. Statistics" = list(
    "phylosophies_two_cultures"
   )
)

# Lecture 2:
day6_lec2 = list(
  "Performance Metrics" = list(
    "measures"
  )
  , "Train and Test Error" = list(
      "resampling_train_test"
      , "resampling_repeats"
  )
  , "Overfitting" = list("ml_overfitting")

)

# Lecture 3:
day6_lec3 = list(
  "Trees" = list(
    "cart_01_intro"
    , "cart_02_splitting"
    , "cart_03_stopping"
    # , "cart_03_pruning"
    # , "cart_04_feature"
    , "cart_06_dis_advantages"
    )
    , "Random Forest" = list(
    "random_forests"
    , "random_forest_vi"
    , "random_forests_adv_disadv"
  )
  , "R package mlr" = list("mlr_motivation")
)

# Data appendix:
data_appendix = list(
  "Used Datasets" = list(
    "iris_data", "boston_housing_data", "spam_data"
  )
)

# TODOs
# -------------------

# (1) Train test schoene Grafik wo man sieht wie train und test error aueinandergehen
# (2) Overview Chunks ueber Performance-Masse

# Render lectures:
# -------------------

createCourseHelper = function(ss, header) {

  course.name = as.character(substitute(ss))

  createCourse(
    title            = header
    # , yaml.subtitle  = yaml.subtitle
    , course         = "inhouse_mucre"
    , file.name      = course.name
    , subtitles      = names(ss)
    , author         = "Prof. Dr. Bernd Bischl"
    , course.date    = "10. September 2018"
    , year           = "day"
    , month          = "6"
    , render         = TRUE
    , course.list    = ss
    , reset.exercise = FALSE
    , open.pdf       = FALSE
    , scope          = FALSE
    # , keep.source    = TRUE
    , template       = "preamble_munichre.sty"
  )
}

createCourseHelper(day6_lec1, "Machine Learning Basics")
createCourseHelper(day6_lec2, "Model Evaluation")
createCourseHelper(day6_lec3, "Trees and Random Forest")
createCourseHelper(data_appendix, "Data Appendix")

# renderFile("question_data_task", open.file = FALSE, template = "preamble_munichre.sty")
