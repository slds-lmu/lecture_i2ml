0:00:00.440,0:00:09.349
hi welcome to our next unit on the

0:00:05.810,0:00:14.450
evaluation of ML systems our C analysis

0:00:09.349,0:00:16.490
part 2 so in our first unit on our C

0:00:14.450,0:00:18.699
analysis I introduced various metrics

0:00:16.490,0:00:22.279
for the evaluation of binary

0:00:18.699,0:00:26.359
classification systems and imbalance

0:00:22.279,0:00:29.259
class levels among those were the true

0:00:26.359,0:00:32.960
positive rate which was the percentage

0:00:29.259,0:00:35.480
from the positive class that we also

0:00:32.960,0:00:39.110
predicted as being positive and the

0:00:35.480,0:00:42.559
false positive rate which is the

0:00:39.110,0:00:46.309
percentage of the negative class that we

0:00:42.559,0:00:48.920
erroneously wrongly predict as being

0:00:46.309,0:00:50.930
positive now in order for us to

0:00:48.920,0:00:55.940
introduce the full our C curve

0:00:50.930,0:00:59.719
I'll introduce first the so called our C

0:00:55.940,0:01:02.870
space or our C coordinate system so we

0:00:59.719,0:01:06.770
have already seen in the example for PPV

0:01:02.870,0:01:09.620
and TPR and the F 1 metric that it is

0:01:06.770,0:01:12.860
pretty difficult to I don't know

0:01:09.620,0:01:15.260
objectively marry two of these

0:01:12.860,0:01:21.620
conflicting our C metrics into a single

0:01:15.260,0:01:23.690
quantitative number because we can't

0:01:21.620,0:01:28.280
really do this if we don't have extra

0:01:23.690,0:01:30.830
information on the costs of the false

0:01:28.280,0:01:32.840
positives and the false negatives so if

0:01:30.830,0:01:36.770
we don't have that extra information why

0:01:32.840,0:01:40.070
not just keep the two conflicting

0:01:36.770,0:01:43.970
metrics apart and visualize them on

0:01:40.070,0:01:46.280
their own without combining them in an

0:01:43.970,0:01:50.140
unclear manner and this is exactly what

0:01:46.280,0:01:51.860
the our C space does so for each

0:01:50.140,0:01:52.550
classification system now under

0:01:51.860,0:01:55.490
consideration

0:01:52.550,0:01:59.480
we simply evaluated but it's TPR and by

0:01:55.490,0:02:02.030
its FPR and then we plot it into this

0:01:59.480,0:02:05.000
coordinate system here where we put FP r

0:02:02.030,0:02:06.830
on the x axis on TP r on the y axis and

0:02:05.000,0:02:08.200
of course we could have also used t PR

0:02:06.830,0:02:11.870
and PPV

0:02:08.200,0:02:13.060
like an f1 and that gives rise to a

0:02:11.870,0:02:14.920
different our

0:02:13.060,0:02:19.090
see like ordinate system but in this

0:02:14.920,0:02:23.170
unity I decided to focus on the two more

0:02:19.090,0:02:28.420
standard metrics in our C analogy

0:02:23.170,0:02:32.800
analysis TPR and fer and if we do this

0:02:28.420,0:02:35.230
and plot different classifiers here into

0:02:32.800,0:02:37.989
such a coordinate system and two

0:02:35.230,0:02:42.069
different situations can arise because

0:02:37.989,0:02:44.170
of these trade of metrics where we are

0:02:42.069,0:02:47.350
not sure how we should weigh them

0:02:44.170,0:02:49.870
against each other so situation one is

0:02:47.350,0:02:53.110
pretty clear and this is if we compare

0:02:49.870,0:02:57.250
c1 to something like c3 so in this case

0:02:53.110,0:02:59.980
we can see let's see one is strictly and

0:02:57.250,0:03:02.530
clearly better in both metrics it has a

0:02:59.980,0:03:04.799
lower FPR value and a higher TPR value

0:03:02.530,0:03:07.510
so of course we're going to prefer

0:03:04.799,0:03:11.410
strictly c1 over C 3

0:03:07.510,0:03:14.530
if we compare c1 with C 2 the situation

0:03:11.410,0:03:17.980
is much less less clear c1 has a lower

0:03:14.530,0:03:21.010
FPR value but c2 has a higher TPR value

0:03:17.980,0:03:23.079
and again without extra information on

0:03:21.010,0:03:25.120
misclassification costs we can't really

