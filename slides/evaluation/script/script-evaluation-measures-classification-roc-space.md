# Evaluation: Measures for Binary Classification: ROC visualization

Welcome to our next unit on the evaluation of ML systems. This
unit discusses visual measures for binary classificatin systems
in imbalanced settings and where no cost matrix is known.  

## LABELS: ROC SPACE

Our first unit on ROC analysis I introduced various metrics for
the evaluation of binary classification systems with imbalanced
class levels. Among those were the true positive rate which was
the percentage from the positive class that we also predicted as
being positive and the false positive rate which is the
percentage of the negative class that we erroneously predict as
being positive. Both measures range between 0 and 1, or 0 and
100 if given in percentage points.  If we plot these two
measures like in this example we can compare several models with
each other. This plot is called ROC space.  In the previous unit
we learned that it is difficult to objectivley combine two
conflicting measures like PPV and TPR or also FPR and TPR,
without knowing the costs of different incorrect (and also
correct) decisions. So if we don't have that extra information
why not just keep the two conflicting metrics apart and
visualize them on their own without combining them in an unclear
manner? This is exactly what the ROC space does. For each
classification system under consideration we simply
calculate the TPR and FPR and then we plot it into
this coordinate system here where we put FPR on the x-axis and
the TPR on the y-axis. Of course we could do the same for other
measures, like TPR and PPV as in the F1 measure.
In this unit we focus on the TPR and FPR, as these are most 
commonly plotted in such a fashion.
Now by plotting the measures of different models in one plot,
we can try to visually pick our preferred model.
In this example it is pretty
clear that if we compare c1 to c3, that c1 is better. It is not 
only better with respect to FPR (where lower is better), but also with respect to TPR (where greater is better). If
we compare c1 with c2 the situation is much less less clear. c1
has a lower FPR value but c2 has a higher TPR value and again
without extra information on misclassification costs we can't
decide which of these two systems is preferable. 


## LABELS: ROC SPACE

Obviously the best ever potential system is located on the top
left corner, because it has both a true positive rate of 1 and a
false positive rate of 0. That can only happen if we produce
zero errors on the positive class and on the negative class and
of course if that happens we also don't really have to talk
about costs, right?  Normally if we would see such a solution in
a real-world problem we might worry a bit about label leakage or
some other error we might have introduced into our evaluation
procedure. Models which lie on the diagonal are as good as
random. Imagine a classifier, which produces random labels,
random 0 1 labels, without looking at the features.




 so these are
