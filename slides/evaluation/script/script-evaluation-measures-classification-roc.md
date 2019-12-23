to our next unit on the evaluation of ML
systems so this is our C analysis part
one so our AC analysis is all about
evaluating binary classification systems
for imbalanced label situations so
imbalance label situations means that
one of the two classes is much smaller
than the other class and usually the
smaller classes also of a much higher
importance than the larger class so for
example consider a binary classifier for
diagnosing a serious medical condition
and here we can pretty much rightfully
assume that our label distribution is
going to be imbalanced so fortunately
not too many people potentially you will
have that rare disease that's we want to
model here and assume that maybe for
example only 0.5% of 1000 patients
actually have this very rare disease now
evaluating any classification system on
that task with something like the MIS
classification error or the accuracy is
very obviously inappropriate consider
for example the constant classifier that
always returns the label no disease yet
without looking at any features without
doing anything reasonable derives it
constantly just spits out no disease no
disease no disease for any observation
system if you evaluate this type of
system with the normal in this
classification error rate well obviously
this system man has a Mis classification
error rate of also only 0.5% which
sounds pretty good right but if you
think about this a bit more this is
actually the worst system you could ever
create and hopefully if hopefully not
implement because this system will send
everyone home will classify everyone as
healthy including everyone
from the from the disease group am even
classifying everyone as sick might be
better now depending on what happens
next and this problem is sometimes known
as the so-called Icarus here a paradox
which more or less simply states that
for these binary imbalance situations
it's not too smart to only look at
accuracy because that can be strongly
misleading and yeah what we should do
instead we learn very soon so there's
another very much related point of view
to understand this problem and this is
not through the lens of imbalance class
Labor's what I did before but you could
also look at this through the lens of
timberland classification costs so in
our example if you would classify a sick
patient as healthy this should pretty
obviously incur a much higher loss than
classifying a healthy patient is sick
now because these costs these
misclassification costs short very
likely depend on what happens next after
we've produced that classification and
we can likely assume in this medical
scenario here that our classification
system is not going to create fully
automatic decisions and a decide I'm
fully automatically on a subsequent
treatment for a patient what is very
likely going to happen is that if we
classify somebody as as sick this is
very likely going to be used as some
type of a screening filter now so
everyone that's going to be labeled as
sick is very likely undergoing next
second more invasive more expensive but
also more reliable test for the disease
where we can still figure out whether we
classified this patient incorrectly as
sick but erroneously sub subject
someone it sort erroneously subjecting
someone now to the second step is
obviously not good now from
psychological perspective from an
economic perspective because we are very
likely creating the automatic screening
filter exactly to avoid these costs in
many cases many hopefully correct cases
and also because that second step might
introduce further medical risks for the
patient undergoing that that next type
of diagnostic test but sending someone
home now to get worse or die there is
very obviously much much worse and we
want to avoid that at all costs and such
a situation not only arises if we have
imbalanced labor distributions but also
when well these are costs that are
connected with our decision making
process
Divac differ differ quite strongly so we
could also see this as a problem of
imbalance costs rather than imbalance
Labor's and imbalance costs could also
occur even if labor distributions are
and perfectly equal and both of these
situations are very tightly connected so
if we could specify these imbalance
costs like I for example did in the
previous unit on on Class V on
performance metric exam through a custom
Li designed cost matrix we could them
precisely evaluate against this custom
cost measure and we might even optimize
our machine learning model on the inside
directly through empirical risk
minimization against this against this
cost matrix and there's a individual
subfield of machine learning which is
called cost-sensitive learning which
deals with with exactly this type of
problem unfortunately users have a very
hard time coming up with these precise
cost numbers in imbalance scenarios
so we can't always do that if we can do
that if we can come up with these
precise numbers we have kind of boiled
this down again reduce this again to
well-defined optimization problem and
then everything is potentially much
easier we will now not assume that and
what we are going to do here in this
unit is to create different metrics to
evaluate our binary system from
different perspectives which often helps
to get a first impression of the quality
of the system so um our OSI analysis
deals with exactly this so it stands for
receiving operating characteristics
which is more or less a historical term
and the ROC curve was developed by
electrical engineers and radar engineers
during World War two stole a quote here
from Wikipedia for detecting enemy
objects and battlefields and then it was
very soon introduced to various
scientific subpoena that all have to
deal with the evaluation of binary
systems and psychology for the
perceptual detection of stimuli or in
medicine now I already gave an example
from medicine radiology biometrics
forecasting of hazards and so on and the
first step we are now going to take to
introduce more and new alternative
metrics for binary system is looking at
our two-by-two confusion matrix which
tabulates
predictions versus actual classes and
here in this two-by-two confusion matrix
tabulates
how many corrects and incorrect
labelings happened in these respective
entries and from now on I will
in this unit only consider binary
systems and I will call one of the
classes the positive class and one the
negative class and their respective
class sizes I will measure for denote
with n plus and n minus a so n plus for
the positive class I and minus for the
negative class SAS and the positive
class usually is as well hasn't anything
really positive associated with it I
mean medicine this is usually in the
class where the disease of course but
positive class means it's the important
class it's often the smaller class it's
the one o'clock it's it contains the
elements you don't kind of want to
filter out or miss and in engineering
you might call this class the signal
class and we will now give some
intuitive names to these respective
entries here of the confusion matrix so
for example we will call this entry here
the false positives because these are
all of the elements that we predicted as
class positive but where the prediction
was actually wrong so that second part
of this term specifies what we predicted
and the first part of the term specifies
whether the prediction was correct or
not now so then we have the true
positives the true negatives and the
false negatives and false negatives are
the guys we predicted as negatives but
where the prediction again was wrong and
what we now want to do is to well as a
first step at least we want to see how
many false positives did occur how many
false negatives did acquire again in
this medical scenario false positives
dang sorry false negatives are the
persons we labeled as healthy now
although they are sick so when I
probably avoid these types of errors as
much as we can what these types of
errors are bad but not as bad as these
here
and in order to introduce our our batch
of roc metrics we now do something
extremely simple we either look at rows
or columns and then compute percentages
of correct predictions either in the
columns or in the rows so for example we
can now define what is called the true
positive rate and the true positive rate
is the number or the percentage the rate
of true positives here in this first
column and then there's the true
negative rate the true natural rate is
the rate of negative well the the number
of elements from the negative class that
we also predicted as being negative and
we can do pretty much the same row-wise
now we can specify a something that's
called the positive predictive value or
the negative predictive value where the
positive predictive value is the number
of true positives divided by the number
of elements that we predicted as being
positive so there's a very intuitive way
of understanding what these metrics mean
so true positive rate is how many of the
true positive elements did we also
predict as positive while the positive
predictive value is how many or
if we predict an object as belonging to
a class one how likely is it that this
object is really of class one or if you
again consider this this medical
scenario the PPV tells you if your
medical test assigns you the disease how
likely do you truly have it t PR tells
you if you have the disease how likely
the
your tap does your test assign you to
the disease class or D detects that
disease um here's a small example um
that also um took actually from a
medical test I mean this in this case
was a screening system for bowel cancer
detection so this is a pretty rare
disease so in this case we only have 30
persons actually having that specific
type of disease but we have a control
group of 2,000 pretty much exactly 2,000
some persons not having the disease and
then we tabulated here all the correct
and the incorrect numbers of predictions
are and you can see the various
computations for these new RC metrics
I'm not going to read out every number
in every calculation but you can for
example see from 30 elements in the
positive class we detected 20 of those
resulting in a TPR of 2/3 and for the
positive predictive value well we did
correctly class did classify to any of
our positive class elements correctly as
positive but there's also 180 of the
negative class which is quite large that
we incorrectly labeled as positive
residing in a very low PPV of only 10%
so and we can now start discussing how
much we like this binary system yeah
first of all one third of the sick
patients we are missing
we are not detecting correctly while if
this medical test tells you that we have
the disease but this test is only
correct in only 10 percent of the cases
Sam so this doesn't seem too good on
both fronts
now there's even more our C metrics that
you can create from this 2x2 confusion
matrix there is four examples
yeah the false negative rate which is
simply well the inverse of the true
positive rate so this is the percentage
of false negatives here in this first
column here which is obviously also one
just one minus the T PR or you have here
the false positive rate which is one
minus the true negative rate and then
their stuff I don't know like prevalence
or negative or the false emission rate
and other stuff you can also see one
unfortunate aspect here of our C
analysis and that is that because all of
that stuff is B is being considered in
different scientific fields like
psychology and engineering there's
usually two or three different terms for
the same concept answer two positive
rate is also called recalled and also
called sensitivity false positive rate
is also called fallout the true negative
rate is also called specificity and so
on and I try to avoid all of these
alternative names in this unit and I'm
also mainly focusing on these four if
you want to read a bit more on this can
also go to big pedia where we stole this
matrix from M or go to an interactive
diagram that shows you how all of that
stuff is calculated in detail and one
thing I want to focus on a bit more
here's the so called f1 measure could
have seen this also here before um so um
as you have already seen from this
previous example it's very often
difficult to achieve simultaneously a
high positive predictive value and a
height
pyaare why well if you can somehow
massage or change your classifier so it
predicts more positives than before yes
this will result in a higher TBR map
this will also result usually in a
higher number of false positives because
you're now predicting more observations
as positive and this is the usual price
you pay so increasing your TP are
usually results in a lower PPV and
vice-versa also if you do the opposite
and you somehow change your classifier
through that it predicts more negatives
you will have a higher PPV but your TP
are usually goes down so in a certain
sense there's an inherent trade-off
going on between these two measures and
it might be an interesting idea to try
to balance these two conflicting goals
out and the f1 measure is one way to do
this which is simply the harmonic mean
between PPV and TPR
so if you haven't heard of the harmonic
mean before so in maths there's three
types of mean or averaging functions
they are the normal usual mean the
geometric mean and then the harmonic
mean and for two elements the harmonic
mean is simply two times the product
divided by the sound and note that yeah
we are trying to balance out here PPV
and TPR but this measure doesn't really
take into account the number of true
negatives and if you haven't seen the
harmonic mean before I have tabulated
this here for you for different
combinations of T PR and PPV and what
you can potentially see from this table
is that the harmonic mean tends more
strongly than the normal average or the
geometric mean towards the smaller of
the two elements
so you can maybe see this here where you
have a TPR of one and then you have a
PPV of 0.6 so the normal average would
result in a value of 0.8 well the
harmonic mean of the F 1 measure results
in point 7 5 or here the normal average
would be 0.7 while the F 1 computed from
the harmonic mean is point five seven
and nicely a model with TPR equals zero
now where you didn't predict anything as
a profit positive from the positive
class or a binary system with a positive
predictive value of zero so where no
real positives were among the predicted
positives both of these systems always
have an F 1 of F 1 score of zero now you
can easily see from this formula here
and from the from the product here on
the top you can also ask yourself what
what am what is the F 1 so of a constant
system that always predicts negative the
negative class level well in this case
if you always predict the negative class
then the TPR is 0 so f 1 is 0
that's easy to see if you always predict
positive things are not so simple or
well F 1 is not exactly 0 what happens
then is that well the if you predict
everything is positive then obviously
the true positive rate is going to be
exactly 1 now because everything from
the positive class you're also labeling
as positive so this formula here reduces
to 2 times P PV divided by p VV plus 1
and with I don't know maybe pen and
paper and two seconds of extra time you
cannot also show that this reduces even
further to 2 times n plus so the size of
the positive class divided by n plus
plus n and this is simply due to the
fact that the PPV in this case here is
the number of positive class labels
which is or sorry yeah the number of
well this is the PPV in this case is
simply n plus divided by n because
you're predicting everything as positive
also the number of elements that you
predict as positives n well and of these
n plus elements you have predicted
correctly as positive and if you're
positive class is rather small then also
there's an f1 square here will be rather
small and which you can directly see
from this formula um the f1 metric
allows you to balance out PPV and true
positive rate in a single number on the
other hand I'm not sure whether this is
always reasonable in order to really
talk about one single metric for these
imbalanced cases you would really have
to specify your precise costs in a cost
matrix and we just assume that we can't
do that so what this basically means is
that that there is no single perfect
metric or we are actually missing some
information to come up with a single
quantitative number to evaluate our
binary system f1 is a possibility but f1
now assumes a certain cost structure
that we haven't explicitly written down
so now of course you can do that whether
this really reflects what you want in in
practice either not is another matter
and I think very often it makes more
sense to really then stick with visual
analytical tools from our C analysis
which I will introduce in the next