0:03:23.079,0:03:32.609
decide which of these two systems is

0:03:25.120,0:03:36.760
preferable obviously the best ever

0:03:32.609,0:03:41.650
potential system is located here and the

0:03:36.760,0:03:45.670
top left corner now for this system we

0:03:41.650,0:03:48.180
have a TP R of 1 and an F P R of 0 and

0:03:45.670,0:03:52.600
that can only happen if we produce zero

0:03:48.180,0:03:54.850
errors on the positive class and on the

0:03:52.600,0:03:56.260
negative class and of course if that

0:03:54.850,0:03:58.000
happens we also don't really have to

0:03:56.260,0:04:02.350
talk about costs right if no have there

0:03:58.000,0:04:05.829
us having it happen anyway on the day

0:04:02.350,0:04:07.209
out and and this if if we would see such

0:04:05.829,0:04:09.370
a potential solution and this solution

0:04:07.209,0:04:11.049
is going to dominate everything else and

0:04:09.370,0:04:13.470
we of course would happily select that

0:04:11.049,0:04:15.880
actually normally if we would see such a

0:04:13.470,0:04:19.239
solution in a real-world problem we

0:04:15.880,0:04:22.050
might worry a bit about label leakage or

0:04:19.239,0:04:24.520
some other error we might have

0:04:22.050,0:04:25.830
introduced into our evaluation procedure

0:04:24.520,0:04:29.099
because normally we

0:04:25.830,0:04:32.310
I get something like this the worst

0:04:29.099,0:04:36.439
possible candidates do not really lie

0:04:32.310,0:04:41.400
down here but they actually lie on this

0:04:36.439,0:04:44.789
main diagonal of the ROC space so on

0:04:41.400,0:04:49.409
this main diagonal classifiers produce

0:04:44.789,0:04:52.439
random labels random 0 1 labels without

0:04:49.409,0:04:54.539
looking at the features so these are

0:04:52.439,0:04:57.960
pretty bad systems they're not learning

0:04:54.539,0:05:00.090
anything um here we have a system that

0:04:57.960,0:05:04.310
always predicts negative class labels

0:05:00.090,0:05:08.280
here we have a system that predicts

0:05:04.310,0:05:11.190
positive classes with 25% of probability

0:05:08.280,0:05:13.710
here with 75% of probability and here

0:05:11.190,0:05:17.180
with 100% of probabilities here we

0:05:13.710,0:05:21.440
always predict positive classes without

0:05:17.180,0:05:23.729
considering any feature value at all so

0:05:21.440,0:05:28.680
for such a system if we predict

0:05:23.729,0:05:30.810
everything as positive obviously the TP

0:05:28.680,0:05:32.490
R is 1 right because everything from the

0:05:30.810,0:05:34.949
positive class we predict also is being

0:05:32.490,0:05:37.590
positive while everything from the

0:05:34.949,0:05:42.690
negative class we also predict wrongly

0:05:37.590,0:05:45.650
as positive so the fpr is also 1 for

0:05:42.690,0:05:50.069
this point here now where we predict the

0:05:45.650,0:05:55.139
positive class with 25% probability we

0:05:50.069,0:05:59.069
get a TP are also of 25% why well

0:05:55.139,0:06:01.800
because for every observation from the

0:05:59.069,0:06:04.830
positive class we assign a random label

0:06:01.800,0:06:09.120
and with 25% probability we assign

0:06:04.830,0:06:12.810
positive as the predicted label so TPR

0:06:09.120,0:06:17.629
is 25% for everything from the natural

0:06:12.810,0:06:21.029
class and we also assign a positive

0:06:17.629,0:06:23.699
label 25% of the time these are exactly

0:06:21.029,0:06:25.589
the errors we are producing on the

0:06:23.699,0:06:28.909
negative class so we have an F P are

0:06:25.589,0:06:28.909
also of 25%

0:06:29.460,0:06:36.659
and practice we should actually never

0:06:33.400,0:06:39.490
really obtain a classifier which is

0:06:36.659,0:06:41.349
significantly below this diagonal why

0:06:39.490,0:06:44.770
because this is really not a bad

0:06:41.349,0:06:47.139
classifier we could from this classifier

0:06:44.770,0:06:49.599
produce a very good one

0:06:47.139,0:06:52.750
simply by inverting its predictive

0:06:49.599,0:06:56.289
labels also transforming every predict 0

0:06:52.750,0:07:00.389
into a 1 and vice versa and this would

0:06:56.289,0:07:04.270
reflect in this ROC coordinate system

