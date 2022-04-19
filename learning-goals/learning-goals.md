## Learning Goals 

This is a comprehensive compilation of the learning goals of this course, ordered by chapter.

### ML Basics

- Understand the goal of supervised learning and the difference to unsupervised learning
- Understand the difference of target and feature variables and know the definition of labeled and unlabeled data
- Know the basic tasks in supervised learning: regression and classification
- Understand the concept of hypothesis space and why and how parameterizations of models are useful
- Understand the concept of empirical risk minimization and how loss and risk work together
- Understand the basic concept of optimization
- Understand why it is useful to think of learning as combination of hypothesis space, risk and optimization

### Supervised Regression

- Understand the definitions and differences between L1 and L2 loss
- Know hypothesis space, risk and optimization for the linear model and understand how the choice of the loss function affects the result
- Understand how to add flexibility to the linear model by using polynomials

### Supervised Classification

- Understand the difference between regression and classification
- Understand why classification models have a score / probability as output and not a class
- Know the difference between generative and discriminant approaches
- Know the definition of a linear classifier
- Understand the idea of logistic regression
- Understand the ideas, parallels and differences of LDA, QDA and Naive Bayes
- Know for which of the treated models an optimization step is necessary

### Performance Evaluation

- Understand the difference between outer and inner loss
- Understand the connections of MSE and MAE to L2 and L1 loss
- Understand the entries of a confusion matrix
- Understand the different measures computable from a confusion matrix
- Understand the ROC curve
- Understand the definition of AUC and what a certain value of AUC means (and what not!)
- Understand what overfitting is and why it is a problem
- Understand why training error is no reliable estimator of future performance
- Understand how overfitting can be seen in the test error
- Understand how resampling techniques extend the idea of simple train-test splits
- Understand the ideas of cross-validation, bootstrap and subsampling

### k-Nearest Neighbors (k-NN)

- Understand the idea of k-NN regression and why this model has no optimization step
- Understand that k-NN is a non-parametric, local model
- Know different distance measures for different scales of feature variables

### Classification and Regression Trees (CART)

- Understand the basic structure of a tree model and how a new observation is predicted via CART
- Understand how split points are derived via empirical risk
- Know which losses can be applied for regression and classification, respectively
- Know how monotone feature transformations affect the tree
- Understand how nominal features and missing values can be treated in a CART
- Understand the necessity and idea of pruning
- Know how CART can be expressed in terms of hypothesis space, risk and optimization

### Random Forests

- Understand the basic idea of bagging
- Understand how a prediction is computed for bagging
- Know how random forests are defined by extending the idea of bagging
- Understand for which kind of learners bagging can improve predictive power
- Understand that the goal of defining variable importance is to enhance interpretability of the random forest
- Understand how a random forest can be used to define proximities of observations and how these proximities can be used
- Be able to explain random forests in terms of hypothesis space, risk and optimization

### Tuning

- Understand the differencebetween model parameters and hyperparameters
- Know different types of hyperparameters
- Be able to explain the goal of hyperparameter tuning
- Understand tuning as a bi-level optimization problem
- Know the components of a tuning problem
- Be able to explain what makes tuning a complex problem
- Understand the idea of grid search
- Understand the idea of random search
- Be able to discuss advantages and disadvantages of the two methods

### Nested Resampling

- Understand the problem of overtuning
- Be able to explain the untouched test set principle and how it motivates the idea of nested resampling
- Understand how to fulfill the untouched test set principle by a 3-way split of the data
- Understand how thereby the tuning step can be seen as part of a more complex training procedure
- Understand how the 3-way split of the data can be generalized to nested resampling
- Understand the goal of nested resampling
- Be able to explain how resampling allows to estimate the generalization error

### mlr3

- Be able to apply the learned concepts in R with the package mlr3
- Understand how mlr3 can be used to conduct tuning efficiently and effectively
- Understand how mlr3 pipelines package all important machine learning steps into one object