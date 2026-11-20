# Evaluation: Test Error

- Welcome to a new unit on performance evaluation in machine learningn. 
- In this unit we will talk about the test error.



## TEST ERROR

- Other than the training error, the test error is computed on
  new, unseen data.
- Data which was not used in training. 
- This data is called "test data".
- So now what we do is we fit the model using the training data.
- Then we predict the outcome on the test data and evaluate how
  well we did.


## TEST ERROR AND HOLD-OUT SPLITTING

- What we usually do to obtain the two data sets, is we split the data set we have into 2 parts.
- For example we could use 2/3 for training and 1/3 for testing.
- We use the training data for training only.
- And we use the test data for testing only.
- This way we do not get the problems as in the training error, where we support overfitting. 
- The test error will be able to detect overfitting issues.


## TEST ERROR

- We consider an example where we have a sinusoidal function plus some measurement error epsilon.
- From this function we draw data: a training set and a test set.
- The line shows the sinusoidal function without error.
- The dots are the data points from the two respective samples
- We try to fit polyniomial models to the data.


## TEST ERROR

- The figure shows three possible models.
- Below the figure we see the mean squared error calculated on the training data.
- The linear model in purple is clearly not a good option.
- The model with a degree of 3 seems to be fine. 
- Both from the figure and the test MSE.
- The blue line looks fairly similar to the grey line, which shows the true underlying structure.
- The green line is too wiggly. It tries to go through the dots of the training data.
- The test MSE shows that even if the line might fit very well to the training data, it doesn't fit well to the test data.


## TEST ERROR PROBLEMS

- We can try to plot the MSE for several polynomial degrees up to d=9.
- On the y-axis we have the MSE, on th x-axis the degree.
- The grey dots and lines show the test error, the black show the training error.
- We see that for small degrees, the training and test error are almost the same.
- At some point though, the test error goes up, while the training error keeps going down.
- The lower the complexity of our model, the higher the bias of our estimate. 
- In our example we clearly saw that the linear model was doing a poor job.
- The variance, however, is usually lower with less complex models.
- With increase in model complexity, we usually see a decrease in bias, but an increase in variance.
- Too complex models overfit the data.
- This here is just an example, but we usually see that with increasing model complexity, the training error keeps decreasing, while the test error first goes down and the starts going up again at some point, due to overfitting. 
- The sweet spot is somewhere in between and has to be estimated.


## TEST ERROR PROBLEMS

- Now, even though the test error solves the issues of the the
  training error, it is not perfect.
- If we have an independent test set, we need this to come from
  the same data generating process.
- Imagine you try to predict rent prices. 
- Your training data is from Munich and your test data from
  Instanbul.
- The rent situation in these two cities are completely
  different, which means the data generating process is
different and the data points are hence not iid.
- You will not be able to get a good estimate of your
  generalization error.
- Another problem is the hold-out splitting: you have a data set
  of a certain sample size.
- By splitting that data set into training and test set, you
  have less observations for training.
- This usually means you have a worse model.
- This is especially a problem when you have few data points to
  begin with.
- It does, however, not only have a negative impact on the
  model, but also on the generalization error estimate.
- The smaller the test set, the higher the variance of the
  estimate.
- Finally, we have the issue, that usually our holdout set, our
  test set, is chosen randomly. By chance the test set can be
quite strange. Maybe we end up with only observations at one end
of the distribution.
- In the rent example, we might end up with only really small
  but pricey appartments.
- The chance of that happening increases with decreasing sample
  size. 


## TEST ERROR PROBLEMS

- In ML we are in a weird situation. We are usually given one
  data set. At the end of our model selection and evaluation
process we will likely fit one model on exactly that complete
data set. As training error evaluation does not work, we have
nothing left to evaluate exactly that model.
- Holdout splitting (and resampling) are tools to estimate the
  future performance. All of the models produced during that
phase of evaluation are intermediate results.
- Keep that already in mind now, it will help to avoid confusion
  when we move on to related concepts like cross-validation.