0:07:00.389,0:07:07.389
our point at the main diagonal residing

0:07:04.270,0:07:10.210
in a good classifier in this upper

0:07:07.389,0:07:16.599
triangular part here so if you would for

0:07:10.210,0:07:18.789
example have a system with FP R 1 and T

0:07:16.599,0:07:21.099
P R 0 we can do the same trick and would

0:07:18.789,0:07:24.389
end up with a perfect classifier on the

0:07:21.099,0:07:26.050
other hand if that happens our

0:07:24.389,0:07:27.669
classification system has basically

0:07:26.050,0:07:36.159
learned the opposite of what it should

0:07:27.669,0:07:38.199
have learned so there's I guess - yeah

0:07:36.159,0:07:39.789
scenario is possible how to think about

0:07:38.199,0:07:41.650
this the first one is the first thing I

0:07:39.789,0:07:43.719
would probably do is to just look an

0:07:41.650,0:07:45.580
arrow in my arm and the code that I've

0:07:43.719,0:07:48.009
written because there's probably some

0:07:45.580,0:07:50.740
some label flipping going on if that's

0:07:48.009,0:07:52.060
not true and I really have learned the

0:07:50.740,0:07:56.469
opposite of what I should have learned I

0:07:52.060,0:07:59.699
would yeah worry even more because then

0:07:56.469,0:07:59.699
something extremely strange has happened

0:08:00.900,0:08:10.830
ROC this is our C metric so have one

0:08:08.469,0:08:13.569
nice property and this is that they are

0:08:10.830,0:08:18.400
insensitive so-called insensitive to

0:08:13.569,0:08:20.500
class distribution changes during

0:08:18.400,0:08:23.949
prediction time so what I mean with that

0:08:20.500,0:08:30.639
is that if we consider such a situation

0:08:23.949,0:08:33.159
here where we have the same amount of

0:08:30.639,0:08:35.409
examples in the positive class as in the

0:08:33.159,0:08:41.729
negative class so n plus divided by n

0:08:35.409,0:08:41.729
minus is one yeah 50/50 and

0:08:41.800,0:08:49.509
now we consider the miss classification

0:08:47.079,0:08:50.860
error of this system here we can see

0:08:49.509,0:08:57.579
that the miss classification error is

0:08:50.860,0:09:01.110
these 35 counts now these 35 elements

0:08:57.579,0:09:05.230
that we predict incorrectly if we

0:09:01.110,0:09:07.899
compute the true positive Reds and the

0:09:05.230,0:09:09.579
false positive red we see directly that

0:09:07.899,0:09:17.079
the TPR is 0.8

0:09:09.579,0:09:19.179
now 40/50 and the fpr is 0.5 25 also

0:09:17.079,0:09:21.790
divided by 50 now

0:09:19.179,0:09:27.160
let's double the size of a positive

0:09:21.790,0:09:31.929
class so our proportions change to n

0:09:27.160,0:09:35.160
plus divided by n minus equals 2 so at

0:09:31.929,0:09:38.100
prediction time we now simply use more

0:09:35.160,0:09:40.329
examples from the positive class

0:09:38.100,0:09:45.040
now our miss classification error

0:09:40.329,0:09:47.799
actually changes as you can see here now

0:09:45.040,0:09:52.929
forty five elements are classified

0:09:47.799,0:09:54.339
incorrectly from 150 and this reduces to

0:09:52.929,0:09:57.549
a miss classification error of not

0:09:54.339,0:10:02.850
thirty five percent but thirty percent

0:09:57.549,0:10:02.850
so by simply changing the proportion of

0:10:03.720,0:10:13.420
positive elements in our test set but

0:10:09.490,0:10:14.230
not really the simply by kind of kind of

0:10:13.420,0:10:15.819
upscaling

0:10:14.230,0:10:18.160
the number of positive elements in our

0:10:15.819,0:10:21.639
test set we have also now changed or

0:10:18.160,0:10:25.119
miss classification error evaluation on

0:10:21.639,0:10:28.179
that set if we consider again TPR and FP

0:10:25.119,0:10:32.439
are nothing really has changed again we

0:10:28.179,0:10:35.049
have a TPR of eighty percent point

0:10:32.439,0:10:36.639
eighty divided by 100 for this column

0:10:35.049,0:10:43.119
here and we have a false positive rate

0:10:36.639,0:10:45.489
again of 50 percent 25/50 you have to be

0:10:43.119,0:10:49.660
a bit careful here and sometimes this

