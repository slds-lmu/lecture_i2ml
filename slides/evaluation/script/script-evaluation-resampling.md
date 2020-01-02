# Evaluation: Resampling

- Welcome to our next part on evaluating machine
learning models.
- This unit is on resampling, which is an alternative to hold-out splitting which we disuccessed in the test data unit.
- We learned that using hold-out training and test splits is much better than estimating the generalization error by using the training data.
- We also learned about the problem that we get a bad estimate if the test set is too small.
- In this unit we will try to solve this issue.


## RESAMPLING

- The aim of resampling strategies is to assess the performance of learning algorithms in a efficient and unbiased fashion.
- Resampling tries to use the available data more efficiently than a simple train-test split.
- Instead in resampling we reapeatedly split the data into training and test data and then average the results we get in the repetitions.
- So what we do is we make the training set pretty large. The high variability in the test error is mitigated by doing several repetitions and averaging over them.
- In principle we do the same as in holdout-splitting. Just we do it severalt times.
- There are different techniques how we can organize these
  repetitions.
- Here we will discuss "cross-validation", "bootstrap", and "subsampling" as three very common techniques.


## CROSS-VALIDATION

- In cross-validation we split the data into k roughly equally
  sized partitions or folds.
- We use each part once as a test set.
- The respective remaining parts are then the training set.
- This way we obtain k test errors, k measures.
- We average over them to get a stable result.
- The size of the training and test sets depends on the size of the data and the number of folds. 
- The more folds, the smaller is the test set and the larger is the training set in each iteration.
- If we have 3 folds, we call this type of cross-validation 3-fold cross-validation.
- Here we see an example of 3-fold cross-validation. 
- We split the data into 3 parts.
- In the first iteration we use the first two parts as training data, train the model on that data, and evaluate it using the remaining third part.
- In the next iteration we choose two other parts as training data. The second and the third.
- In the third iteration we choose the 1st and the third parts as training data.
- In each iteration we train the model on two parts and evaluate on the remaining.
- This way, in 3-fold cross-validation, we get 3 error estimates, over which we average.
- In 5-fold cross-validatione, we would get 5 error estimates; in 10-fold, 10; and so on.


## CROSS-VALIDATION - STRATIFICATION

- If there is imbalanced class distribution, one may want to do a variation of cross-validation. 
- Stratification in cross-validation tries to keep the distribution of the target class in each fold.
- So in this example here, the proportion of orange and blue class are allways the same in each fold.
- There are some other variations to cross-validation, which you need if you have, for example groups such as different hospitals or countries.
- Also repeated cross-validation has proven a useful strategy to even further reduce variability issues.


## CROSS-VALIDATION - COMMENTS

- Before we move on to the next technique, let me leave you with some comments on cross-validation.
- If you do not know what number of folds to use, pick one of the most common strategies: 5 or 10 folds are usually a good choice. Sometimes a small number of folds results in issues with the size of the training data. So if you run into convergence issues, try increasing k.
- If you increas k so much that it equals the number of
  observations, your test set is of size 1.
- This is known as leave-one-out cross-validation and not recommended, as research suggests that LOO has bad behaviour in many situations.
- In general, we can expect that the generalisation error estimates resulting from cross-validation tend to be pessimistically biased.
- Our final estimate will probably be worse than the true error as we only use a subset of the data for computing the model.
- With smaller k this bias gets worse.
- Another issue is that the k training sets have overlapping observations. For this reason, the performance estimates are not independent. 
- This means, that for very large k, the variance of the estimator gets worse and worse, because training set nearly completely overlap and the test set gets very small at the same time.
- If time permits, we recommend doing repeated cross-validation with differing splits. This has been shown to improve the variability of error estimates and thus improves error estimation. Particularly in small samples.


## BOOTSTRAP

