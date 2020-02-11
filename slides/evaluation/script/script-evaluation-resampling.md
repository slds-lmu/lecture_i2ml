# Evaluation: Resampling

- Welcome to our next part on evaluating machine learning
  models.
- This unit is on resampling, which is an alternative to
  hold-out splitting which we disuccessed in the test data unit.
- We learned that using hold-out training and test splits is
  much better than estimating the generalization error by using
the training data.
- We also learned about the problem that we get a bad estimate
  if the test set is too small.
- In this unit we will try to solve this issue.


## RESAMPLING

- The aim of resampling strategies is to assess the performance
  of learning algorithms in a efficient and unbiased fashion.
- Resampling tries to use the available data more efficiently
  than a simple train-test split.
- Instead in resampling we reapeatedly split the data into
  training and test data and then average the results we get in
the repetitions.
- So what we do is we make the training set pretty large. The
  high variability in the test error is mitigated by doing
several repetitions and averaging over them.
- In principle we do the same as in holdout-splitting. Just we
  do it severalt times.
- There are different techniques how we can organize these
  repetitions.
- Here we will discuss "cross-validation", "bootstrap", and
  "subsampling" as three very common techniques.


## CROSS-VALIDATION

- In cross-validation we split the data into k roughly equally
  sized partitions or folds.
- We use each part once as a test set.
- The respective remaining parts are then the training set.
- This way we obtain k test errors, k measures.
- We average over them to get a stable result.
- The size of the training and test sets depends on the size of
  the data and the number of folds. 
- The more folds, the smaller is the test set and the larger is
  the training set in each iteration.
- If we have 3 folds, we call this type of cross-validation
  3-fold cross-validation.
- Here we see an example of 3-fold cross-validation. 
- We split the data into 3 parts.
- In the first iteration we use the first two parts as training
  data, train the model on that data, and evaluate it using the
remaining third part.
- In the next iteration we choose two other parts as training
  data. The second and the third.
- In the third iteration we choose the 1st and the third parts
  as training data.
- In each iteration we train the model on two parts and evaluate
  on the remaining.
- This way, in 3-fold cross-validation, we get 3 error
  estimates, over which we average.
- In 5-fold cross-validatione, we would get 5 error estimates;
  in 10-fold, 10; and so on.


## CROSS-VALIDATION - STRATIFICATION

- If there is imbalanced class distribution, one may want to do
  a variation of cross-validation. 
- Stratification in cross-validation tries to keep the
  distribution of the target class in each fold.
- So in this example here, the proportion of orange and blue
  class are allways the same in each fold.
- There are some other variations to cross-validation, which you
  need if you have, for example groups such as different
hospitals or countries.
- Also repeated cross-validation has proven a useful strategy to
  even further reduce variability issues.


## CROSS-VALIDATION - COMMENTS

- Before we move on to the next technique, let me leave you with
  some comments on cross-validation.
- If you do not know what number of folds to use, pick one of
  the most common strategies: 5 or 10 folds are usually a good
choice. Sometimes a small number of folds results in issues with
the size of the training data. So if you run into convergence
issues, try increasing k.
- If you increas k so much that it equals the number of
  observations, your test set is of size 1.
- This is known as leave-one-out cross-validation and not
  recommended, as research suggests that LOO has bad behaviour
in many situations.
- In general, we can expect that the generalisation error
  estimates resulting from cross-validation tend to be
pessimistically biased.
- Our final estimate will probably be worse than the true error
  as we only use a subset of the data for computing the model.
- With smaller k this bias gets worse.
- Another issue is that the k training sets have overlapping
  observations. For this reason, the performance estimates are
not independent. 
- This means, that for very large k, the variance of the
  estimator gets worse and worse, because training set nearly
completely overlap and the test set gets very small at the same
time.
- If time permits, we recommend doing repeated cross-validation
  with differing splits. This has been shown to improve the
variability of error estimates and thus improves error
estimation. Particularly in small samples.


## BOOTSTRAP

- The basic idea of bootstrap is to randomly draw B training
  sets of size n with replacement from our data set.
- Let's go through that step by step.
- In our first iteration we draw n observations from our data
  set.
- We draw with replacement.
- Otherwise we would of course get the same data set just in a
  different order ;)
- This means, we have some observations twice or even more often
  in our new data set.
- Some observations do not make it into the new data set. We
  call these observations "out-of-bag" or "out-of-bootstrap"
observations.
- In this pictogram here, Dtrain is our original data set.
- Each colored ball represents one observation.
- The first bootstrap sample contains the red ball twice, and
  the blue and black ball once.