0:10:45.489,0:10:54.069
factor some abbreviated a bit too

0:10:49.660,0:10:55.379
shortly by that our C analysis is simply

0:10:54.069,0:10:57.910
insensitive to classes

0:10:55.379,0:10:59.679
is really not true if you mess around

0:10:57.910,0:11:02.709
with class proportions during training

0:10:59.679,0:11:04.839
because then you're completely your

0:11:02.709,0:11:06.850
complete learned classification system

0:11:04.839,0:11:08.740
can change estimated posterior

0:11:06.850,0:11:11.589
probabilities can change can sometimes

0:11:08.740,0:11:14.319
drastically change for example reduce

0:11:11.589,0:11:17.139
one of the classes to an extremely small

0:11:14.319,0:11:19.899
size then maybe only the largest class

0:11:17.139,0:11:23.529
is going to be predicted predicted at

0:11:19.899,0:11:25.990
all and then basically all bets can be

0:11:23.529,0:11:30.879
off and we actually sometimes have to

0:11:25.990,0:11:34.720
repair this situation too by upscaling

0:11:30.879,0:11:44.230
I'm the smaller class again up weighting

0:11:34.720,0:11:47.009
it now until here I have only considered

0:11:44.230,0:11:51.069
binary classifiers which produce

0:11:47.009,0:11:53.829
discrete class levels of course nearly

0:11:51.069,0:11:58.449
all of our models that we nowadays have

0:11:53.829,0:12:01.569
available all of these models are able

0:11:58.449,0:12:04.679
to output and continue scores very often

0:12:01.569,0:12:07.209
continuous probabilities so they can

0:12:04.679,0:12:11.410
output and model posterior probabilities

0:12:07.209,0:12:14.199
for class one what we can do with these

0:12:11.410,0:12:18.149
posterior probabilities is we can

0:12:14.199,0:12:21.519
convert them as I've already said into

0:12:18.149,0:12:23.860
discrete Labor's by threshold during

0:12:21.519,0:12:26.709
them at a specific value and with

0:12:23.860,0:12:29.110
threshold I mean of the estimate

0:12:26.709,0:12:34.929
posterior probability from observation

0:12:29.110,0:12:39.040
acts exceeds this threshold tau here we

0:12:34.929,0:12:41.410
assign a predicted predicted label of

0:12:39.040,0:12:43.389
one so a positive class and if it's

0:12:41.410,0:12:46.540
below that threshold we predict zero the

0:12:43.389,0:12:50.649
negative class and normally we would

0:12:46.540,0:12:55.499
probably use a threshold of 0.5 now as I

0:12:50.649,0:12:59.079
also already told you in the unit on

0:12:55.499,0:13:02.049
performance metrics and for

0:12:59.079,0:13:03.100
classification and the Briers war and

0:13:02.049,0:13:05.470
the la crosse

0:13:03.100,0:13:09.010
but for imbalanced and cost sensitive

0:13:05.470,0:13:13.649
situations this threshold at Point

0:13:09.010,0:13:17.649
five is neither required necessary nor

0:13:13.649,0:13:19.149
always beneficial right because if

0:13:17.649,0:13:23.290
everything is imbalanced and cost

0:13:19.149,0:13:28.209
sensitive it might be we are interesting

0:13:23.290,0:13:31.690
attractive to more liberally or more

0:13:28.209,0:13:35.889
conservatively predict the positive

0:13:31.690,0:13:39.490
class anyway whatever Thresh would be

0:13:35.889,0:13:43.959
select here after Thresh willing we have

0:13:39.490,0:13:46.750
transformed our continuous probability

0:13:43.959,0:13:49.680
scores into discrete class levels and

0:13:46.750,0:13:56.410
therefore we can now evaluate this

0:13:49.680,0:14:01.120
discretized system with any performance

0:13:56.410,0:14:03.310
metric that is possible for discrete

0:14:01.120,0:14:06.160
class levels and which I have introduced

0:14:03.310,0:14:09.010
so far so we can use accuracy we can use

0:14:06.160,0:14:11.920
any normal RC metric or we can use the

0:14:09.010,0:14:14.380
f1 score or if we don't do the threshold

0:14:11.920,0:14:18.459
of course we can use all of these

0:14:14.380,0:14:21.579
metrics for probability outcomes like

0:14:18.459,0:14:22.839
rious for the lock loss or the area the

0:14:21.579,0:14:26.670
under the curve which I'm going to

