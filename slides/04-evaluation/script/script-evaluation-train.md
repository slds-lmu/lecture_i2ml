# Evaluation: Training Error

- Welcome back to our next unit on performance evaluation in
  machine learning.
- In this unit we will discuss the training error.

## TRAINING ERROR

- In previous unit we discussed, that we want to do performance
  evaluation in order to figure out how well our model does in
prediction.
- What we want to estimate is the generalization error.
- Since we cannot compute the generalization error directly, we
  have to estimate it using data.
- One possible data set is of course the training data.
- So what we do is, we use a certain learner in combination with
  some data set D to fit a model.
- We use the model to make a prediction on this same data set D.
- From the true and predicted values, we compute our error.
- This error is called the training error, as it is computed on
  the training data.
- It is often also called the "apparent error" or
  "resubsittution error".


## EXAMPLE: POLYNOMIAL REGRESSION

- Let's look at an example, where we know the true data
  generating process.
- We sample some data from the function shown here.
- This is a sinusoidal function with some measurement error
  epsilon.
- So we know the true function is sinusoidal function shown in
  grey in the graph.
- The dots are the sampled data points.
- They do not lie exactly on the line because of the error
  epsilon.
- Now let's pretend we do not know that the data generating
  process is this function and we try to fit a model to estimate
it.
- We use a polynomial of degree "d".
- So a linear model where the covariate x is included with
  different exponents.
- Now our task is to choos an optimal complexity, an optimal
  "d".


## EXAMPLE: POLYNOMIAL REGRESSION

- Let's just try to fit different orders of the polynomial.
- They are plotted here.
- d = 1 means that we have a linear model with one covariate,
  this is the purple line shown. The MSE on the training data is
pretty high and also from the plot we see, that this is not a
great fit.
- The 3 degree polynomial looks pretty good in the graph and
  also the MSE on the training data looks ok.
- Now, when we set d to 9, the MSE on the training data goes
  down even more.
- However, when we look at the graph it seems like a pretty
  wiggly curve.
- It tries to go through all the data points.
- This is clearly overfitting the training data.
- The training error does not seem to see a problem in that.
- Of course not, because it only knows about the training data.


## TRAINING ERROR PROBLEMS

- Now what are the problems with using the training error?
- The training error is an unreliable and overly optimistic
  estimator of future performance. Modelling the training data
is not of interest, but modelling the general structure in it.
We do not want to overfit to noise or peculiarities.
- The training error of 1-Nearest-Neighbour is always zero, as
  each observation is its own Nearest-Neighbour during test time
(assuming we do not have repeated measurements with conflicting
labels).
- There are so called interpolators - such as interpolating
  splines, interpolating Gaussian processes - whose predictions
can always perfectly match the regression targets.  They are not
necessarily good in reality as they will interpolate the noise,
too.
- In statistics we use training error all the time:
  goodness-of-fit measures like the (classical) $R^2$,
likelihood, AIC, BIC, deviance are all usually based on the
training error. The don't necessarily have to be, though.
- For models of severely restricted capacity, and given enough
  data, the training error might provide reliable information.
For example, consider a linear model with 5 features, with
$10^6$ training points. But: What happens if we have less data
or as the number of features increases? It is impossible to
determine when the training error becomes unreliable.