pretty bad systems they're not learning anything um here we have
a system that always predicts negative class labels here we have
a system that predicts positive classes with 25% of probability
here with 75% of probability and here with 100% of probabilities
here we always predict positive classes without considering any
feature value at all so for such a system if we predict
everything as positive obviously the TP R is 1 right because
everything from the positive class we predict also is being
positive while everything from the negative class we also
predict wrongly as positive so the fpr is also 1 for this point
here now where we predict the positive class with 25%
probability we get a TP are also of 25% why well because for
every observation from the positive class we assign a random
label and with 25% probability we assign positive as the
predicted label so TPR is 25% for everything from the natural
class and we also assign a positive label 25% of the time these
are exactly the errors we are producing on the negative class so
we have an F P are also of 25% and practice we should actually
never really obtain a classifier which is significantly below
this diagonal why because this is really not a bad classifier we
could from this classifier produce a very good one simply by
inverting its predictive labels also transforming every predict
0 into a 1 and vice versa and this would reflect in this ROC
coordinate system our point at the main diagonal residing in a
good classifier in this upper triangular part here so if you
would for example have a system with FP R 1 and T P R 0 we can
do the same trick and would end up with a perfect classifier on
the other hand if that happens our classification system has
basically learned the opposite of what it should have learned so
there's I guess - yeah scenario is possible how to think about
this the first one is the first thing I would probably do is to
just look an arrow in my arm and the code that I've written
because there's probably some some label flipping going on if
that's not true and I really have learned the opposite of what I
should have learned I would yeah worry even more because then
something extremely strange has happened ROC this is our C
metric so have one nice property and this is that they are
insensitive so-called insensitive to class distribution changes
during prediction time so what I mean with that is that if we
consider such a situation here where we have the same amount of
examples in the positive class as in the negative class so n
plus divided by n minus is one yeah 50/50 and now we consider
the miss classification error of this system here we can see
that the miss classification error is these 35 counts now these
35 elements that we predict incorrectly if we compute the true
positive Reds and the false positive red we see directly that
the TPR is 0.8 now 40/50 and the fpr is 0.5 25 also divided by
50 now let's double the size of a positive class so our
proportions change to n plus divided by n minus equals 2 so at
prediction time we now simply use more examples from the
positive class now our miss classification error actually
changes as you can see here now forty five elements are
classified incorrectly from 150 and this reduces to a miss
classification error of not thirty five percent but thirty
percent so by simply changing the proportion of positive
elements in our test set but not really the simply by kind of
kind of upscaling the number of positive elements in our test
set we have also now changed or miss classification error
evaluation on that set if we consider again TPR and FP are
nothing really has changed again we have a TPR of eighty percent
point eighty divided by 100 for this column here and we have a
false positive rate again of 50 percent 25/50 you have to be a
bit careful here and sometimes this factor some abbreviated a
bit too shortly by that our C analysis is simply insensitive to
classes is really not true if you mess around with class
proportions during training because then you're completely your
complete learned classification system can change estimated
posterior probabilities can change can sometimes drastically
change for example reduce one of the classes to an extremely
small size then maybe only the largest class is going to be
predicted predicted at all and then basically all bets can be
off and we actually sometimes have to repair this situation too
by upscaling I'm the smaller class again up weighting it now
until here I have only considered binary classifiers which
produce discrete class levels of course nearly all of our models
that we nowadays have available all of these models are able to
output and continue scores very often continuous probabilities
so they can output and model posterior probabilities for class
one what we can do with these posterior probabilities is we can
convert them as I've already said into discrete Labor's by
threshold during them at a specific value and with threshold I
mean of the estimate posterior probability from observation acts
exceeds this threshold tau here we assign a predicted predicted
label of one so a positive class and if it's below that
threshold we predict zero the negative class and normally we
would probably use a threshold of 0.5 now as I also already told
you in the unit on performance metrics and for classification
and the Briers war and the la crosse but for imbalanced and cost
sensitive situations this threshold at Point five is neither
required necessary nor always beneficial right because if
everything is imbalanced and cost sensitive it might be we are
interesting attractive to more liberally or more conservatively
predict the positive class anyway whatever Thresh would be
select here after Thresh willing we have transformed our
continuous probability scores into discrete class levels and
therefore we can now evaluate this discretized system with any
performance metric that is possible for discrete class levels
and which I have introduced so far so we can use accuracy we can
use any normal RC metric or we can use the f1 score or if we
don't do the threshold of course we can use all of these metrics
for probability outcomes like rious for the lock loss or the
area the under the curve which I'm going to introduce very soon
in this unit here now the ROC curve kind of relies and is
defined on this threshold enough classifiers so because we don't
really know what threshold is actually best and we can't also
really optimize for a perfect threshold now because we don't
really have a single objective clear performance metric
available in these imbalance situations with unknown costs what
the ROC analysis does is it iterates through all potential
thresholds calculates FPR and TPR values for all of these
barriers induced binary classification systems and then
visualizes them and all at the same time so you can see the
complete spectrum of solutions you get from different trade-offs
and this resulting plot is called in the ROC curve so if you set
small thresholds you very very liberally predict class 1 now for
example the threshold of 0.1 will assign every posterior
probability of larger than 10% to plasma and this will very
likely happen very often and so this will result in a
classification system with an extremely high F P R but also very
high T P R if you choose a very high threshold you will only
very conservatively predict class 1 and this will of course
restrict the amount of false positive errors you're making but
it will also very likely result a name only quite small true
positive rate so um let's now draw this ROC curve step by step
to see how it works out so you're going to do this by ranking
our observations depending or with regard to decreasing score
then we'll start with the highest threshold possible which is a
value of 1 and we start in the origin actually let me directly
maybe go to the animation so I can explain this here so assume
we have 12 only 12 observations here in our toy example and six
of those are truly from class positive so here are the six
positive elements and then six are from the negative class and
here you can see The Associated scores from our binary
classifier under consideration and I've already ordered these
observations we regard to decreasing score and now I will start
here in the origin at FP r equals zero and TP r equals zero with
a classifier with that threshold one so this classifier with a
threshold one will assign everything to the negative class now
because there no posterior probability will be larger than one
so this means nothing is assigned to the positive class so f of
f PR of zero and also unfortunately only a TPR of zero now after
I've drawn this point here now I will create a threshold that is
exactly between the first observation and all of the other ones
for example I could use I don't know point 9 now because this
observation here this blue one is from the positive class I know
that my false positive rate stays the same right because I
haven't changed anything from the negative class but this
positive example I have now correctly labelled also as positive
so my t PR goes up a bit and I can actually calculate how much
it goes up because there's only six elements in the positive
class it will go up by 1/6 which is about 0.167 now the next
element again is positive if I now set my threshold here between
these two observations to I don't know something like 0.85 again
I will go up by one sixth and again I will go up to this year
for the third possible threshold now the next element is
actually negative so the true positive rate stays the same
because I'm not changing any prediction on that positive class
what I'm changing is a prediction on the negative class I'm not
incorrectly labeling this element here as positive although it
is it and that's actually the only mistake until now that I'm
creating other than that I'm producing on the negative class now
another positive element and so on and so on and after I've
iterated through all of these different thresholds I have
produced this curve here which doesn't look very smooth because
I've only in this toy example consider twelve twelve
observations and this is what I'm going to call the ROC curve
and this ROC curve now encodes all of the different thresholds
sorry all of the different binary classification systems I can
create by just using different thresholds and this allows me to
produce a wide spectrum of differently behaving systems with
more ones and more zeros being predicted and different GPRS and
fpr's and although I still don't know how to objectively select
now a point from this curve maybe by producing this curve
thinking about this thinking about it discussing this with my
with my client I cannot come up with a certain threshold an
operating point here on the curve that I like and that I can now
select and the whole idea behind doing that compared to
specifying costs a priori is that specifying the costs without
knowing anything about the potential candidate solutions is very
hard if you are being shown all of the potential systems that
you could use maybe it's much easier to select one of these as
the one you want to implement here's an example of four
different types of our C curves you could produce from scoring
classifier so for example this green one here are very close to
the diagonal line so if you are exactly on the diagram again
this would be a random system not learning anything this year
close to this top-left corner would be a very good scoring
classifier and then here I have drawn two kind of okayish
systems somewhere between in the middle and you can also see one
other thing here and this is that yes this dark blue system
dominates all of the other three but if you compare these two
you can see something that happens quite often in these
situations and that is that is that these are RC curves actually
cross here so depending on where you want to be in your rock
space either the green curve or the blue one is actually better
and this again you can't really specify objectively you have to
think about where you want to be you wanna have a larger TPR or
you wanna have a smaller FPR if you really want to drill down
the evaluation of such a scoring classifier again to a single
number one thing you can do is you can calculate the AUC again
I'm worrying a little bit against this don't do this if you have
to the full ROC curve and plot is I think much more informative
but if you want to tabulate dozens of models if you want to
optimize over hundreds of models and being able to rank stuff is
convenient and one way to go about this is the area under the
curve the name should already kind of tell you its definition so
you produce the ROC curve and then you simply calculate the area
under that curve by integrating over this curve now so it's well
it simply is the area under that curve and if the AOC is one you
have a perfect classifier whose ROC curve goes like that a
classifier with an AMC of 0.5 would pretty much lie here on this
diagonal and be yeah denote the worst possible system and then
again a classifier with a or C equals zero or something below
point five actually should not happen because again we can do
this inverting of labor's trick and then produce a much better
classifier out of that bad one and this bad one has kind of
learned the opposite of what it what it should have learned
besides this hey the AUC is the area under this war curve
there's a second nice interpretation of a you see that you
should also know and this is that the AUC is exactly the
following probability if you select randomly an element from the
positive class in this case I think we with selected this
element here randomly from the positive class and then we select
the second element randomly but from the negative class so for
example this element here and on both elements we consider the
predicted scores by our classifier and we now calculate whether
these two elements are ranked correctly so whether the score of
the positive element is higher than the score on the selected
negative element than the probability that this ranking is
actually correct is exactly the value of the AUC one last final
well generalization the AUC so one thing I sometimes do not like
too much about the AOC is that very often you integrate out over
large portions of the curve that you're not really interested in
for example again think about these types of medical
applications where you really really really want an extreme hi
true positive red because having a lower positive red means well
sending people home who are classified as being healthy while
they are actually sick so you are now integrating out over for
example parts of your RC a space with the TPR of 0.1 now so true
negatives of 90% maybe of 80% 70% and you would never implement
or consider any of these systems anyway why should you do this
done in this integration of the AOC value wouldn't maybe be much
smarter to think about certain regions like minimal and maximal
boundaries where inside of these boundaries you would be
interested in implementing such a system we can so what we are
basically going to do is put in constraints reasonable
constraints now either on TPR or an FPR so for example we could
say our a false positive rate should be below 20% otherwise
we're not going to consider anything beyond this anything worse
that at all or we might say that our TPR and this is maybe more
appropriate for this medical example I'm using again and again
so our TPR needs to be at least 80% so the amount of false false
negatives is below 20% and then only beyond these limits and
constraints we are now calculating the area under the curve by
integrating over this area here or integrating over this area
and if we do that we call this the partially AUC and yes this is
a little bit harder do you find because you have to think a bit
more about what you actually want which types of systems yeah
you deem worthy enough to implement on the other hand it's
probably much more appropriate in realistic applications of
binary image systems