0:14:22.839,0:14:35.680
introduce very soon in this unit here

0:14:26.670,0:14:39.250
now the ROC curve kind of relies and is

0:14:35.680,0:14:43.360
defined on this threshold enough

0:14:39.250,0:14:46.589
classifiers so because we don't really

0:14:43.360,0:14:51.660
know what threshold is actually best and

0:14:46.589,0:14:54.610
we can't also really optimize for a

0:14:51.660,0:14:58.329
perfect threshold now because we don't

0:14:54.610,0:15:01.600
really have a single objective clear

0:14:58.329,0:15:04.170
performance metric available in these

0:15:01.600,0:15:08.560
imbalance situations with unknown costs

0:15:04.170,0:15:11.470
what the ROC analysis does is it

0:15:08.560,0:15:15.220
iterates through all potential

0:15:11.470,0:15:18.490
thresholds calculates FPR and TPR values

0:15:15.220,0:15:20.260
for all of these barriers induced binary

0:15:18.490,0:15:21.580
classification systems and then

0:15:20.260,0:15:23.920
visualizes them

0:15:21.580,0:15:26.290
and all at the same time so you can see

0:15:23.920,0:15:29.590
the complete spectrum of solutions you

0:15:26.290,0:15:32.080
get from different trade-offs and this

0:15:29.590,0:15:37.170
resulting plot is called in the ROC

0:15:32.080,0:15:41.110
curve so if you set small thresholds you

0:15:37.170,0:15:46.030
very very liberally predict class 1 now

0:15:41.110,0:15:49.650
for example the threshold of 0.1 will

0:15:46.030,0:15:53.230
assign every posterior probability of

0:15:49.650,0:15:56.980
larger than 10% to plasma and this will

0:15:53.230,0:15:59.050
very likely happen very often and so

0:15:56.980,0:16:04.060
this will result in a classification

0:15:59.050,0:16:09.400
system with an extremely high F P R but

0:16:04.060,0:16:11.320
also very high T P R if you choose a

0:16:09.400,0:16:14.230
very high threshold you will only very

0:16:11.320,0:16:18.640
conservatively predict class 1 and this

0:16:14.230,0:16:20.770
will of course restrict the amount of

0:16:18.640,0:16:23.340
false positive errors you're making but

0:16:20.770,0:16:31.420
it will also very likely result a name

0:16:23.340,0:16:36.880
only quite small true positive rate so

0:16:31.420,0:16:40.570
um let's now draw this ROC curve step by

0:16:36.880,0:16:42.220
step to see how it works out so you're

0:16:40.570,0:16:45.640
going to do this by ranking our

0:16:42.220,0:16:49.120
observations depending or with regard to

0:16:45.640,0:16:54.250
decreasing score then we'll start with

0:16:49.120,0:16:57.240
the highest threshold possible which is

0:16:54.250,0:17:01.020
a value of 1 and we start in the origin

0:16:57.240,0:17:03.790
actually let me directly maybe go to the

0:17:01.020,0:17:07.720
animation so I can explain this here so

0:17:03.790,0:17:11.050
assume we have 12 only 12 observations

0:17:07.720,0:17:15.190
here in our toy example and six of those

0:17:11.050,0:17:18.850
are truly from class positive so here

0:17:15.190,0:17:23.470
are the six positive elements and then

0:17:18.850,0:17:26.980
six are from the negative class and here

0:17:23.470,0:17:30.280
you can see The Associated scores from

0:17:26.980,0:17:32.460
our binary classifier under

0:17:30.280,0:17:35.290
consideration and I've already ordered

0:17:32.460,0:17:37.630
these observations we

0:17:35.290,0:17:42.040
regard to decreasing score and now I

0:17:37.630,0:17:45.150
will start here in the origin at FP r

0:17:42.040,0:17:50.020
equals zero and TP r equals zero with a

0:17:45.150,0:17:52.660
classifier with that threshold one so

0:17:50.020,0:17:55.630
this classifier with a threshold one

0:17:52.660,0:17:58.660
will assign everything to the negative

0:17:55.630,0:18:01.540
class now because there no posterior

0:17:58.660,0:18:03.700
probability will be larger than one so

0:18:01.540,0:18:07.300
this means nothing is assigned to the

0:18:03.700,0:18:10.680
positive class so f of f PR of zero and

0:18:07.300,0:18:16.150
also unfortunately only a TPR of zero

0:18:10.680,0:18:19.060
now after I've drawn this point here now

