0:00:02.469,0:00:08.380
welcome to our next part on evaluating

0:00:05.980,0:00:11.870
about evaluating machine learning models

0:00:08.380,0:00:16.789
on reasoning and cross-validation so

0:00:11.870,0:00:20.140
until now we have learned one reliable

0:00:16.789,0:00:23.210
technique to estimate the generalization

0:00:20.140,0:00:26.019
performance of an MA model and this is

0:00:23.210,0:00:28.819
through hood out training test splits

0:00:26.019,0:00:32.980
but we have also learned that there's

0:00:28.819,0:00:36.260
kind of an inherent unresolved of the

0:00:32.980,0:00:38.690
trade-off conflict going on when we do

0:00:36.260,0:00:40.340
training test fitting when we do train

0:00:38.690,0:00:44.480
test splits and this is a four data set

0:00:40.340,0:00:47.750
is not too large um at the same time lot

0:00:44.480,0:00:49.910
like to increase our training set size

0:00:47.750,0:00:52.490
as much as possible to reduce the

0:00:49.910,0:00:54.200
pessimistic bias in a generalization

0:00:52.490,0:00:57.740
performance estimation but we also would

0:00:54.200,0:00:59.840
like to make our test set as large as

0:00:57.740,0:01:03.429
possible to reduce variance of course we

0:00:59.840,0:01:07.759
can't do both things at the same time

0:01:03.429,0:01:08.740
but resampling is a nice way out of this

0:01:07.759,0:01:11.679
problem

0:01:08.740,0:01:14.600
so resampling uses our data much more

0:01:11.679,0:01:18.439
efficiently than just doing a simpler

0:01:14.600,0:01:22.219
training test plot and the whole trick

0:01:18.439,0:01:24.530
is pretty simple and works like this so

0:01:22.219,0:01:27.219
our first observation is that we really

0:01:24.530,0:01:31.219
dislike the pessimistic bias introduced

0:01:27.219,0:01:33.579
through two small training sets and

0:01:31.219,0:01:38.509
because we can't really repair this

0:01:33.579,0:01:40.249
anymore if that happens so what we are

0:01:38.509,0:01:46.189
going to do is we're going to make our

0:01:40.249,0:01:48.130
and training sets quite large in order

0:01:46.189,0:01:51.679
to reduce that pessimistic bias of

0:01:48.130,0:01:54.469
course if that if we do that testing

0:01:51.679,0:01:56.630
sets will become quite small now and

0:01:54.469,0:01:58.549
variance of our performance estimator

0:01:56.630,0:02:01.369
the variance of a performance estimator

0:01:58.549,0:02:04.939
it goes up considerably now the usual

0:02:01.369,0:02:07.099
trick to repair that is just do the

0:02:04.939,0:02:09.759
whole thing repeatedly now I mean it's

0:02:07.099,0:02:12.750
the whole splitting a stochastic anyway

0:02:09.759,0:02:16.630
so we do this building multiple times

0:02:12.750,0:02:21.520
repeated and an average to smooth out

0:02:16.630,0:02:23.830
the random error yeah over my tab

0:02:21.520,0:02:26.530
repetitious this is the usual trick in

0:02:23.830,0:02:28.959
statistics and to deal with this type of

0:02:26.530,0:02:34.870
problem and this allows us to have large

0:02:28.959,0:02:39.850
training sets a nearly unbiased

0:02:34.870,0:02:42.910
performance estimator but also reduced

0:02:39.850,0:02:45.310
variance through the repetition in

0:02:42.910,0:02:48.820
averaging and this is what is called

0:02:45.310,0:02:52.300
resampling so repeated training test

0:02:48.820,0:02:54.209
splits and repeat the performance

0:02:52.300,0:02:59.350
estimation that at the end we averaged

0:02:54.209,0:03:01.480
and one of the most well known and

0:02:59.350,0:03:05.140
popular techniques for this is a

0:03:01.480,0:03:06.910
cross-validation which really uses our

0:03:05.140,0:03:07.260
available data in a very efficient

0:03:06.910,0:03:10.239
manner

0:03:07.260,0:03:12.760
so press validation looks like this you

0:03:10.239,0:03:15.700
take or complete data set we split it

0:03:12.760,0:03:17.650
into K parts these K parts I usually

0:03:15.700,0:03:23.200
call it fourths before we do this

0:03:17.650,0:03:25.870
usually commute our data set wants to

0:03:23.200,0:03:27.190
break up any unwanted ordering or

0:03:25.870,0:03:31.959
structure and the data I don't know

0:03:27.190,0:03:33.910
maybe in the first observations I don't

0:03:31.959,0:03:35.140
know the first observations or the

0:03:33.910,0:03:36.760
observations are actually ordered back

0:03:35.140,0:03:38.739
class and collected by class and we

0:03:36.760,0:03:41.140
really don't want to have these types of

0:03:38.739,0:03:43.480
artifacts in there in the ordering of

0:03:41.140,0:03:45.880
our data when we split up so we randomly

0:03:43.480,0:03:48.700
permuted commute everything and then we

0:03:45.880,0:03:52.360
split it into K Falls K parts of roughly

0:03:48.700,0:03:55.090
equal size and in each iteration of our

0:03:52.360,0:03:57.750
cross-validation one of these parts one

0:03:55.090,0:04:01.750
of these Falls exactly one will become

0:03:57.750,0:04:04.510
the test set so here in the first

0:04:01.750,0:04:07.989
iteration the first two parts the first

0:04:04.510,0:04:11.070
blue parts will be joined to become our

0:04:07.989,0:04:14.590
training set and we train a model on

0:04:11.070,0:04:17.970
well their joint observations and we

