# Evaluation: Overfitting

- Welcome to our next unit on performance evaluation in machine
  learning.
- This unit will discuss a common issue in machine learning,
  which we want to try to avoid: overfitting.


## OVERFITTING

- What is overfitting actually?
- Overfitting means, that our model does not learn the
  underlying data generating process, but instead learns how to
optimally fit to the training data.
- This results in a bad generalization error.
- Look at this example here:
- On the two axes of the plot we have two features x1 and x2.
  The color shows our predicted classes.
- The shapes show the actual class.
- In the left plot we see that the prediction is very much
  focussed on the individual observations. This looks like
overfitting.
- The right plot shows a different model.
- The model in the left plot will show great performance on the
  training set, but will be bad if evaluated on a test set.
- The model in the right plot will probably do much better in a
  test set.


## OVERFITTING

- Overfitting is a well-known problem in ML for non-linear,
  powerful learning algorithms
- It happens when your algorithm starts modelling patterns in
  the data that are not actually true in the real world, for
example, noise or artefacts in the training data
- Overfitting happens when you have too many hypotheses and not
  enough data to tell them apart
- Overfitting is less of an issue in big data sets. The more
  data, the more "bad" hypotheses are eliminated
- But: If the hypothesis space is not constrained, there may
  never be enough data to avoid overfitting. 
- So the rule with the more data the better only works, if we
  have a constrained set of models.
- There is often a parameter that allows you to constrain the
  learner
- If you, for example, reduce the number of trees in a forest,
  this constraines the complexity of the forest.
- If you reduce the number of polynomial degrees in polynomial
  regression, you constrain the complexity of the model, and
with that reduce the chance of overfitting.
- Of course, if the model is oversimplistic, this is also a
  problem. This is then called underfitting.
- In this unit we will only give a very basic definition, and
  not really talk about measures against overfitting. So
regularization is not a topic here.
- To check if overfitting is an issue in your case, evaluate
  your model using an independent test data set.


## TRADE-OFF BETWEEN GENERALIZATION ERROR AND COMPLEXITY

- This graph visualizes nicely, why an independent test data set
  is needed to detect overfitting.
- On the y-axis we have the error.
- On the x-axis the complexity of the model.
- This can be for example the number of trees and their depth in
  a forest or the number of features used in a regression model.
- The two curves show the actual, true, error and the apparent
  error.
- The apparent error is the error that we compute using the
  training data. So for example R-squared or MSE in the data set
used for training the model.
- The apparent error goes down with increasing complexity, while
  the actual error first goes down and the back up.
- The reason why it goes up at some point is that the model fits
  too well to the training data only and does not generalize to
new data any longer. 
- It overfits.
- So what we need to do is find this sweet spot in the middle,
  where the model is complex enough but not too complex.
- We need to find the point where the generalization error
  becomes minimal.