0:18:16.150,0:18:21.310
I will create a threshold that is

0:18:19.060,0:18:23.710
exactly between the first observation

0:18:21.310,0:18:28.560
and all of the other ones for example I

0:18:23.710,0:18:33.520
could use I don't know point 9 now

0:18:28.560,0:18:36.220
because this observation here this blue

0:18:33.520,0:18:38.560
one is from the positive class I know

0:18:36.220,0:18:40.510
that my false positive rate stays the

0:18:38.560,0:18:42.790
same right because I haven't changed

0:18:40.510,0:18:45.540
anything from the negative class but

0:18:42.790,0:18:48.580
this positive example I have now

0:18:45.540,0:18:51.130
correctly labelled also as positive so

0:18:48.580,0:18:53.020
my t PR goes up a bit and I can actually

0:18:51.130,0:18:55.810
calculate how much it goes up because

0:18:53.020,0:19:01.170
there's only six elements in the

0:18:55.810,0:19:08.130
positive class it will go up by 1/6

0:19:01.170,0:19:11.040
which is about 0.167

0:19:08.130,0:19:15.790
now the next element again is positive

0:19:11.040,0:19:19.240
if I now set my threshold here between

0:19:15.790,0:19:23.560
these two observations to I don't know

0:19:19.240,0:19:31.510
something like 0.85 again I will go up

0:19:23.560,0:19:33.220
by one sixth and again I will go up to

0:19:31.510,0:19:37.030
this year for the third possible

0:19:33.220,0:19:39.160
threshold now the next element is

0:19:37.030,0:19:41.080
actually negative so the true positive

0:19:39.160,0:19:44.200
rate stays the same because I'm not

0:19:41.080,0:19:45.820
changing any prediction on that positive

0:19:44.200,0:19:47.100
class what I'm changing is a prediction

0:19:45.820,0:19:50.269
on the negative class

0:19:47.100,0:19:55.080
I'm not incorrectly labeling this

0:19:50.269,0:19:57.419
element here as positive although it is

0:19:55.080,0:19:59.730
it and that's actually the only mistake

0:19:57.419,0:20:02.220
until now that I'm creating

0:19:59.730,0:20:04.679
other than that I'm producing on the

0:20:02.220,0:20:09.269
negative class now another positive

0:20:04.679,0:20:10.799
element and so on and so on and after

0:20:09.269,0:20:13.019
I've iterated through all of these

0:20:10.799,0:20:15.000
different thresholds I have produced

0:20:13.019,0:20:17.610
this curve here which doesn't look very

0:20:15.000,0:20:20.820
smooth because I've only in this toy

0:20:17.610,0:20:22.649
example consider twelve twelve

0:20:20.820,0:20:24.929
observations and this is what I'm going

0:20:22.649,0:20:27.779
to call the ROC curve and this ROC curve

0:20:24.929,0:20:29.669
now encodes all of the different

0:20:27.779,0:20:33.330
thresholds sorry all of the different

0:20:29.669,0:20:35.100
binary classification systems I can

0:20:33.330,0:20:37.950
create by just using different

0:20:35.100,0:20:41.639
thresholds and this allows me to produce

0:20:37.950,0:20:44.970
a wide spectrum of differently behaving

0:20:41.639,0:20:47.519
systems with more ones and more zeros

0:20:44.970,0:20:50.399
being predicted and different GPRS and

0:20:47.519,0:20:53.730
fpr's and although I still don't know

0:20:50.399,0:20:56.519
how to objectively select now a point

0:20:53.730,0:20:59.730
from this curve maybe by producing this

0:20:56.519,0:21:01.710
curve thinking about this thinking about

0:20:59.730,0:21:05.490
it discussing this with my with my

0:21:01.710,0:21:07.559
client I cannot come up with a certain

0:21:05.490,0:21:10.259
threshold an operating point here on the

0:21:07.559,0:21:13.919
curve that I like and that I can now

0:21:10.259,0:21:17.870
select and the whole idea behind doing

0:21:13.919,0:21:22.289
that compared to specifying costs a

0:21:17.870,0:21:24.990
priori is that specifying the costs

0:21:22.289,0:21:26.759
without knowing anything about the

0:21:24.990,0:21:30.299
potential candidate solutions is very

0:21:26.759,0:21:32.519
hard if you are being shown all of the

0:21:30.299,0:21:35.700
potential systems that you could use

0:21:32.519,0:21:40.250
maybe it's much easier to select one of

0:21:35.700,0:21:40.250
these as the one you want to implement