0:04:14.590,0:04:17.970
predict on the test set

0:04:18.569,0:04:29.400
on these predictions we can now compute

0:04:24.030,0:04:34.030
an average error measure and stall that

0:04:29.400,0:04:35.860
in the second iteration of our second

0:04:34.030,0:04:37.930
fold of our cross validation we do

0:04:35.860,0:04:39.880
exactly the same now this part of the

0:04:37.930,0:04:42.310
data has become the test set these two

0:04:39.880,0:04:44.620
have become the training set and we can

0:04:42.310,0:04:48.130
induce a model on the combined training

0:04:44.620,0:04:50.500
set we predict on the test set we get a

0:04:48.130,0:04:52.780
second score in two and the third fold

0:04:50.500,0:04:55.030
we do exactly the same again now this

0:04:52.780,0:04:58.509
guy here becomes the testing set and we

0:04:55.030,0:05:00.759
obtain a third performance score and at

0:04:58.509,0:05:04.509
the end of across validation we average

0:05:00.759,0:05:10.080
all of these three scores here and

0:05:04.509,0:05:13.180
output their average as our estimated

0:05:10.080,0:05:16.389
generalization error I have here

0:05:13.180,0:05:18.699
describes three foot cross-validation of

0:05:16.389,0:05:21.880
course there's two foils are five or ten

0:05:18.699,0:05:27.039
fold jar you can freely select how many

0:05:21.880,0:05:29.409
folds you would like to perform another

0:05:27.039,0:05:31.720
nice aspect of cross-validation is that

0:05:29.409,0:05:32.830
each observation and this is what we

0:05:31.720,0:05:34.630
kind of mean when we say that

0:05:32.830,0:05:39.280
cross-validation uses the data very

0:05:34.630,0:05:41.560
efficiently that each observation in our

0:05:39.280,0:05:42.789
original data set is being tested

0:05:41.560,0:05:46.479
exactly once

0:05:42.789,0:05:50.550
so for each observation in our data set

0:05:46.479,0:05:53.530
for example this one here this is being

0:05:50.550,0:05:56.710
this is being partitioned or assigned to

0:05:53.530,0:05:58.990
exactly one test data set so it's also

0:05:56.710,0:06:01.389
being predicted on exactly once and so

0:05:58.990,0:06:04.120
for each observation we have exactly one

0:06:01.389,0:06:08.830
true label and exactly one predicted

0:06:04.120,0:06:13.479
level so at the end you obtain one

0:06:08.830,0:06:15.130
vector of predictions now if you would

0:06:13.479,0:06:17.949
join the predictions on this set and on

0:06:15.130,0:06:20.020
this set on this set for each

0:06:17.949,0:06:22.919
observation in the original set so it's

0:06:20.020,0:06:26.830
kind of like using the complete data set

0:06:22.919,0:06:29.250
for for testing up in a fair and

0:06:26.830,0:06:29.250
balanced manner

0:06:29.729,0:06:39.190
there is um a second or a reserve usual

0:06:37.380,0:06:42.130
extension of normal cross-validation

0:06:39.190,0:06:44.800
which is called stratification which you

0:06:42.130,0:06:48.849
very often consider if you have an

0:06:44.800,0:06:51.970
imbalanced class distribution especially

0:06:48.849,0:06:56.199
for the targets so imagine for example

0:06:51.970,0:06:59.710
that you have a pretty imbalanced binary

0:06:56.199,0:07:02.319
classification situation where you have

0:06:59.710,0:07:04.990
a lot more observations here in the

0:07:02.319,0:07:07.150
orange class than the blue one so what

0:07:04.990,0:07:11.050
can happen now is that if you split up

0:07:07.150,0:07:14.530
the data into three different parts

0:07:11.050,0:07:20.590
randomly now then just by pure chance

0:07:14.530,0:07:24.180
and I bet luck in a couple of these

0:07:20.590,0:07:27.940
faults the amount of blue observations

0:07:24.180,0:07:30.009
can become even smaller as it already is

0:07:27.940,0:07:35.820
just because it was through I don't know

0:07:30.009,0:07:40.979
an unbalanced partitioning

0:07:35.820,0:07:46.830
stratification and show us that in each

0:07:40.979,0:07:51.000
fold and in each split exactly the same

0:07:46.830,0:07:53.080
proportion of orange and blue

0:07:51.000,0:07:54.699
observations is present and this is

0:07:53.080,0:07:59.370
ensured in a very very simple manner

0:07:54.699,0:07:59.370
where instead of splitting up the

0:07:59.490,0:08:06.099
complete data set into K parts we now

0:08:02.710,0:08:08.110
split up let's let's let's say we do a

0:08:06.099,0:08:10.930
3/4 cross relation with three splits

0:08:08.110,0:08:15.009
then we split up the orange part here

0:08:10.930,0:08:17.680
into three equal into three parts of

0:08:15.009,0:08:21.099
equal size and we split up the blue part

0:08:17.680,0:08:23.680
here into the blue class into three

0:08:21.099,0:08:30.099
parts of equal size and then we join

0:08:23.680,0:08:34.169
these parts now now you can see that so

0:08:30.099,0:08:37.589
all so three

0:08:34.169,0:08:40.380
equal equal sized orange parts three

0:08:37.589,0:08:43.529
equal sized blue parts and then you join

0:08:40.380,0:08:45.660
these two guys here together to generate

0:08:43.529,0:08:48.329
a new training set and this is going to

0:08:45.660,0:08:51.420
be your new test set so this ensures

0:08:48.329,0:08:54.269
that in these individual forwards but

0:08:51.420,0:08:58.040
also in the combined sets the same

0:08:54.269,0:09:00.810
proportion of blue and orange

