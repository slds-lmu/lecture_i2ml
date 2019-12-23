Welcome to our next unit on the evaluation of ML systems.  In
this lesson we will take a deeper look at binary classification
and corresponding measures, which we call ROC measures.  ROC
analysis is all about evaluating binary classification systems
for imbalanced label situations.  Imbalanced label situations
are situations in which one of the two classes is much smaller
than the other class. Often the smaller class is also of higher
importance than the larger class. So for example, consider a
binary classifier for diagnosing a serious medical condition.
Let's assume that our label distribution is imbalanced. So
fortunately not too many people have the disease that we want to
model here. And assume that, for example, only 0.5% of 1000
patients actually have this very rare disease. Now evaluating
any classification system on that task with something like the
misclassification error or the accuracy is obviously
inappropriate. Consider, for example, the constant classifier
that always returns the label "no disease".  A very stupid
classifier that doesn't look at any features. It just constantly
spits out "no disease", "no disease", "no disease" - for each
and every patient.  If you evaluate this type of system with the
normal misclassification error rate, well, this system does very
well. It has a misclassification error rate of only 0.5%. This
sounds pretty good right, but if you think about this a bit more
this is the worst system ever and hopefully not implemented
because this system will say nobody has the disease and send
everyone home, including the patients who have the disease.
This problem is known as the accuracy paradox. The paradox
states that for these binary imbalanced situations it's not too
smart to only look at accuracy, because that can be strongly
misleading.  What should we do instead? Wait and learn!

There's another very much related point of view to understand
this problem: instead of through the lens of imbalanced class
labels, we will now view the problem through the lens of
imbalanced classification costs. In our example if you would
classify a sick patient as "not sick" this should usually come
along with a higher cost than classifying a healthy patient as
sick. These costs, these misclassification costs should depend
on what happens after we've produced that classification.
Imagine patients classified as sick are sent to another, more
thorough and expensive screening.  Patients classified as "not
sick" are sent home.  In the cases where we do the thorough
screening, we can still figure out whether we classified this
patient incorrectly as sick. Erroneously subjecting someone to
the screening is obviously not good from a psychological and
economic perspectiv. But sending someone home who is sick and
will likely get worse or even die, is clearly much much worse
and we want to avoid that at all costs. Such a situation not
only arises if we have imbalanced label distributions but also
when well these costs that are connected with our decision
making process differ quite strongly. So we could also see this
as a problem of imbalanced costs rather than imbalance labels
and imbalanced costs could also occur even if label
distributions are perfectly equal.  Both of these situations are
very tightly connected. If we could specify these imbalanced
costs, we could precisely evaluate against this custom cost
measure, and we might even optimize our machine learning model
on the inside directly through empirical risk minimization
against this cost matrix. There's a specific subfield of machine
learning, which is called cost-sensitive learning, which deals
with with exactly this type of problem.  Unfortunately it is
usually very difficult to up with precise cost numbers, so we
can't always do that. In the following we assume that we have no
knowledge about costs. What we are going to do in this unit is
to create different metrics to evaluate our binary system from
different perspectives. This often helps to get a first
impression of the quality of the system.
ROC analysis deals with exactly this.

First we are now going to introduce more and new alternative
metrics for binary systems. Let's look at our two-by-two
confusion matrix which tabulates predictions versus actual
classes. This confusion matrix tabulates how many correct and
incorrect labelings happened in the respective entries. In this
unit we will only consider binary systems and I will call one of
the classes the positive class and one the negative class.
Their respective class sizes we denote with n plus and n minus.
So n plus for the positive class and n minus for the negative
class. The positive class usually does not have anything
positive associated with it. Positive class means it's the
important class - it's often the smaller class - it contains the
elements you don't want to miss. In engineering you might call
this class the signal class.  In medicine this would be the
disease class, so not positive at all. Ok, now let's get to our
new measures: The ROC metrics.