0:21:42.259,0:21:50.899
here's an example of four different

0:21:45.720,0:21:54.149
types of our C curves you could produce

0:21:50.899,0:21:57.179
from scoring classifier so for example

0:21:54.149,0:21:59.700
this green one here are very close to

0:21:57.179,0:22:00.320
the diagonal line so if you are exactly

0:21:59.700,0:22:04.100
on the diagram

0:22:00.320,0:22:07.880
again this would be a random system not

0:22:04.100,0:22:10.280
learning anything this year close to

0:22:07.880,0:22:15.400
this top-left corner would be a very

0:22:10.280,0:22:19.190
good scoring classifier and then here I

0:22:15.400,0:22:20.480
have drawn two kind of okayish systems

0:22:19.190,0:22:22.700
somewhere between in the middle and you

0:22:20.480,0:22:28.270
can also see one other thing here and

0:22:22.700,0:22:31.190
this is that yes this dark blue system

0:22:28.270,0:22:33.760
dominates all of the other three but if

0:22:31.190,0:22:36.020
you compare these two you can see

0:22:33.760,0:22:38.000
something that happens quite often in

0:22:36.020,0:22:39.980
these situations and that is that is

0:22:38.000,0:22:43.100
that these are RC curves actually cross

0:22:39.980,0:22:46.340
here so depending on where you want to

0:22:43.100,0:22:48.920
be in your rock space either the green

0:22:46.340,0:22:53.150
curve or the blue one is actually better

0:22:48.920,0:22:54.500
and this again you can't really specify

0:22:53.150,0:22:56.000
objectively you have to think about

0:22:54.500,0:22:58.490
where you want to be you wanna have a

0:22:56.000,0:23:07.790
larger TPR or you wanna have a smaller

0:22:58.490,0:23:09.590
FPR if you really want to drill down the

0:23:07.790,0:23:11.390
evaluation of such a scoring classifier

0:23:09.590,0:23:14.290
again to a single number one thing you

0:23:11.390,0:23:16.640
can do is you can calculate the AUC

0:23:14.290,0:23:19.820
again I'm worrying a little bit against

0:23:16.640,0:23:22.850
this don't do this if you have to the

0:23:19.820,0:23:24.890
full ROC curve and plot is I think much

0:23:22.850,0:23:30.590
more informative but if you want to

0:23:24.890,0:23:32.630
tabulate dozens of models if you want to

0:23:30.590,0:23:35.960
optimize over hundreds of models and

0:23:32.630,0:23:38.840
being able to rank stuff is convenient

0:23:35.960,0:23:41.900
and one way to go about this is the area

0:23:38.840,0:23:45.800
under the curve the name should already

0:23:41.900,0:23:47.630
kind of tell you its definition so you

0:23:45.800,0:23:50.930
produce the ROC curve and then you

0:23:47.630,0:23:54.320
simply calculate the area under that

0:23:50.930,0:23:57.350
curve by integrating over this curve now

0:23:54.320,0:24:00.680
so it's well it simply is the area under

0:23:57.350,0:24:02.750
that curve and if the AOC is one you

0:24:00.680,0:24:07.910
have a perfect classifier whose ROC

0:24:02.750,0:24:10.940
curve goes like that a classifier with

0:24:07.910,0:24:13.230
an AMC of 0.5 would

0:24:10.940,0:24:21.450
pretty much lie here on this diagonal

0:24:13.230,0:24:24.270
and be yeah denote the worst possible

0:24:21.450,0:24:26.880
system and then again a classifier with

0:24:24.270,0:24:28.590
a or C equals zero or something below

0:24:26.880,0:24:30.360
point five actually should not happen

0:24:28.590,0:24:33.450
because again we can do this inverting

0:24:30.360,0:24:36.330
of labor's trick and then produce a much

0:24:33.450,0:24:38.760
better classifier out of that bad one

0:24:36.330,0:24:40.770
and this bad one has kind of learned the

0:24:38.760,0:24:43.010
opposite of what it what it should have

0:24:40.770,0:24:43.010
learned

0:24:43.039,0:24:48.360
besides this hey the AUC is the area

0:24:46.409,0:24:51.390
under this war curve there's a second

0:24:48.360,0:24:53.539
nice interpretation of a you see that

0:24:51.390,0:24:58.230
you should also know and this is that

0:24:53.539,0:25:03.110
the AUC is exactly the following

0:24:58.230,0:25:07.950
probability if you select randomly an