0:08:58.040,0:09:04.170
observations is always available now and

0:09:00.810,0:09:08.070
that at least the blue class doesn't

0:09:04.170,0:09:11.360
become smaller as it has to be just by

0:09:08.070,0:09:14.250
bad luck and and random chat and usually

0:09:11.360,0:09:17.880
this ratification doesn't hurt if you

0:09:14.250,0:09:20.190
apply this even in more balanced

0:09:17.880,0:09:23.070
situations and you can also apply

0:09:20.190,0:09:24.240
stratification not only on class labels

0:09:23.070,0:09:26.579
but you could also apply this on

0:09:24.240,0:09:29.339
features and I don't know in imbalanced

0:09:26.579,0:09:30.930
feature of males and females and you

0:09:29.339,0:09:32.820
want to stratify on that or even on a

0:09:30.930,0:09:38.490
combination of some features that's also

0:09:32.820,0:09:41.040
possible some comments on cross

0:09:38.490,0:09:44.730
validation so very often five or ten

0:09:41.040,0:09:49.199
folds are common setting because if you

0:09:44.730,0:09:52.170
use five faults you already use 80% of

0:09:49.199,0:09:53.940
data for training and we split your data

0:09:52.170,0:09:56.579
into five parts four are being used for

0:09:53.940,0:09:58.860
training one is used for testing and if

0:09:56.579,0:10:00.839
you use ten folds ninety percent of data

0:09:58.860,0:10:02.610
are being used for training so this

0:10:00.839,0:10:06.510
pessimistic bias becomes smaller and

0:10:02.610,0:10:09.360
smaller and smaller if you use K equals

0:10:06.510,0:10:11.459
n so you split up your data set into

0:10:09.360,0:10:13.019
exactly as many parts as you have

0:10:11.459,0:10:15.060
observations and this is called leave

0:10:13.019,0:10:17.310
one out cross validation of course this

0:10:15.060,0:10:19.290
is rather expensive if you implement

0:10:17.310,0:10:22.800
this naively because you then have to

0:10:19.290,0:10:25.519
fit n models if you have 10,000

0:10:22.800,0:10:28.829
observations have to fit 10,000 models

0:10:25.519,0:10:32.130
on the other hand and you are using than

0:10:28.829,0:10:35.399
nearly as many observations during

0:10:32.130,0:10:37.769
resampling as your final model will also

0:10:35.399,0:10:41.220
see now use an N minus 1 observations

0:10:37.769,0:10:42.130
for training and later on your model

0:10:41.220,0:10:47.200
will be

0:10:42.130,0:10:49.350
and observations so all of these cross

0:10:47.200,0:10:51.820
validation procedures have a slight

0:10:49.350,0:10:55.150
pessimistic biased because they still

0:10:51.820,0:10:57.910
use less data now then in on the other

0:10:55.150,0:11:00.130
hand if you use a higher number of false

0:10:57.910,0:11:03.300
more than five more than ten more than

0:11:00.130,0:11:06.520
twenty this pessimistic bias will become

0:11:03.300,0:11:10.090
rather small and not really noticeable

0:11:06.520,0:11:12.730
that much anymore and if you want to you

0:11:10.090,0:11:14.950
could go as a half as high up as leaf

0:11:12.730,0:11:17.710
100 then it's a comparison between n

0:11:14.950,0:11:19.990
minus 1 and n and your data set will not

0:11:17.710,0:11:22.060
only consist of I don't know 20 or 30

0:11:19.990,0:11:25.240
observations but more likely or at least

0:11:22.060,0:11:28.300
a hundred or 200 huh and then this

0:11:25.240,0:11:32.080
pessimistic bias is nearly not there

0:11:28.300,0:11:34.060
anymore um one thing you should keep

0:11:32.080,0:11:37.420
keep in mind is that the performance

0:11:34.060,0:11:41.200
estimate you compute from these

0:11:37.420,0:11:47.890
individual faults and loops so these

0:11:41.200,0:11:52.210
guys here yeah you these are not going

0:11:47.890,0:12:01.420
to be independent so add so one is kind

0:11:52.210,0:12:07.540
of I don't know one one often things

0:12:01.420,0:12:09.820
about considering this collection of

0:12:07.540,0:12:11.440
values as an independent sample may be

0:12:09.820,0:12:14.980
from something even like a normal

0:12:11.440,0:12:16.660
distribution and but it really isn't and

0:12:14.980,0:12:20.700
you have to be quite careful if you then

0:12:16.660,0:12:23.650
calculate I don't know stuff like

0:12:20.700,0:12:25.960
variances or standard estimation from

0:12:23.650,0:12:29.320
this alternative energy vs from this

0:12:25.960,0:12:31.060
collection of values or if you for

0:12:29.320,0:12:32.530
example you run to cross-validation for

0:12:31.060,0:12:38.710
two different models and then you would

0:12:32.530,0:12:41.980
like to test these two samples against

0:12:38.710,0:12:43.980
each other in order to figure out

0:12:41.980,0:12:49.210
whether there's a significant difference

0:12:43.980,0:12:51.370
in mean location the iid assumption

0:12:49.210,0:12:52.949
really does not hold here and the reason

0:12:51.370,0:12:56.999
for this is that

0:12:52.949,0:12:59.910
when you construct your training sets

0:12:56.999,0:13:02.819
your training sets are largely

0:12:59.910,0:13:06.839
overlapping and they're overlapping even

0:13:02.819,0:13:09.199
more the larger your number of folds as

0:13:06.839,0:13:12.720
now so in the extreme if you're using

0:13:09.199,0:13:17.160
leave one out cross validation there's n