# Keep improving from here
# TODO

 And we will now give some intuitive
names to these
respective entries here of the confusion matrix so for example
we will call this entry here the false positives, because these
are all of the elements that we predicted as class positive but
where the prediction was actually wrong. So that second part of
this term specifies what we predicted and the first part of the
term specifies whether the prediction was correct or not. So
then we have the true positives the true negatives and the false
negatives. False negatives are the guys we predicted as
negatives but where the prediction again was wrong. And what we
now want to do is to do as a first step, at least we want to see
how many false positives, did occur? How many false negatives
did accure? Again, in this medical scenario, false negatives are
the persons we labeled as healthy although they are sick. So we
wanna probably avoid these types of errors as much as we can.
These types of errors are bad but not as bad as these here. In
order to introduce our our batch of ROC metrics we now do
something extremely simple we either look at rows or columns,
and then compute percentages of correct predictions, either in
the columns or in the rows. So for example we can now define
what is called the true positive rate and the true positive rate
is the number or the percentage, the rate of true positives here
in this first column. And then there's the true negative rate:
the true negative rate is the number of elements from the
negative class that we also predicted as being negative. We can
do pretty much the same row-wise: we can specify a something
that's called the positive predictive value or the negative
predictive value where the positive predictive value is the
number of true positives divided by the number of elements that
we predicted as being positive. So there's a very intuitive way
of understanding what these metrics mean: so true positive rate
is "how many of the true positive elements did we also predict
as positive?" while the positive predictive value is "if we
predict an object as belonging to a class one how likely is it
that this object is really of class one?" or if you again
consider this this medical scenario, the PPV tells you, if your
medical test assigns you the disease, how likely do you truly
have it? TPR tells you: if you have the disease, how likely does
your test assign you to the disease class or detects that
disease.




 so
it stands for receiver operating characteristics which is more
or less a historical term and the ROC curve was developed by
electrical engineers and radar engineers during World War two. I
stole a quote here from Wikipedia - for detecting enemy objects
and battlefields - and then it was very soon introduced to
various scientific subfields that all have to deal with the
evaluation of binary systems: psychology for the perceptual
detection of stimuli or in medicine - I already gave an example
from medicine -, radiology, biometrics, forecasting of hazards,
and so on.



 Here's a small example that also um took actually from a
medical test, in this in this case, was a screening system for
bowel cancer detection. So this is a pretty rare disease so in
this case we only have 30 persons actually having that specific
type of disease but we have a control group of 2,000, pretty
much exactly 2,000 some persons, not having the disease and then
we tabulated here all the correct and the incorrect numbers of
predictions are and you can see the various computations for
these new ROC metrics.  I'm not going to read out every number
in every calculation but you can for example see from 30
elements in the positive class we detected 20 of those,
resulting in a TPR of 2/3. For the positive predictive value, we
did correctly classify twenty of our positive class elements
correctly as positive. But there's also 180 of the negative
class - which is quite large - that we incorrectly labeled as
positive resulting in a very low PPV of only 10%.  So and we can
now start discussing how much we like this binary system.  First
of all one third of the sick patients we are missing - we are
not detecting correctly - while if this medical test tells you
that we have the disease - but this test is only correct in only
10 percent of the cases - so this doesn't seem too good on both
fronts.  Now there's even more ROC metrics that you can create
from this 2x2 confusion matrix. There is for example the false
negative rate which is simply, well, the inverse of the true
positive rate, so this is the percentage of false negatives here
in this first column, which is obviously also one just one minus
the TPR. Or you have here the false positive rate which is one
minus the true negative rate. And then there is stuff like
prevalence or the false emission rate or other stuff. You can
also see one unfortunate aspect here of ROC analysis and that is
that because all of that stuff is being considered in different
scientific fields like psychology and engineering there's
usually two or three different terms for the same concept. So
true positive rate is also called recall and also called
sensitivity. False positive rate is also called fallout. The
true negative rate is also called specificity and so on. I try
to avoid all of these alternative names in this unit and I'm
also mainly focusing on these four. If you want to read a bit
more on this you can also go to Wikipedia where we stole this
matrix from or go to an interactive diagram that shows you how
all of that stuff is calculated in detail.