0:25:03.110,0:25:10.350
element from the positive class in this

0:25:07.950,0:25:12.270
case I think we with selected this

0:25:10.350,0:25:14.370
element here randomly from the positive

0:25:12.270,0:25:16.740
class and then we select the second

0:25:14.370,0:25:18.600
element randomly but from the negative

0:25:16.740,0:25:22.350
class so for example this element here

0:25:18.600,0:25:26.870
and on both elements we consider the

0:25:22.350,0:25:33.570
predicted scores by our classifier and

0:25:26.870,0:25:37.070
we now calculate whether these two

0:25:33.570,0:25:40.020
elements are ranked correctly

0:25:37.070,0:25:43.529
so whether the score of the positive

0:25:40.020,0:25:45.870
element is higher than the score on the

0:25:43.529,0:25:49.559
selected negative element than the

0:25:45.870,0:25:50.610
probability that this ranking is

0:25:49.559,0:25:57.860
actually correct

0:25:50.610,0:26:03.960
is exactly the value of the AUC one last

0:25:57.860,0:26:06.299
final well generalization the AUC so one

0:26:03.960,0:26:10.130
thing I sometimes do not like too much

0:26:06.299,0:26:14.610
about the AOC is that very often you

0:26:10.130,0:26:16.289
integrate out over large portions of the

0:26:14.610,0:26:18.720
curve that you're not really interested

0:26:16.289,0:26:21.090
in for example again think about these

0:26:18.720,0:26:22.990
types of medical applications where you

0:26:21.090,0:26:25.270
really really really want an extreme

0:26:22.990,0:26:27.730
hi true positive red because having a

0:26:25.270,0:26:31.929
lower positive red means well sending

0:26:27.730,0:26:34.360
people home who are classified as being

0:26:31.929,0:26:36.880
healthy while they are actually sick so

0:26:34.360,0:26:39.970
you are now integrating out over for

0:26:36.880,0:26:43.890
example parts of your RC a space with

0:26:39.970,0:26:49.720
the TPR of 0.1 now so true negatives of

0:26:43.890,0:26:52.360
90% maybe of 80% 70% and you would never

0:26:49.720,0:26:55.270
implement or consider any of these

0:26:52.360,0:26:58.510
systems anyway why should you do this

0:26:55.270,0:27:01.270
done in this integration of the AOC

0:26:58.510,0:27:05.770
value wouldn't maybe be much smarter to

0:27:01.270,0:27:10.300
think about certain regions like minimal

0:27:05.770,0:27:13.000
and maximal boundaries where inside of

0:27:10.300,0:27:16.150
these boundaries you would be interested

0:27:13.000,0:27:18.370
in implementing such a system we can so

0:27:16.150,0:27:19.360
what we are basically going to do is put

0:27:18.370,0:27:21.850
in constraints

0:27:19.360,0:27:24.010
reasonable constraints now either on TPR

0:27:21.850,0:27:26.440
or an FPR so for example we could say

0:27:24.010,0:27:28.900
our a false positive rate should be

0:27:26.440,0:27:32.650
below 20% otherwise we're not going to

0:27:28.900,0:27:36.550
consider anything beyond this anything

0:27:32.650,0:27:39.370
worse that at all or we might say that

0:27:36.550,0:27:42.160
our TPR and this is maybe more

0:27:39.370,0:27:44.980
appropriate for this medical example I'm

0:27:42.160,0:27:49.020
using again and again so our TPR needs

0:27:44.980,0:27:52.510
to be at least 80% so the amount of

0:27:49.020,0:27:58.540
false false negatives is below 20% and

0:27:52.510,0:28:01.480
then only beyond these limits and

0:27:58.540,0:28:03.780
constraints we are now calculating the

0:28:01.480,0:28:07.870
area under the curve by integrating over

0:28:03.780,0:28:11.200
this area here or integrating over this

0:28:07.870,0:28:13.300
area and if we do that we call this the

0:28:11.200,0:28:15.160
partially AUC and yes this is a little

0:28:13.300,0:28:16.900
bit harder do you find because you have

0:28:15.160,0:28:19.800
to think a bit more about what you

0:28:16.900,0:28:24.330
actually want which types of systems

0:28:19.800,0:28:29.020
yeah you deem worthy enough to implement

0:28:24.330,0:28:32.740
on the other hand it's probably much

0:28:29.020,0:28:34.330
more appropriate in realistic

0:28:32.740,0:28:38.250
applications

0:28:34.330,0:28:38.250
of binary image systems