0:13:12.720,0:13:23.459
minus two observations that are the same

0:13:17.160,0:13:26.639
in each pair of two to false or to cross

0:13:23.459,0:13:28.919
validation iterations now and therefore

0:13:26.639,0:13:31.189
also these performance estimators here

0:13:28.919,0:13:33.589
will not really be independent and

0:13:31.189,0:13:37.379
there's actually very complicated

0:13:33.589,0:13:42.919
correlation structure going on which

0:13:37.379,0:13:45.829
makes the calculation of the variance of

0:13:42.919,0:13:47.730
the cross validation performance values

0:13:45.829,0:13:50.549
somewhere between hard and impossible

0:13:47.730,0:13:53.459
and there's actually theoretical

0:13:50.549,0:13:54.959
considerations that prove that you can't

0:13:53.459,0:13:59.160
cannot really produce an unbiased

0:13:54.959,0:14:04.379
estimator of the of the variance for the

0:13:59.160,0:14:06.449
cross validation um and this is also the

0:14:04.379,0:14:09.509
reason why nowadays leave one out cross

0:14:06.449,0:14:11.459
validation has somewhat fallen out of

0:14:09.509,0:14:15.509
little bits of slightly falling out of

0:14:11.459,0:14:16.049
favor because although it is nearly I'm

0:14:15.509,0:14:20.040
biased

0:14:16.049,0:14:23.459
although this pessimistic bias is nearly

0:14:20.040,0:14:26.369
not there at all it has quite a high

0:14:23.459,0:14:30.059
variance as an estimator because of

0:14:26.369,0:14:31.429
these this correlation going on between

0:14:30.059,0:14:33.899
the different leave one out cross

0:14:31.429,0:14:37.639
validation iterations and the large

0:14:33.899,0:14:40.529
overlap of the training data sets and

0:14:37.639,0:14:43.499
alternative option is to use a repeated

0:14:40.529,0:14:45.449
k-fold cross-validation so you just do

0:14:43.499,0:14:47.100
multiple random cross validation

0:14:45.449,0:14:50.609
partitions I mean the cross relation

0:14:47.100,0:14:52.709
itself is done randomly and done

0:14:50.609,0:14:55.769
somewhat arbitrarily so why not do this

0:14:52.709,0:14:57.389
a couple of times if you think that your

0:14:55.769,0:15:00.569
cross validation estimator might

0:14:57.389,0:15:04.280
fluctuate still a lot because on your

0:15:00.569,0:15:06.740
original data set is pretty small

0:15:04.280,0:15:08.840
then one standard option is run a

0:15:06.740,0:15:12.140
10-fold around 24 cross-validation and

0:15:08.840,0:15:16.670
repeat this ten five and what 20 times

0:15:12.140,0:15:21.970
to average out the stock historicity

0:15:16.670,0:15:26.180
here and this is nowadays more preferred

0:15:21.970,0:15:29.180
protocol for dealing with small small

0:15:26.180,0:15:31.490
data sets below I don't know 200 or 500

0:15:29.180,0:15:35.660
observations instead of running even out

0:15:31.490,0:15:38.240
on this one alternative I'm to

0:15:35.660,0:15:40.910
cross-validation bootstrap so here the

0:15:38.240,0:15:43.520
idea is to draw B training data sets of

0:15:40.910,0:15:45.620
size n so kind of the motivation is to

0:15:43.520,0:15:47.900
create training sets which are really of

0:15:45.620,0:15:51.980
the same size as the original data set

0:15:47.900,0:15:53.930
and we can only reach that by drawing

0:15:51.980,0:15:56.540
from the original data set with

0:15:53.930,0:15:58.850
repetition now so this is the usual

0:15:56.540,0:16:01.190
bootstrap approach where we draw from

0:15:58.850,0:16:04.150
this original set here with replacement

0:16:01.190,0:16:06.560
now as long and as often if we have

0:16:04.150,0:16:08.630
until we have produced a set of the same

0:16:06.560,0:16:10.430
size and of course if we draw with

0:16:08.630,0:16:14.120
replacement some of these observations

0:16:10.430,0:16:17.150
in here some of the observations from

0:16:14.120,0:16:19.640
the original set will be in the newly

0:16:17.150,0:16:25.339
generated sets two times three times

0:16:19.640,0:16:28.190
four times now these observations were

0:16:25.339,0:16:30.980
usually called in back and the remaining

0:16:28.190,0:16:32.900
observations we haven't drawn so for

0:16:30.980,0:16:35.390
example you for this first said this

0:16:32.900,0:16:39.250
would be the green the green guy and for

0:16:35.390,0:16:42.860
the second set would be the this black

0:16:39.250,0:16:46.910
observation and the so-called out of

0:16:42.860,0:16:50.900
back observations are going to become

0:16:46.910,0:16:56.360
our Associated test set for the

0:16:50.900,0:16:57.950
respective training set typically we

0:16:56.360,0:17:05.170
construct somewhere I don't know between

0:16:57.950,0:17:07.310
30 and 200 different bootstraps splits

0:17:05.170,0:17:12.549
and of course the variance of a

0:17:07.310,0:17:16.369
bootstrap estimator tends to be smaller

0:17:12.549,0:17:20.419
the variance of our k4 truss validation

0:17:16.369,0:17:22.639
estimator because training sets are at

0:17:20.419,0:17:26.869
least a bit more independently drawn and

0:17:22.639,0:17:29.450
discontinued discontinuities are a bit

0:17:26.869,0:17:32.080
more smooth code here and of course the

0:17:29.450,0:17:35.299
more iterations perform in the bootstrap

0:17:32.080,0:17:39.190
more expensive the estimator becomes but