One thing I want to focus on a bit more here is the so called F1
measure. You've have seen this also here before. As you have
already seen from this previous example it's very often
difficult to achieve simultaneously a high positive predictive
value and a high TPR. Well if you can somehow massage or change
your classifier so it predicts more positives than before, yes
this will result in a higher TPR, butp this will also result
usually in a higher number of false positives, because you're
now predicting more observations as positive and this is the
usual price you pay. So increasing your TPR usually results in a
lower PPV and vice-versa also if you do the opposite and you
somehow change your classifier through that it predicts more
negatives you will have a higher PPV but your TPR usually goes
down. So in a certain sense there's an inherent trade-off going
on between these two measures and it might be an interesting
idea to try to balance these two conflicting goals out. The F1
measure is one way to do this: which is simply the harmonic mean
between PPV and TPR.  So if you haven't heard of the harmonic
mean before: in maths there's three types of mean or averaging
functions.  There is the normal usual mean, the geometric mean
and then the harmonic mean and for two elements the harmonic
mean is simply two times the product divided by the sum. Note
that yeah we are trying to balance out here PPV and TPR, but
this measure doesn't really take into account the number of true
negatives. 

And if you haven't seen the harmonic mean before, I have
tabulated this here for you for different combinations of TPR
and PPV and what you can potentially see from this table is that
the harmonic mean tends more strongly - than the normal average
or the geometric mean - towards the smaller of the two elements.
So you can maybe see this here where you have a TPR of one and
then you have a PPV of 0.6, so the normal average would result
in a value of 0.8, while the harmonic mean of the F1 measure
results in .75 or here the normal average would be 0.7 while the
F1 computed from the harmonic mean is .57.  And nicely a model
with TPR equals zero
- where you didn't predict anything as as positive / from the
  positive class - or a binary system with a positive predictive
value of zero - so where no real positives were among the
predicted positives - both of these systems always have an F1
score of zero. You can easily see from this formula here and
from the product here on the top.  You can also ask yourself
what what is the F1 of a constant system that always predicts
the negative class label. Well, in this case, if you always
predict the negative class then the TPR is 0 so F1 is 0, that's
easy to see. If you always predict positive, things are not so
simple or, well, F1 is not exactly 0. What happens then is that,
well, if you predict everything as positive then obviously the
true positive rate is going to be exactly 1 now, because
everything from the positive class you're also labeling as
positive. So this formula here reduces to 2 times PPV divided by
PVV plus 1. And with - I don't know maybe - pen and paper and
two seconds of extra time you can now also show that this
reduces even further to 2 times n plus - so the size of the
positive class - divided by n plus plus n. This is simply due to
the fact that the PPV in this case is simply n plus divided by n
because you're predicting everything as positive, so the number
of elements that you predict as positives n. Well and of these n
plus elements you have predicted correctly as positive. And if
you're positive class is rather small then also there's an F1
here will be rather small, which you can directly see from this
formula. The F1 metric allows you to balance out PPV and true
positive rate in a single number, on the other hand I'm not sure
whether this is always reasonable. In order to really talk about
one single metric for these imbalanced cases, you would really
have to specify your precise costs in a cost matrix and we just
assume that we can't do that so what this basically means is
that that there is no single perfect metric, or we are actually
missing some information, to come up with a single quantitative
number to evaluate our binary system. F1 is a possibility but F1
now assumes a certain cost structure that we haven't explicitly
written down.  Now of course you can do that. Whether this
really reflects what you want  in practice is another matter and
I think very often it makes more sense to really then stick with
visual analytical tools from ROC analysis, which I will
introduce in the next unit.
