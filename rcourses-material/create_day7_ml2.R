# ============================================================================ #
#                                MUNICH RE DAY 7                               #
#                                                                              #
#     - Lecture 1: Curse of Dimensionality and Regularization                  #
#        * Curse of dimensionality                                             #
#        * Examples / Counter-Intuitive Problems                               #
#        * Regularization                                                      #
#        * Ridge and Lasso with the linear model                               #
#                                                                              #
#     - Lecture 2: Tuning and Nested Resampling                                #
#        * (30 min) Hyperparameter tuning: Grid Search + Random Search,        #
#                   Reference more advanced methods                            #
#        * (30 min) Nested Resampling                                          #
#                                                                              #
#     - Lecture 3: Imbalanced Binary Problems                                  #
#        * ROC Analysis                                                        #
#        * Imbalance correction                                                #
#                                                                              #
#     - Lecture 4: Boosting                                                    #
#        * Gradient boosting                                                   #
#        * XGBoost                                                             #
#        * Model based Boosting                                                #
#                                                                              #
# ============================================================================ #

# Source some functions:
source(file = "courses/_setup/create_course_functions.R")

# Structure:
# --------------------

# Lecture 1:
day7_lec1 = list(
  "Curse of Dimensionality" = list(
    "curse_of_dim"
  )
  , "Regularization" = list(
    "ml_regularization"
  )
)

# Lecture 2:
day7_lec2 = list(
  "Hyperparameter Tuning" = list(
    "tuning_2"
  )
  , "Nested Resampling" = list(
    "nested_resampling_01_intro"
    , "nested_resampling_02_example"
    , "nested_resampling_03"
  )
)

# Lecture 3:
day7_lec3 = list(
  "ROC Analysis" = list(
    "roc"
  )
  , "Imbalance Correction"  = list(
    "imbalanced"
  )
)

# Lecture 4:
day7_lec4 = list(
  "Boosting" = list(
    "boosting"
    , "gradient_boosting"
    , "autoxgboost"
    , "mboost"
  )
)

# Render lectures:
# -------------------

createCourseHelper = function(ss, header) {

  course.name = as.character(substitute(ss))

  createCourse(
    title            = header
    , course         = "inhouse_mucre"
    , file.name      = course.name
    , subtitles      = names(ss)
    , author         = "Prof. Dr. Bernd Bischl"
    , course.date    = "11. September 2018"
    , year           = "day"
    , month          = "7"
    , render         = TRUE
    , course.list    = ss
    , reset.exercise = FALSE
    , open.pdf       = FALSE
    , scope          = FALSE
    # , keep.source    = TRUE,
    , template       = "preamble_munichre.sty"
  )
}

createCourseHelper(day7_lec1, "Curse of Dimensionality and Regularization")
createCourseHelper(day7_lec2, "Tuning and Nested Resampling")
createCourseHelper(day7_lec3, "Imbalanced Binary Problems")
createCourseHelper(day7_lec4, "Gradient Boosting")


# renderFile("roc", template = "preamble_munichre.sty")