0:17:35.299,0:17:42.529
also the smaller the variance is of our

0:17:39.190,0:17:46.850
constructed generalization performance

0:17:42.529,0:17:49.190
estimator the bootstrap is also somewhat

0:17:46.850,0:17:49.970
pessimistically biased because the

0:17:49.190,0:17:52.639
training sets

0:17:49.970,0:17:56.269
well they kind of artificially container

0:17:52.639,0:18:02.600
when observations but in reality only

0:17:56.269,0:18:04.669
about now roughly two-thirds of the

0:18:02.600,0:18:11.179
observations are actually uniquely

0:18:04.669,0:18:15.019
different and because at least the

0:18:11.179,0:18:20.239
variance and the independence well

0:18:15.019,0:18:21.889
because the because although our

0:18:20.239,0:18:24.559
observations are not perfectly

0:18:21.889,0:18:30.230
independent about the variance structure

0:18:24.559,0:18:34.820
of the constructed performance value

0:18:30.230,0:18:36.169
some bits is a bit now more well behaved

0:18:34.820,0:18:40.820
and get what we get from

0:18:36.169,0:18:42.379
cross-validation using this

0:18:40.820,0:18:44.809
bootstrapping framework might actually

0:18:42.379,0:18:50.480
allow the use of formal inference

0:18:44.809,0:18:54.759
methods for my tests being um for

0:18:50.480,0:18:54.759
example use to compare different

0:18:54.940,0:18:59.869
performance estimation samples yeah with

0:18:58.220,0:19:02.179
respect to significant differences you

0:18:59.869,0:19:05.869
can also they're also um protocols for

0:19:02.179,0:19:07.419
running tests on cross-validation scores

0:19:05.869,0:19:10.669
but this is usually a bit harder and

0:19:07.419,0:19:14.480
sometimes also a bit more heuristic and

0:19:10.669,0:19:17.119
they also exist interesting extensions

0:19:14.480,0:19:20.779
for very small data sets and that also

0:19:17.119,0:19:22.110
use the training error for for

0:19:20.779,0:19:24.870
estimation of

0:19:22.110,0:19:27.870
hopefully improved estimation of the

0:19:24.870,0:19:29.460
generalization performance error try to

0:19:27.870,0:19:35.399
be a bit more efficient here so there's

0:19:29.460,0:19:39.210
B 6 3 2 and B 6 3 2 plus by f1 which I'm

0:19:35.399,0:19:43.380
not going to cover here that's the third

0:19:39.210,0:19:46.830
type of resampling procedure which is

0:19:43.380,0:19:49.620
very very simple to explain called

0:19:46.830,0:19:51.299
subsampling and this is just repeated

0:19:49.620,0:19:54.090
holdout with averaging so instead of

0:19:51.299,0:19:56.220
running our hearts bleeding once and

0:19:54.090,0:19:57.750
estimating the test arrow just on one

0:19:56.220,0:19:59.700
test set we just do this a couple of

0:19:57.750,0:20:00.720
times and then average this this is also

0:19:59.700,0:20:03.090
sometimes called Monte Carlo

0:20:00.720,0:20:05.190
cross-validation and this is also can

0:20:03.090,0:20:06.899
also compare this to bootstrap so it

0:20:05.190,0:20:08.840
kind of it's the same as bootstrap but

0:20:06.899,0:20:12.870
we are now drawing without replacement

0:20:08.840,0:20:15.659
and typical choices for the splitting

0:20:12.870,0:20:18.059
rate here are not again with the same

0:20:15.659,0:20:19.679
argument for in in general for

0:20:18.059,0:20:22.289
resampling we try to make the training

0:20:19.679,0:20:26.210
sets larger to reduce the pessimistic

0:20:22.289,0:20:32.840
bias and then prepare the variance by

0:20:26.210,0:20:35.130
repeated sampling and averaging and

0:20:32.840,0:20:39.720
therefore two bigger choices for

0:20:35.130,0:20:43.230
splitting are 80% or 90% or 95% for

0:20:39.720,0:20:44.669
training of course the smaller we select

0:20:43.230,0:20:46.590
the sub something right the larger the

0:20:44.669,0:20:48.299
pessimistic bias would be and the more

0:20:46.590,0:20:50.159
sampler sampling iterations we perform

0:20:48.299,0:20:57.210
and the smaller the variance of our

0:20:50.159,0:21:01.110
estimator I have now extended the

0:20:57.210,0:21:06.620
bias-variance analysis example that are

0:21:01.110,0:21:07.909
already showed you for our hold out a

0:21:06.620,0:21:10.440
unit

0:21:07.909,0:21:12.360
so let's reconsider this now that our

0:21:10.440,0:21:15.320
sampling and see what happens and let's

0:21:12.360,0:21:19.529
see whether we can somehow motivate that

0:21:15.320,0:21:21.929
resampling is a good idea so I'm running

0:21:19.529,0:21:25.500
exactly the same thing as before maybe

0:21:21.929,0:21:28.679
it if you can't remember the somewhat

0:21:25.500,0:21:31.620
complex setup for this experiment

0:21:28.679,0:21:33.190
read it again so I was using the spiral

0:21:31.620,0:21:38.320
dataset

0:21:33.190,0:21:39.430
I was running a cart algorithm on this I

0:21:38.320,0:21:41.620
was trying to estimate the

0:21:39.430,0:21:45.310
generalization performance of that cart

0:21:41.620,0:21:46.840
algorithm if I gave the three 500

0:21:45.310,0:21:49.660
observations and I tried out different

0:21:46.840,0:21:56.290
split rates for the holdup speeding so

0:21:49.660,0:21:59.620
5% 10% 20% or 95% of the data used for