- The basic idea of bootstrap is to randomly draw B training sets of size n with replacement from our data set.
- Let's go through that step by step.
- In our first iteration we draw n observations from our data set.
- We draw with replacement.
- Otherwise we would of course get the same data set just in a different order ;)
- This means, we have some observations twice or even more often in our new data set.
- Some observations do not make it into the new data set. We call these observations "out-of-bag" or "out-of-bootstrap" observations.
- In this pictogram here, Dtrain is our original data set.
- Each colored ball represents one observation.
- The first bootstrap sample contains the red ball twice, and the blue and black ball once.
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
- In Bootstrap we also just use a subset of the original data. On average it is 63.2%.
- One really nice thing about the bootstrapping framework is that it allows us to do inference. We can for example calculate if there are significant performance differneces between learners or models.
- As for cross-validation, several extensions of variants of
  bootstrap exist. We will not go into details, but examples
include B632 and B632+ which try to reduce the bias of the error
estimate, but are based on bootstrap.


 um a second or a reserve usual extension of
normal cross-validation which is called stratification which you
very often consider if you have an imbalanced class distribution
especially for the targets so imagine for example that you have
a pretty imbalanced binary classification situation where you
have a lot more observations here in the orange class than the
blue one so what can happen now is that if you split up the data
into three different parts randomly now then just by pure chance
and I bet luck in a couple of these faults the amount of blue
observations can become even smaller as it already is just
because it was through I don't know an unbalanced partitioning
stratification and show us that in each fold and in each split
exactly the same proportion of orange and blue observations is
present and this is ensured in a very very simple manner where
instead of splitting up the complete data set into K parts we
now split up let's let's let's say we do a 3/4 cross relation
with three splits then we split up the orange part here into
three equal into three parts of equal size and we split up the
blue part here into the blue class into three parts of equal
size and then we join these parts now now you can see that so
all so three equal equal sized orange parts three equal sized
blue parts and then you join these two guys here together to
generate a new training set and this is going to be your new
test set so this ensures that in these individual forwards but
also in the combined sets the same proportion of blue and orange
observations is always available now and that at least the blue
class doesn't become smaller as it has to be just by bad luck
and and random chat and usually this ratification doesn't hurt
if you apply this even in more balanced situations and you can
also apply stratification not only on class labels but you could
also apply this on features and I don't know in imbalanced
feature of males and females and you want to stratify on that or
even on a combination of some features that's also possible some
comments on cross validation so very often five or ten folds are
common setting because if you use five faults you already use
80% of data for training and we split your data into five parts
four are being used for training one is used for testing and if
you use ten folds ninety percent of data are being used for
training so this pessimistic bias becomes smaller and smaller
and smaller if you use K equals n so you split up your data set
into exactly as many parts as you have observations and this is
called leave one out cross validation of course this is rather
expensive if you implement this naively because you then have to
fit n models if you have 10,000 observations have to fit 10,000
models on the other hand and you are using than nearly as many
observations during resampling as your final model will also see
now use an N minus 1 observations for training and later on your
model will be and observations so all of these cross validation
procedures have a slight pessimistic biased because they still
use less data now then in on the other hand if you use a higher
number of false more than five more than ten more than twenty
this pessimistic bias will become rather small and not really
noticeable that much anymore and if you want to you could go as
a half as high up as leaf 100 then it's a comparison between n
minus 1 and n and your data set will not only consist of I don't
know 20 or 30 observations but more likely or at least a hundred
or 200 huh and then this pessimistic bias is nearly not there
anymore um one thing you should keep keep in mind is that the
performance estimate you compute from these individual faults
and loops so these guys here yeah you these are not going to be
independent so add so one is kind of I don't know one one often
things about considering this collection of values as an
independent sample may be from something even like a normal
distribution and but it really isn't and you have to be quite
careful if you then calculate I don't know stuff like variances
or standard estimation from this alternative energy vs from this
collection of values or if you for example you run to
cross-validation for two different models and then you would
like to test these two samples against each other in order to
figure out whether there's a significant difference in mean
location the iid assumption really does not hold here and the
reason for this is that when you construct your training sets
your training sets are largely overlapping and they're
overlapping even more the larger your number of folds as now so
in the extreme if you're using leave one out cross validation
there's n minus two observations that are the same in each pair
of two to false or to cross validation iterations now and
therefore also these performance estimators here will not really
be independent and there's actually very complicated correlation
structure going on which makes the calculation of the variance
of the cross validation performance values somewhere between
hard and impossible and there's actually theoretical
considerations that prove that you can't cannot really produce
an unbiased estimator of the of the variance for the cross
validation um and this is also the reason why nowadays leave one
out cross validation has somewhat fallen out of little bits of
slightly falling out of favor because although it is nearly I'm
biased although this pessimistic bias is nearly not there at all
it has quite a high variance as an estimator because of these
this correlation going on between the different leave one out
cross validation iterations and the large overlap of the
training data sets and alternative option is to use a repeated
k-fold cross-validation so you just do multiple random cross
validation partitions I mean the cross relation itself is done
randomly and done somewhat arbitrarily so why not do this a
couple of times if you think that your cross validation
estimator might fluctuate still a lot because on your original
data set is pretty small then one standard option is run a
10-fold around 24 cross-validation and repeat this ten five and
what 20 times to average out the stock historicity here and this
is nowadays more preferred protocol for dealing with small small
data sets below I don't know 200 or 500 observations instead of
running even out on this one alternative I'm to cross-validation
bootstrap so here the idea is to draw B training data sets of
size n so kind of the motivation is to create training sets
which are really of the same size as the original data set and
we can only reach that by drawing from the original data set
with repetition now so this is the usual bootstrap approach
where we draw from this original set here with replacement now
as long and as often if we have until we have produced a set of
the same size and of course if we draw with replacement some of
these observations in here some of the observations from the
original set will be in the newly generated sets two times three
times four times now these observations were usually called in
back and the remaining observations we haven't drawn so for
example you for this first said this would be the green the
green guy and for the second set would be the this black
observation and the so-called out of back observations are going
to become our Associated test set for the respective training
set typically we construct somewhere I don't know between 30 and
200 different bootstraps splits and of course the variance of a
bootstrap estimator tends to be smaller the variance of our k4
truss validation estimator because training sets are at least a
bit more independently drawn and discontinued discontinuities
are a bit more smooth code here and of course the more
iterations perform in the bootstrap more expensive the estimator
becomes but also the smaller the variance is of our constructed
generalization performance estimator the bootstrap is also
somewhat pessimistically biased because the training sets well
they kind of artificially container when observations but in
reality only about now roughly two-thirds of the observations
are actually uniquely different and because at least the
variance and the independence well because the because although
our observations are not perfectly independent about the
variance structure of the constructed performance value some
bits is a bit now more well behaved and get what we get from
cross-validation using this bootstrapping framework might
actually allow the use of formal inference methods for my tests
being um for example use to compare different performance
estimation samples yeah with respect to significant differences
you can also they're also um protocols for running tests on
cross-validation scores but this is usually a bit harder and
sometimes also a bit more heuristic and they also exist
interesting extensions for very small data sets and that also
use the training error for for estimation of hopefully improved
estimation of the generalization performance error try to be a
bit more efficient here so there's B 6 3 2 and B 6 3 2 plus by
f1 which I'm not going to cover here that's the third type of
resampling procedure which is very very simple to explain called
subsampling and this is just repeated holdout with averaging so
instead of running our hearts bleeding once and estimating the
test arrow just on one test set we just do this a couple of
times and then average this this is also sometimes called Monte
Carlo cross-validation and this is also can also compare this to
bootstrap so it kind of it's the same as bootstrap but we are
now drawing without replacement and typical choices for the
splitting rate here are not again with the same argument for in
in general for resampling we try to make the training sets
larger to reduce the pessimistic bias and then prepare the
variance by repeated sampling and averaging and therefore two
bigger choices for splitting are 80% or 90% or 95% for training
of course the smaller we select the sub something right the
larger the pessimistic bias would be and the more sampler
sampling iterations we perform and the smaller the variance of
our estimator I have now extended the bias-variance analysis
example that are already showed you for our hold out a unit so
let's reconsider this now that our sampling and see what happens
and let's see whether we can somehow motivate that resampling is
a good idea so I'm running exactly the same thing as before
maybe it if you can't remember the somewhat complex setup for
this experiment read it again so I was using the spiral dataset
I was running a cart algorithm on this I was trying to estimate
the generalization performance of that cart algorithm if I gave
the three 500 observations and I tried out different split rates
for the holdup speeding so 5% 10% 20% or 95% of the data used
for training and the rest used for testing and then what we saw
was that well if we use very small training data sets that's
this pessimistic bias and a fuse a very small test data sets
fastest increase variance and at the end an optimal splitting
rate was somewhere around two-thirds of the data used for
training and one third of the data use for testing kind of the
sweet spot between not that much pessimistic bias and not so
highly increased variance because of small test says I'm not
doing exactly the same and I'm kind of reusing my results for
the holdout splitting but I'm also now running as a comparison
method 50 subsampling experiments on top of these 50 holder
experiments so for each potentials literate I not only compute
one holdout experiment but also compute one subsampling
experiment where do repeated training and test splits with s
equals five percent FS equals one percent s equals at 20 percent
this is of course much more expensive because of the repeated
splitting and averaging for one experiment but let's see whether
that kind of helps us a bit in better Araya summation so this is
if I not only plot the resulting box plots for our holed out
experiments this you have all seen before in the unit on
training test evaluation but next to these blue box plots you
see these green ones here from the subsampling and what you can
easily see is that the pessimistic bias of holdout splitting and
subsampling is pretty much the same why well because mainly
depends on the splitting rate right and the spilling red is the
same for holdout and sub something but what is quite different
is the variance right because what subsampling we're not using
one training test but we are using my tablet and an averaging
over them so this immediately reduces the variance of our
performance estimator which is a good thing so if we go from the
left hand side to the right hand side what you see is that the
pessimistic bias goes down down down now for subsampling as for
hotels bidding but the variance doesn't go that much up now so
this potentially allows us to push the boundary now for the
optimist bleeding red much further to the right hand side and
now use about 90% of data as an optimist blood red for for
subsampling and repair the increased the increased variance it's
basically repaired mitigated by the repeated averaging going on
in the in this subsampling what you can also see is that the
subsampling estimated says for each split read that i've
considered here is strictly better than everything i have
produced in the for the holdup estimator again i was measuring
this by MSE now so i'm computing the squared difference between
each element here in the box plot and the true generalization
performance of a misclassification error oh I don't know about
eleven percent and if I now compare these two estimators the
subsampling estimator is strictly better and its optimal value
is somewhere around here for splitting red with ninety percent
you might ask yourself hey why can't I even use 95 or 99 percent
for for splitting and the reason why you see this little
increase here again in MSE is actually the same reason that we
already discussed belief one hour cross-validation the larger we
make the training data sets the more overlapping they become and
the estimators or the numbers we are averaging here in
subsampling I'm not perfectly independent and the larger the
splitting rate is the more correlated that they are and at the
end we are averaging not over an independent sample of a bunch
of numbers but over a correlated sample and if the correlation
becomes stronger and stronger and stronger the beneficial effect
of our averaging they would be independent we know that variants
would go down live in a linear fashion but that doesn't hold
true anymore if we average over correlated samples which we
really do here in this case and then the more correlated larger
the split reddit um so let's discuss this a bit and wrap
everything up so in ml at the end we will fit one model on all
of our given data we really need to know how well this model is
going to perform in the future because otherwise work well if
the model is otherwise we're just blind right and we don't want
to blindly trust our predictor might be that the model is
behaving pretty badly and then we don't really want to I don't
know publish or implement this but if we have already used up
all of the data during fitting and there is no data left to
reliably compute this performance score anymore so what we have
to do is to kind of approximate this number through a different
alternative process and this is recently so we try to construct
the protocol where we use merely endpoints for training the
remaining points for testing train on the training sets test on
this headset iterate an average the resulting performance
performance was called oscillation be something they all
estimate exactly this number there are all alternative ways to
just estimate this important performance score and split leaking
resampling and cross-validation and subsampling we only produce
just that one number or just that I don't know sample of
performance values they do not really produce models parameters
etc so I'm I'm very often being asked if I run cross-validation
now like yeah I'm producing three models right which of these
models do I actually I don't know publish discuss put in my
paper which of the parameter vectors of these models who I
report who I use the answers none of them you're only running
cross-validation to produce a an estimator of the generalization
performance and the model you are going to publish and report is
the model you're going to fit on the complete data set at the
end because that's the one you want to use all of this stuff
here is just being run and performed so you get your hands on
the average performance from these from these values here at the
end so the models um I kind of just intermediate results and
discarded of course it's allowed to store them it's allowed to
look at them it's maybe also allowed to worry a bit if you see
that they randomly fluctuate a lot that you're producing um a
highly stochastic model here if your parameter estimators change
a lot you can do lots of stuff if you know what you're doing but
strictly speaking cross-validation first and foremost is a
procedure just for performance score estimation let's see them
with anything else left um yeah well there's one final point
this is a bit weird and sometimes confusing for the beginner and
complicated but unfortunately this is how it is an ml and bad
news is it becomes even more confusing if we have to talk about
tuning and nested cross validation but this will come in a later
unit um okay um maybe some some final comments for practice so I
already said that five or ten for cross-validation are somewhat
standard nowadays um it's not a very good idea to use something
like hold out or cross validation with a few number of
iterations or subsampling with the low subsampling rate if you
have a very small data set this can cause the estimator to be
extremely biased I'm also can cause quite a lot of variance for
smaller data situations with less than 500 to our observations
is probably good idea to use leave one out or nowadays probably
better to use repeat cross-validation so 10 times 10 forward
repeated across relation has become a standard or use 20 folds
um we can also repeat this 10 or too many times depends a bit
also on how expensive your model fitting is and how much time
you have um if you have already said that if you have a large
data set available but a very imbalance class situation now may
you might still have the problem of yeah small sample sizes and
high variance or performance estimators normally if you would
have I don't know 100,000 or 500,000 observations you wouldn't
really have to worry about I'm doing repeated splits now if
everything is kind of balanced if not maybe you do have to
repeat things so this is why it's very hard to give reliable
rules for running these performance estimation protocols you
also have to use a bit your own intelligence you have a bit of
exploratory analysis and think about problems that might work or
an estimation and how you how you could do this properly and I
hope you I taught you I'm the most important concepts in this
unit now I should also say that if you only worry about speed
for leave one out there are some computationally fast exact
calculations or approximations for some model classes available
um and modern results seem to indicate that some sampling has
somewhat better properties than bootstrapping I also have to say
that I nearly never nowadays really use bootstrapping for these
types of ML performance estimations usually these repeated
observations caused um can cause problems and training
algorithms especially in nested setups where this training setup
is split up again now in kind of an inner loop and then you have
these repeated measurements ending up simultaneously and
training and test sets and this is really not a good thing
because then you kind of again having the problem of training on
observations that are also being used a test time which you
normally never want and sometimes just the repeated measurements
itself can also result in numerical or problems for the fitting
algorithm

- Strictly speaking, resampling only produces one number, the
  performance estimator. It does NOT produce models, paramaters,
etc. These are intermediate results and discarded.
- The model and parameters are obtained when we fit the learner
  finally on the complete data.
- This is a bit weird and complicated, but we have to live with
  this.