- The green ball is an out-of-bag observation here.
- We use this new data set to compute our model.
- The out-of-bag observations represent the test data.
- We repeat this procedure B times.



## BOOTSTRAP

- Typically, B, so the number of iterations, is between 30 and
  200, depending on how much time or computing power one has.
- The variance of the bootstrap estimator tends to be smaller
  than the variance of k-fold CV, as training sets are
independently drawn, discontinuities are smoothed out.
- And we know that more iterations are in general better, as the
  variance of the estimator decreases with increasing B.
- As in cross-validation and hold-out splitting we get a
  pessimistically biased sample.
- In Bootstrap we also just use a subset of the original data.
  On average it is 63.2%.
- One really nice thing about the bootstrapping framework is
  that it allows us to do inference. We can for example
calculate if there are significant performance differneces
between learners or models.
- As for cross-validation, several extensions of variants of
  bootstrap exist. We will not go into details, but examples
include B632 and B632+ which try to reduce the bias of the error
estimate, but are based on bootstrap.



## SUBSAMPLING

- The final resampling technique we want to talk about in this
  unit, is subsampling.
- In subsampling we do basically hold-out, just many times, and
  then average over the measures.
- This is also called monte-carlo cross-validation.
- It is similar to bootstrap in that it samples the training
  data from the original data.
- The difference is that we sample without replacement and we
  sample less than n observations.
- Typically we draw 4/5 or 9/10 for training.
- The remaining data is then used for testing.
- We know that also in subsampling we see a pessimistic bias, as
  we do in the other resampling techniques and in hold-out.
- We know that this problem gets worse if the number of
  observations in the training set gets smaller, so the
subsampling rate gets smaller.
- As in repeated cross-validation we can reduce the variance of
  the generalization error estimate be increasing the number or
repetitions.


## RESAMPLING DISCUSSION

- Ok, so we just learned about 3 resampling techniques for
  performance evaluation.
- Let's discuss the idea of resampling a bit before we wrap up.
- So in ML at the end we will fit one model on all of our given
  data.
- We really need to know how well this model is going to perform
  in the future because otherwise, well, we're just blind right
and we don't want to blindly trust our predictor.
- Might be that the model is behaving pretty badly and then we
  don't really want to publish or implement this.
- But if we have already used up all of the data during fitting
  and there is no data left to reliably compute the performance
metric.
- What we have to do is to approximate the performance metric
  through a different alternative process and this is what we
use resampling for.
- The idea is always to repeatedly use some part of the data for
  training and the rest for testing.
- Then we average over these repetitions.
- The downside of all resampling techniques is that we get a
  pessimistic bias in our estimate of the generalisation error.
- What is confusing for a lot of people about resampling is that
  we compute so many models, but then don't use them at the end.
- We use them just to estimate the performance, the
  generalization error.
- In the end we throw all the trained models away and recompute
  the selected learner on the entire data set.
- So what we do all the heavy computation in resampling merely
  to compute one number. 
- However this is an important number that tells us which
  learner we should use and which hyper-parameter settings we
should pick.
- Of course it's allowed to store the models you fitted in
  resampling.
- It's allowed to look at them it's maybe also allowed to worry
  a bit if you see that they are all very different and the
performance is also very different.
- But the models computed in resampling are not the main thing
  we want. We want the estimated generalisation error.


## RESAMPLING DISCUSSION

- Let's finish this unit with some practical comments.
- We already said that five or ten for cross-validation are
  somewhat standard nowadays.
- If your data set is small, it's not a very good idea to use
  something like-hold out or cross-validation with few
iterations or subsampling with a low subsampling rate.
- If you have a very small data set this can cause the estimator
  to be extremely biased.
- We recommend repeated cross-validation, especially if you have
  few observations.
- Below 500 observations is maybe a good rule of thumb.
- Be carful however, as this rule of thumb does not work if you
  have strange data sets.
- A data set that has many rows, can, for example have small
  sample properties, if, for example, only 100 observations are
from one class.
- Modern results seem to indicate that subsampling has somewhat
  better properties than bootstrapping.
- This is because of the repeated observations we have in the
  training set in bootstrapping.
- They can cause problems in training, especially in nested
  setups where the "training" set is split up again in kind of
an inner loop and then you have these repeated measurements
ending up simultaneously in training and test sets.
- This is really not a good thing because then you again have
  the problem of training on observations that are also being
used in testing.
- Sometimes repeated measurements themselves can result in
  numerical or problems for the fitting algorithm.