0:21:56.290,0:22:04.180
training and the rest used for testing

0:21:59.620,0:22:05.890
and then what we saw was that well if we

0:22:04.180,0:22:08.230
use very small training data sets that's

0:22:05.890,0:22:10.210
this pessimistic bias and a fuse a very

0:22:08.230,0:22:13.990
small test data sets fastest increase

0:22:10.210,0:22:16.380
variance and at the end an optimal

0:22:13.990,0:22:18.610
splitting rate was somewhere around

0:22:16.380,0:22:20.410
two-thirds of the data used for training

0:22:18.610,0:22:24.270
and one third of the data use for

0:22:20.410,0:22:28.060
testing kind of the sweet spot between

0:22:24.270,0:22:32.140
not that much pessimistic bias and not

0:22:28.060,0:22:35.320
so highly increased variance because of

0:22:32.140,0:22:38.170
small test says I'm not doing exactly

0:22:35.320,0:22:39.970
the same and I'm kind of reusing my

0:22:38.170,0:22:42.100
results for the holdout splitting but

0:22:39.970,0:22:47.890
I'm also now running as a comparison

0:22:42.100,0:22:55.810
method 50 subsampling experiments on top

0:22:47.890,0:22:57.350
of these 50 holder experiments so for

0:22:55.810,0:23:00.510
each

0:22:57.350,0:23:03.000
potentials literate I not only compute

0:23:00.510,0:23:05.730
one holdout experiment but also compute

0:23:03.000,0:23:09.830
one subsampling experiment where do

0:23:05.730,0:23:12.660
repeated training and test splits with s

0:23:09.830,0:23:16.710
equals five percent FS equals one

0:23:12.660,0:23:18.300
percent s equals at 20 percent this is

0:23:16.710,0:23:19.920
of course much more expensive because of

0:23:18.300,0:23:23.130
the repeated splitting and averaging for

0:23:19.920,0:23:27.890
one experiment but let's see whether

0:23:23.130,0:23:34.460
that kind of helps us a bit in better

0:23:27.890,0:23:39.720
Araya summation so this is if I not only

0:23:34.460,0:23:42.030
plot the resulting box plots for our

0:23:39.720,0:23:45.210
holed out experiments this you have all

0:23:42.030,0:23:50.340
seen before in the unit on training test

0:23:45.210,0:23:52.110
evaluation but next to these blue box

0:23:50.340,0:23:53.880
plots you see these green ones here from

0:23:52.110,0:23:58.400
the subsampling and what you can easily

0:23:53.880,0:24:01.620
see is that the pessimistic bias of

0:23:58.400,0:24:03.770
holdout splitting and subsampling is

0:24:01.620,0:24:05.880
pretty much the same why well because

0:24:03.770,0:24:07.920
mainly depends on the splitting rate

0:24:05.880,0:24:09.690
right and the spilling red is the same

0:24:07.920,0:24:12.090
for holdout and sub something but what

0:24:09.690,0:24:14.160
is quite different is the variance right

0:24:12.090,0:24:16.530
because what subsampling we're not using

0:24:14.160,0:24:19.260
one training test but we are using my

0:24:16.530,0:24:22.170
tablet and an averaging over them so

0:24:19.260,0:24:24.150
this immediately reduces the variance of

0:24:22.170,0:24:32.040
our performance estimator which is a

0:24:24.150,0:24:33.720
good thing so if we go from the left

0:24:32.040,0:24:35.310
hand side to the right hand side what

0:24:33.720,0:24:37.860
you see is that the pessimistic bias

0:24:35.310,0:24:40.260
goes down down down now for subsampling

0:24:37.860,0:24:46.490
as for hotels bidding but the variance

0:24:40.260,0:24:50.250
doesn't go that much up now so this

0:24:46.490,0:24:53.400
potentially allows us to push the

0:24:50.250,0:24:55.560
boundary now for the optimist bleeding

0:24:53.400,0:25:01.740
red much further to the right hand side

0:24:55.560,0:25:04.670
and now use about 90% of data as an

0:25:01.740,0:25:04.670
optimist blood red

0:25:06.330,0:25:14.850
for for subsampling and repair the

0:25:11.610,0:25:20.690
increased the increased variance

0:25:14.850,0:25:26.820
it's basically repaired mitigated by the

0:25:20.690,0:25:30.240
repeated averaging going on in the in

0:25:26.820,0:25:32.630
this subsampling what you can also see

0:25:30.240,0:25:37.020
is that the subsampling estimated says

0:25:32.630,0:25:41.070
for each split read that i've considered

0:25:37.020,0:25:43.890
here is strictly better than everything

0:25:41.070,0:25:46.950
i have produced in the for the holdup

0:25:43.890,0:25:50.010
estimator again i was measuring this by

0:25:46.950,0:25:52.350
MSE now so i'm computing the squared

0:25:50.010,0:25:56.600
difference between each element here in

0:25:52.350,0:26:00.390
the box plot and the true generalization

0:25:56.600,0:26:04.280
performance of a misclassification error

0:26:00.390,0:26:06.960
oh I don't know about eleven percent and

0:26:04.280,0:26:09.810
if I now compare these two estimators

0:26:06.960,0:26:13.020
the subsampling estimator is strictly

0:26:09.810,0:26:15.720
better and its optimal value is

0:26:13.020,0:26:18.000
somewhere around here for splitting red

0:26:15.720,0:26:21.360
with ninety percent you might ask

0:26:18.000,0:26:27.540
yourself hey why can't I even use 95 or

0:26:21.360,0:26:31.440
99 percent for for splitting and the

0:26:27.540,0:26:35.130
reason why you see this little increase

