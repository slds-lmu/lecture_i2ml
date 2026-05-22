# Evaluation: Measures for Regression

- Welcome back to our next unit on performance evalutation.
- In this unit we will discuss some simple measures for
  performance evaluation in regression tasks


## MEAN SQUARED ERROR

- The mean squared error is probably the most widely know
  perfromance measure. It simply takes the squared distance
between the predicted value and the actual value for each
observation and sums them up.
- The mean squared error - or MSE - is equivalent ot the
  L2-loss.
- There are simply two different words for the same thing.
  Usually we call it L2-loss if we talk about the inner loss and
we call it MSE if we talk about the outer loss.
- As the we take the SQUARED error, single observations with a
  high prediction error can have a big influence on the MSE. 
- We nicely see this here in the left plot. 
- The contribution of this left red dot is much larger than of
  the other red dot, although the absolute error is less
drastically larger.
- The right plot shows the MSE or L2-loss on the y-axis and the
  residuals on the x-axis. 
- With residuals we mean here the difference between observed
  and predicted value.
- Again, what this plot shows us, is that with increasing
  residuals, the contribution to the MSE increases heavily.
- Similar measures to the MSE are the sum of squared errors or
  the root mean squared error.
- The SSE is just the MSE times the number of observations n.
- The RMSE is like the MSE just on the original scale of the
  outcome.


## MEAN ABSOLUTE ERROR

- The mean ABSOLUTE error is also quite similare to the mean
  squared error. 
- Instead of taking the squared error, here we take the absolute
  error. 
- Using the absolute error means that large errors have a less
  heavy contribution to the evaluation measure.
- The MAE is also something we have seen before: it is
  equivalent with the L1-loss.
- Just in performance evaluation we usually call it mean
  absolute error instead of L1-loss.
- A similar measure that is even more robust, even less
  dependent on outliers, is the median absoute error. 


## R2

- The next measure we take a look at now the R-squared.
- This is a measure you might know already from a statistics
  context.
- In statistics this is usually used with the training data and
  then interpretetd as the "fraction of variance explained by
the model".
- What we actually do is we compare the sum of squared errors of
  a simple baseline model with a more complex model.
- In statistics we use it with linear models: there the simple
  baseline model is an intercept only model and the complex
model is a linear model with at least one covariate.
- If R-squrared is 1 this implies that all residuals are 0 and
  our complex model predicts perfectly.
- If R-squared is 0 this implies that we are as bad a the
  constant model.
- If computed on the training data R-squared is always between 0
  and 1.
- On different data it can also take on other values. In the
  case of overfitting we could even see negative R-squared. A
negative R-squared means that the complex model is worse than
the constant model.


## GENERALIZED R2 FOR ML

- We can take the idea of R-squared and use it in contexts other
  than linear models.
- We can, for example, set up this general formula here.
- We can generally just compare a complex model to a simpler
  model.
- Also we do not have to use the sum of squared errors.
- We can use any loss, any evaluation measure, for this
  comparison.
- We can, for example, compare a linear model to a non-linear
  model, or a tree to a forest.
- We can also compare a learner including versus excluding some
  features.
- This general idea of R-squared is not very widely used and
  pretty unknown in the machine learning community.
- The term "generalize r-squared" is also something we came up
  with.
- So if you discuss about this with colleagues in the field,
  they may not know it.
- We think, however, that this is a pretty useful measure.