0:26:31.440,0:26:36.750
here again in MSE is actually the same

0:26:35.130,0:26:39.060
reason that we already discussed belief

0:26:36.750,0:26:42.750
one hour cross-validation the larger we

0:26:39.060,0:26:45.420
make the training data sets the more

0:26:42.750,0:26:47.640
overlapping they become and the

0:26:45.420,0:26:49.620
estimators or the numbers we are

0:26:47.640,0:26:52.470
averaging here in subsampling I'm not

0:26:49.620,0:26:54.630
perfectly independent and the larger the

0:26:52.470,0:26:56.940
splitting rate is the more correlated

0:26:54.630,0:27:01.190
that they are and at the end we are

0:26:56.940,0:27:03.900
averaging not over an independent sample

0:27:01.190,0:27:06.330
of a bunch of numbers but over a

0:27:03.900,0:27:07.680
correlated sample and if the correlation

0:27:06.330,0:27:13.050
becomes stronger and stronger and

0:27:07.680,0:27:15.750
stronger the beneficial effect of our

0:27:13.050,0:27:17.850
averaging they would be independent we

0:27:15.750,0:27:21.960
know that

0:27:17.850,0:27:24.869
variants would go down live in a linear

0:27:21.960,0:27:27.509
fashion but that doesn't hold true

0:27:24.869,0:27:30.600
anymore if we average over correlated

0:27:27.509,0:27:33.539
samples which we really do here in this

0:27:30.600,0:27:38.820
case and then the more correlated larger

0:27:33.539,0:27:41.700
the split reddit um so let's discuss

0:27:38.820,0:27:46.590
this a bit and wrap everything up so in

0:27:41.700,0:27:50.070
ml at the end we will fit one model on

0:27:46.590,0:27:51.330
all of our given data we really need to

0:27:50.070,0:27:55.019
know how well this model is going to

0:27:51.330,0:27:58.229
perform in the future because otherwise

0:27:55.019,0:28:01.379
work well if the model is otherwise

0:27:58.229,0:28:03.960
we're just blind right and we don't want

0:28:01.379,0:28:06.239
to blindly trust our predictor might be

0:28:03.960,0:28:10.590
that the model is behaving pretty badly

0:28:06.239,0:28:15.539
and then we don't really want to I don't

0:28:10.590,0:28:18.559
know publish or implement this but if we

0:28:15.539,0:28:21.840
have already used up all of the data

0:28:18.559,0:28:25.320
during fitting and there is no data left

0:28:21.840,0:28:27.359
to reliably compute this performance

0:28:25.320,0:28:31.159
score anymore so what we have to do is

0:28:27.359,0:28:34.979
to kind of approximate this number

0:28:31.159,0:28:40.340
through a different alternative process

0:28:34.979,0:28:42.450
and this is recently so we try to

0:28:40.340,0:28:45.419
construct the protocol where we use

0:28:42.450,0:28:48.359
merely endpoints for training the

0:28:45.419,0:28:50.989
remaining points for testing train on

0:28:48.359,0:28:55.019
the training sets test on this headset

0:28:50.989,0:28:59.849
iterate an average the resulting

0:28:55.019,0:29:01.489
performance performance was called

0:28:59.849,0:29:03.899
oscillation be something they all

0:29:01.489,0:29:06.539
estimate exactly this number there are

0:29:03.899,0:29:13.609
all alternative ways to just estimate

0:29:06.539,0:29:13.609
this important performance score

0:29:14.940,0:29:20.970
and split leaking resampling and

0:29:18.840,0:29:24.450
cross-validation and subsampling we only

0:29:20.970,0:29:27.540
produce just that one number or just

0:29:24.450,0:29:29.490
that I don't know sample of performance

0:29:27.540,0:29:33.060
values they do not really produce models

0:29:29.490,0:29:34.590
parameters etc so I'm I'm very often

0:29:33.060,0:29:41.220
being asked if I run cross-validation

0:29:34.590,0:29:43.020
now like yeah I'm producing three models

0:29:41.220,0:29:45.870
right which of these models do I

0:29:43.020,0:29:49.200
actually I don't know publish discuss

0:29:45.870,0:29:52.140
put in my paper which of the parameter

0:29:49.200,0:29:55.440
vectors of these models who I report who

0:29:52.140,0:29:57.480
I use the answers none of them you're

0:29:55.440,0:30:03.450
only running cross-validation to produce

0:29:57.480,0:30:05.760
a an estimator of the generalization

0:30:03.450,0:30:07.770
performance and the model you are going

0:30:05.760,0:30:09.300
to publish and report is the model

0:30:07.770,0:30:10.830
you're going to fit on the complete data

0:30:09.300,0:30:14.670
set at the end because that's the one

0:30:10.830,0:30:17.340
you want to use all of this stuff here

0:30:14.670,0:30:18.600
is just being run and performed so you

0:30:17.340,0:30:22.140
get your hands on the average

0:30:18.600,0:30:25.200
performance from these from these values

0:30:22.140,0:30:26.670
here at the end so the models um I kind

0:30:25.200,0:30:28.740
of just intermediate results and

0:30:26.670,0:30:30.720
discarded of course it's allowed to

0:30:28.740,0:30:32.460
store them it's allowed to look at them

0:30:30.720,0:30:34.530
it's maybe also allowed to worry a bit

0:30:32.460,0:30:39.450
if you see that they randomly fluctuate

0:30:34.530,0:30:44.610
a lot that you're producing um a highly

0:30:39.450,0:30:48.000
stochastic model here if your parameter

0:30:44.610,0:30:50.300
estimators change a lot you can do lots

0:30:48.000,0:30:52.830
of stuff if you know what you're doing

0:30:50.300,0:30:55.350
but strictly speaking cross-validation

0:30:52.830,0:31:00.500
first and foremost is a procedure just

0:30:55.350,0:31:00.500
for performance score estimation

0:31:02.570,0:31:07.490
let's see them with anything else left

0:31:05.530,0:31:10.370
um yeah

0:31:07.490,0:31:12.230
well there's one final point this is a

0:31:10.370,0:31:13.810
bit weird and sometimes confusing for

0:31:12.230,0:31:16.430
the beginner and complicated but

0:31:13.810,0:31:19.790
unfortunately this is how it is an ml

0:31:16.430,0:31:21.800
and bad news is it becomes even more

0:31:19.790,0:31:23.840
confusing if we have to talk about

0:31:21.800,0:31:29.270
tuning and nested cross validation but

0:31:23.840,0:31:33.020
this will come in a later unit um okay

0:31:29.270,0:31:36.320
um maybe some some final comments for

0:31:33.020,0:31:38.630
practice so I already said that five or

0:31:36.320,0:31:39.410
ten for cross-validation are somewhat

0:31:38.630,0:31:42.260
standard nowadays

0:31:39.410,0:31:44.660
um it's not a very good idea to use

0:31:42.260,0:31:45.980
something like hold out or cross

0:31:44.660,0:31:47.750
validation with a few number of

0:31:45.980,0:31:49.130
iterations or subsampling with the low

0:31:47.750,0:31:53.420
subsampling rate if you have a very

0:31:49.130,0:31:55.280
small data set this can cause the

0:31:53.420,0:31:57.590
estimator to be extremely biased

0:31:55.280,0:32:00.170
I'm also can cause quite a lot of

0:31:57.590,0:32:02.990
variance for smaller data situations

0:32:00.170,0:32:04.610
with less than 500 to our observations

0:32:02.990,0:32:07.010
is probably good idea to use leave one

0:32:04.610,0:32:10.310
out or nowadays probably better to use

0:32:07.010,0:32:11.810
repeat cross-validation so 10 times 10

0:32:10.310,0:32:16.100
forward repeated across relation has

0:32:11.810,0:32:17.540
become a standard or use 20 folds um we

0:32:16.100,0:32:19.940
can also repeat this 10 or too many

0:32:17.540,0:32:22.100
times depends a bit also on how

0:32:19.940,0:32:25.040
expensive your model fitting is and how

0:32:22.100,0:32:29.770
much time you have um if you have

0:32:25.040,0:32:34.010
already said that if you have a large

0:32:29.770,0:32:37.070
data set available but a very imbalance

0:32:34.010,0:32:41.210
class situation now may you might still

0:32:37.070,0:32:44.210
have the problem of yeah small sample

0:32:41.210,0:32:46.640
sizes and high variance or performance

0:32:44.210,0:32:48.620
estimators normally if you would have I

0:32:46.640,0:32:50.780
don't know 100,000 or 500,000

0:32:48.620,0:32:53.420
observations you wouldn't really have to

0:32:50.780,0:32:56.060
worry about I'm doing repeated splits

0:32:53.420,0:32:58.460
now if everything is kind of balanced if

0:32:56.060,0:33:01.960
not maybe you do have to repeat things

0:32:58.460,0:33:05.620
so this is why it's very hard to give

0:33:01.960,0:33:07.700
reliable rules for running these

0:33:05.620,0:33:10.100
performance estimation protocols you

0:33:07.700,0:33:11.559
also have to use a bit your own

0:33:10.100,0:33:15.129
intelligence you have

0:33:11.559,0:33:19.090
a bit of exploratory analysis and think

0:33:15.129,0:33:20.769
about problems that might work or an

0:33:19.090,0:33:22.840
estimation and how you how you could do

0:33:20.769,0:33:25.149
this properly and I hope you I taught

0:33:22.840,0:33:28.539
you I'm the most important concepts in

0:33:25.149,0:33:30.850
this unit now I should also say that if

0:33:28.539,0:33:33.480
you only worry about speed for leave one

0:33:30.850,0:33:36.519
out there are some computationally fast

0:33:33.480,0:33:39.600
exact calculations or approximations for

0:33:36.519,0:33:43.269
some model classes available um

0:33:39.600,0:33:45.909
and modern results seem to indicate that

0:33:43.269,0:33:48.129
some sampling has somewhat better

0:33:45.909,0:33:51.100
properties than bootstrapping I also

0:33:48.129,0:33:53.499
have to say that I nearly never nowadays

0:33:51.100,0:33:56.860
really use bootstrapping for these types

0:33:53.499,0:33:59.970
of ML performance estimations usually

0:33:56.860,0:34:02.679
these repeated observations caused um

0:33:59.970,0:34:05.440
can cause problems and training

0:34:02.679,0:34:07.720
algorithms especially in nested setups

0:34:05.440,0:34:11.139
where this training setup is split up

0:34:07.720,0:34:12.819
again now in kind of an inner loop and

0:34:11.139,0:34:15.790
then you have these repeated

0:34:12.819,0:34:20.950
measurements ending up simultaneously

0:34:15.790,0:34:22.810
and training and test sets and this is

0:34:20.950,0:34:27.300
really not a good thing because then you

0:34:22.810,0:34:30.099
kind of again having the problem of

0:34:27.300,0:34:32.710
training on observations that are also

0:34:30.099,0:34:36.849
being used a test time which you

0:34:32.710,0:34:38.470
normally never want and sometimes just

0:34:36.849,0:34:43.329
the repeated measurements itself can

0:34:38.470,0:34:46.139
also result in numerical or problems for

0:34:43.329,0:34:46.139
the fitting algorithm

