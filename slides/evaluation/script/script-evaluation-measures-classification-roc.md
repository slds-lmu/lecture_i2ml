0:00:02.070,0:00:08.109
to our next unit on the evaluation of ML

0:00:05.590,0:00:12.599
systems so this is our C analysis part

0:00:08.109,0:00:15.489
one so our AC analysis is all about

0:00:12.599,0:00:20.109
evaluating binary classification systems

0:00:15.489,0:00:24.310
for imbalanced label situations so

0:00:20.109,0:00:28.300
imbalance label situations means that

0:00:24.310,0:00:29.829
one of the two classes is much smaller

0:00:28.300,0:00:32.290
than the other class and usually the

0:00:29.829,0:00:35.950
smaller classes also of a much higher

0:00:32.290,0:00:40.020
importance than the larger class so for

0:00:35.950,0:00:41.950
example consider a binary classifier for

0:00:40.020,0:00:46.180
diagnosing a serious medical condition

0:00:41.950,0:00:48.640
and here we can pretty much rightfully

0:00:46.180,0:00:50.730
assume that our label distribution is

0:00:48.640,0:00:54.670
going to be imbalanced so fortunately

0:00:50.730,0:00:58.120
not too many people potentially you will

0:00:54.670,0:01:02.080
have that rare disease that's we want to

0:00:58.120,0:01:06.250
model here and assume that maybe for

0:01:02.080,0:01:10.120
example only 0.5% of 1000 patients

0:01:06.250,0:01:13.120
actually have this very rare disease now

0:01:10.120,0:01:16.240
evaluating any classification system on

0:01:13.120,0:01:19.690
that task with something like the MIS

0:01:16.240,0:01:23.620
classification error or the accuracy is

0:01:19.690,0:01:25.630
very obviously inappropriate consider

0:01:23.620,0:01:27.940
for example the constant classifier that

0:01:25.630,0:01:30.010
always returns the label no disease yet

0:01:27.940,0:01:32.140
without looking at any features without

0:01:30.010,0:01:34.479
doing anything reasonable derives it

0:01:32.140,0:01:36.909
constantly just spits out no disease no

0:01:34.479,0:01:40.390
disease no disease for any observation

0:01:36.909,0:01:43.299
system if you evaluate this type of

0:01:40.390,0:01:46.590
system with the normal in this

0:01:43.299,0:01:49.270
classification error rate well obviously

0:01:46.590,0:01:51.909
this system man has a Mis classification

0:01:49.270,0:01:54.460
error rate of also only 0.5% which

0:01:51.909,0:01:56.619
sounds pretty good right but if you

0:01:54.460,0:02:00.630
think about this a bit more this is

0:01:56.619,0:02:03.760
actually the worst system you could ever

0:02:00.630,0:02:06.760
create and hopefully if hopefully not

0:02:03.760,0:02:10.230
implement because this system will send

0:02:06.760,0:02:13.750
everyone home will classify everyone as

0:02:10.230,0:02:17.050
healthy including everyone

0:02:13.750,0:02:20.080
from the from the disease group am even

0:02:17.050,0:02:22.060
classifying everyone as sick might be

0:02:20.080,0:02:24.730
better now depending on what happens

0:02:22.060,0:02:26.710
next and this problem is sometimes known

0:02:24.730,0:02:29.890
as the so-called Icarus here a paradox

0:02:26.710,0:02:34.590
which more or less simply states that

0:02:29.890,0:02:38.190
for these binary imbalance situations

0:02:34.590,0:02:40.330
it's not too smart to only look at

0:02:38.190,0:02:44.530
accuracy because that can be strongly

0:02:40.330,0:02:49.660
misleading and yeah what we should do

0:02:44.530,0:02:53.200
instead we learn very soon so there's

0:02:49.660,0:02:55.270
another very much related point of view

0:02:53.200,0:02:57.700
to understand this problem and this is

0:02:55.270,0:03:00.489
not through the lens of imbalance class

0:02:57.700,0:03:02.260
Labor's what I did before but you could

0:03:00.489,0:03:04.750
also look at this through the lens of

0:03:02.260,0:03:07.150
timberland classification costs so in

0:03:04.750,0:03:11.850
our example if you would classify a sick

0:03:07.150,0:03:15.640
patient as healthy this should pretty

0:03:11.850,0:03:18.220
obviously incur a much higher loss than

0:03:15.640,0:03:21.760
classifying a healthy patient is sick

0:03:18.220,0:03:24.730
now because these costs these

0:03:21.760,0:03:27.850
misclassification costs short very

0:03:24.730,0:03:30.489
likely depend on what happens next after

0:03:27.850,0:03:33.580
we've produced that classification and

0:03:30.489,0:03:37.870
we can likely assume in this medical

0:03:33.580,0:03:40.060
scenario here that our classification

0:03:37.870,0:03:43.140
system is not going to create fully

0:03:40.060,0:03:45.970
automatic decisions and a decide I'm

0:03:43.140,0:03:48.880
fully automatically on a subsequent

0:03:45.970,0:03:50.920
treatment for a patient what is very

0:03:48.880,0:03:56.560
likely going to happen is that if we

0:03:50.920,0:03:58.150
classify somebody as as sick this is

0:03:56.560,0:04:01.230
very likely going to be used as some

0:03:58.150,0:04:03.400
type of a screening filter now so

0:04:01.230,0:04:07.510
everyone that's going to be labeled as

0:04:03.400,0:04:10.480
sick is very likely undergoing next

0:04:07.510,0:04:12.370
second more invasive more expensive but

0:04:10.480,0:04:15.700
also more reliable test for the disease

0:04:12.370,0:04:21.430
where we can still figure out whether we

0:04:15.700,0:04:25.480
classified this patient incorrectly as

0:04:21.430,0:04:29.380
sick but erroneously sub subject

0:04:25.480,0:04:31.180
someone it sort erroneously subjecting

0:04:29.380,0:04:33.670
someone now to the second step is

0:04:31.180,0:04:35.380
obviously not good now from

0:04:33.670,0:04:38.080
psychological perspective from an

0:04:35.380,0:04:40.720
economic perspective because we are very

0:04:38.080,0:04:44.530
likely creating the automatic screening

0:04:40.720,0:04:47.800
filter exactly to avoid these costs in

0:04:44.530,0:04:51.610
many cases many hopefully correct cases

0:04:47.800,0:04:54.520
and also because that second step might

0:04:51.610,0:04:58.570
introduce further medical risks for the

0:04:54.520,0:05:01.330
patient undergoing that that next type

0:04:58.570,0:05:04.410
of diagnostic test but sending someone

0:05:01.330,0:05:07.660
home now to get worse or die there is

0:05:04.410,0:05:11.170
very obviously much much worse and we

0:05:07.660,0:05:13.680
want to avoid that at all costs and such

0:05:11.170,0:05:16.690
a situation not only arises if we have

0:05:13.680,0:05:22.450
imbalanced labor distributions but also

0:05:16.690,0:05:24.040
when well these are costs that are

0:05:22.450,0:05:24.880
connected with our decision making

0:05:24.040,0:05:28.870
process

0:05:24.880,0:05:30.340
Divac differ differ quite strongly so we

0:05:28.870,0:05:32.200
could also see this as a problem of

0:05:30.340,0:05:34.150
imbalance costs rather than imbalance

0:05:32.200,0:05:36.610
Labor's and imbalance costs could also

0:05:34.150,0:05:39.130
occur even if labor distributions are

0:05:36.610,0:05:42.280
and perfectly equal and both of these

0:05:39.130,0:05:45.190
situations are very tightly connected so

0:05:42.280,0:05:48.910
if we could specify these imbalance

0:05:45.190,0:05:54.750
costs like I for example did in the

0:05:48.910,0:05:58.840
previous unit on on Class V on

0:05:54.750,0:06:02.520
performance metric exam through a custom

0:05:58.840,0:06:06.520
Li designed cost matrix we could them

0:06:02.520,0:06:10.230
precisely evaluate against this custom

0:06:06.520,0:06:12.880
cost measure and we might even optimize

0:06:10.230,0:06:14.380
our machine learning model on the inside

0:06:12.880,0:06:18.250
directly through empirical risk

0:06:14.380,0:06:23.590
minimization against this against this

0:06:18.250,0:06:25.450
cost matrix and there's a individual

0:06:23.590,0:06:27.250
subfield of machine learning which is

0:06:25.450,0:06:29.560
called cost-sensitive learning which

0:06:27.250,0:06:33.610
deals with with exactly this type of

0:06:29.560,0:06:36.100
problem unfortunately users have a very

0:06:33.610,0:06:38.960
hard time coming up with these precise

0:06:36.100,0:06:41.479
cost numbers in imbalance scenarios

0:06:38.960,0:06:42.680
so we can't always do that if we can do

0:06:41.479,0:06:45.440
that if we can come up with these

0:06:42.680,0:06:48.800
precise numbers we have kind of boiled

0:06:45.440,0:06:51.770
this down again reduce this again to

0:06:48.800,0:06:53.570
well-defined optimization problem and

0:06:51.770,0:06:56.710
then everything is potentially much

0:06:53.570,0:06:58.820
easier we will now not assume that and

0:06:56.710,0:07:02.210
what we are going to do here in this

0:06:58.820,0:07:04.130
unit is to create different metrics to

0:07:02.210,0:07:07.550
evaluate our binary system from

0:07:04.130,0:07:10.280
different perspectives which often helps

0:07:07.550,0:07:15.169
to get a first impression of the quality

0:07:10.280,0:07:18.380
of the system so um our OSI analysis

0:07:15.169,0:07:19.910
deals with exactly this so it stands for

0:07:18.380,0:07:23.150
receiving operating characteristics

0:07:19.910,0:07:29.690
which is more or less a historical term

0:07:23.150,0:07:32.960
and the ROC curve was developed by

0:07:29.690,0:07:35.780
electrical engineers and radar engineers

0:07:32.960,0:07:39.020
during World War two stole a quote here

0:07:35.780,0:07:41.509
from Wikipedia for detecting enemy

0:07:39.020,0:07:43.570
objects and battlefields and then it was

0:07:41.509,0:07:47.360
very soon introduced to various

0:07:43.570,0:07:49.729
scientific subpoena that all have to

0:07:47.360,0:07:55.990
deal with the evaluation of binary

0:07:49.729,0:07:59.539
systems and psychology for the

0:07:55.990,0:08:01.310
perceptual detection of stimuli or in

0:07:59.539,0:08:04.449
medicine now I already gave an example

0:08:01.310,0:08:13.070
from medicine radiology biometrics

0:08:04.449,0:08:17.150
forecasting of hazards and so on and the

0:08:13.070,0:08:19.789
first step we are now going to take to

0:08:17.150,0:08:23.509
introduce more and new alternative

0:08:19.789,0:08:26.659
metrics for binary system is looking at

0:08:23.509,0:08:27.789
our two-by-two confusion matrix which

0:08:26.659,0:08:33.310
tabulates

0:08:27.789,0:08:36.729
predictions versus actual classes and

0:08:33.310,0:08:38.169
here in this two-by-two confusion matrix

0:08:36.729,0:08:42.649
tabulates

0:08:38.169,0:08:46.790
how many corrects and incorrect

0:08:42.649,0:08:50.440
labelings happened in these respective

0:08:46.790,0:08:53.110
entries and from now on I will

0:08:50.440,0:08:56.410
in this unit only consider binary

0:08:53.110,0:08:58.120
systems and I will call one of the

0:08:56.410,0:09:00.220
classes the positive class and one the

0:08:58.120,0:09:05.199
negative class and their respective

0:09:00.220,0:09:08.079
class sizes I will measure for denote

0:09:05.199,0:09:09.639
with n plus and n minus a so n plus for

0:09:08.079,0:09:12.339
the positive class I and minus for the

0:09:09.639,0:09:14.800
negative class SAS and the positive

0:09:12.339,0:09:16.930
class usually is as well hasn't anything

0:09:14.800,0:09:19.660
really positive associated with it I

0:09:16.930,0:09:22.720
mean medicine this is usually in the

0:09:19.660,0:09:24.819
class where the disease of course but

0:09:22.720,0:09:26.860
positive class means it's the important

0:09:24.819,0:09:29.769
class it's often the smaller class it's

0:09:26.860,0:09:31.720
the one o'clock it's it contains the

0:09:29.769,0:09:36.579
elements you don't kind of want to

0:09:31.720,0:09:38.560
filter out or miss and in engineering

0:09:36.579,0:09:46.259
you might call this class the signal

0:09:38.560,0:09:49.329
class and we will now give some

0:09:46.259,0:09:51.730
intuitive names to these respective

0:09:49.329,0:09:53.350
entries here of the confusion matrix so

0:09:51.730,0:09:55.509
for example we will call this entry here

0:09:53.350,0:09:58.360
the false positives because these are

0:09:55.509,0:10:01.540
all of the elements that we predicted as

0:09:58.360,0:10:04.149
class positive but where the prediction

0:10:01.540,0:10:06.939
was actually wrong so that second part

0:10:04.149,0:10:10.449
of this term specifies what we predicted

0:10:06.939,0:10:12.220
and the first part of the term specifies

0:10:10.449,0:10:13.839
whether the prediction was correct or

0:10:12.220,0:10:16.689
not now so then we have the true

0:10:13.839,0:10:18.790
positives the true negatives and the

0:10:16.689,0:10:21.790
false negatives and false negatives are

0:10:18.790,0:10:26.230
the guys we predicted as negatives but

0:10:21.790,0:10:29.740
where the prediction again was wrong and

0:10:26.230,0:10:31.750
what we now want to do is to well as a

0:10:29.740,0:10:34.149
first step at least we want to see how

0:10:31.750,0:10:36.550
many false positives did occur how many

0:10:34.149,0:10:39.720
false negatives did acquire again in

0:10:36.550,0:10:43.209
this medical scenario false positives

0:10:39.720,0:10:45.389
dang sorry false negatives are the

0:10:43.209,0:10:49.889
persons we labeled as healthy now

0:10:45.389,0:10:54.009
although they are sick so when I

0:10:49.889,0:10:56.319
probably avoid these types of errors as

0:10:54.009,0:10:58.779
much as we can what these types of

0:10:56.319,0:11:01.019
errors are bad but not as bad as these

0:10:58.779,0:11:01.019
here

0:11:01.379,0:11:10.559
and in order to introduce our our batch

0:11:07.769,0:11:16.349
of roc metrics we now do something

0:11:10.559,0:11:19.859
extremely simple we either look at rows

0:11:16.349,0:11:22.559
or columns and then compute percentages

0:11:19.859,0:11:27.599
of correct predictions either in the

0:11:22.559,0:11:30.749
columns or in the rows so for example we

0:11:27.599,0:11:32.819
can now define what is called the true

0:11:30.749,0:11:38.039
positive rate and the true positive rate

0:11:32.819,0:11:41.609
is the number or the percentage the rate

0:11:38.039,0:11:44.999
of true positives here in this first

0:11:41.609,0:11:47.249
column and then there's the true

0:11:44.999,0:11:54.089
negative rate the true natural rate is

0:11:47.249,0:11:57.569
the rate of negative well the the number

0:11:54.089,0:12:02.329
of elements from the negative class that

0:11:57.569,0:12:07.499
we also predicted as being negative and

0:12:02.329,0:12:11.009
we can do pretty much the same row-wise

0:12:07.499,0:12:12.989
now we can specify a something that's

0:12:11.009,0:12:14.549
called the positive predictive value or

0:12:12.989,0:12:16.769
the negative predictive value where the

0:12:14.549,0:12:19.769
positive predictive value is the number

0:12:16.769,0:12:23.309
of true positives divided by the number

0:12:19.769,0:12:26.459
of elements that we predicted as being

0:12:23.309,0:12:29.639
positive so there's a very intuitive way

0:12:26.459,0:12:33.179
of understanding what these metrics mean

0:12:29.639,0:12:35.519
so true positive rate is how many of the

0:12:33.179,0:12:38.159
true positive elements did we also

0:12:35.519,0:12:42.149
predict as positive while the positive

0:12:38.159,0:12:46.589
predictive value is how many or

0:12:42.149,0:12:50.399
if we predict an object as belonging to

0:12:46.589,0:12:54.389
a class one how likely is it that this

0:12:50.399,0:12:57.059
object is really of class one or if you

0:12:54.389,0:13:02.879
again consider this this medical

0:12:57.059,0:13:06.329
scenario the PPV tells you if your

0:13:02.879,0:13:10.019
medical test assigns you the disease how

0:13:06.329,0:13:12.720
likely do you truly have it t PR tells

0:13:10.019,0:13:13.600
you if you have the disease how likely

0:13:12.720,0:13:17.730
the

0:13:13.600,0:13:24.060
your tap does your test assign you to

0:13:17.730,0:13:30.910
the disease class or D detects that

0:13:24.060,0:13:33.339
disease um here's a small example um

0:13:30.910,0:13:37.019
that also um took actually from a

0:13:33.339,0:13:40.120
medical test I mean this in this case

0:13:37.019,0:13:43.540
was a screening system for bowel cancer

0:13:40.120,0:13:46.709
detection so this is a pretty rare

0:13:43.540,0:13:49.540
disease so in this case we only have 30

0:13:46.709,0:13:51.880
persons actually having that specific

0:13:49.540,0:13:55.420
type of disease but we have a control

0:13:51.880,0:13:59.350
group of 2,000 pretty much exactly 2,000

0:13:55.420,0:14:02.769
some persons not having the disease and

0:13:59.350,0:14:05.529
then we tabulated here all the correct

0:14:02.769,0:14:08.350
and the incorrect numbers of predictions

0:14:05.529,0:14:11.589
are and you can see the various

0:14:08.350,0:14:13.300
computations for these new RC metrics

0:14:11.589,0:14:14.889
I'm not going to read out every number

0:14:13.300,0:14:18.339
in every calculation but you can for

0:14:14.889,0:14:22.000
example see from 30 elements in the

0:14:18.339,0:14:26.649
positive class we detected 20 of those

0:14:22.000,0:14:30.069
resulting in a TPR of 2/3 and for the

0:14:26.649,0:14:35.259
positive predictive value well we did

0:14:30.069,0:14:39.689
correctly class did classify to any of

0:14:35.259,0:14:44.740
our positive class elements correctly as

0:14:39.689,0:14:49.930
positive but there's also 180 of the

0:14:44.740,0:14:52.290
negative class which is quite large that

0:14:49.930,0:14:55.889
we incorrectly labeled as positive

0:14:52.290,0:14:58.839
residing in a very low PPV of only 10%

0:14:55.889,0:15:01.149
so and we can now start discussing how

0:14:58.839,0:15:07.089
much we like this binary system yeah

0:15:01.149,0:15:09.550
first of all one third of the sick

0:15:07.089,0:15:14.949
patients we are missing

0:15:09.550,0:15:17.529
we are not detecting correctly while if

0:15:14.949,0:15:19.839
this medical test tells you that we have

0:15:17.529,0:15:22.000
the disease but this test is only

0:15:19.839,0:15:25.269
correct in only 10 percent of the cases

0:15:22.000,0:15:27.779
Sam so this doesn't seem too good on

0:15:25.269,0:15:27.779
both fronts

0:15:28.920,0:15:38.560
now there's even more our C metrics that

0:15:35.290,0:15:41.070
you can create from this 2x2 confusion

0:15:38.560,0:15:44.380
matrix there is four examples

0:15:41.070,0:15:47.290
yeah the false negative rate which is

0:15:44.380,0:15:49.330
simply well the inverse of the true

0:15:47.290,0:15:51.459
positive rate so this is the percentage

0:15:49.330,0:15:53.380
of false negatives here in this first

0:15:51.459,0:15:57.690
column here which is obviously also one

0:15:53.380,0:16:00.730
just one minus the T PR or you have here

0:15:57.690,0:16:03.970
the false positive rate which is one

0:16:00.730,0:16:07.390
minus the true negative rate and then

0:16:03.970,0:16:11.380
their stuff I don't know like prevalence

0:16:07.390,0:16:16.589
or negative or the false emission rate

0:16:11.380,0:16:21.160
and other stuff you can also see one

0:16:16.589,0:16:23.529
unfortunate aspect here of our C

0:16:21.160,0:16:26.880
analysis and that is that because all of

0:16:23.529,0:16:29.020
that stuff is B is being considered in

0:16:26.880,0:16:32.410
different scientific fields like

0:16:29.020,0:16:34.779
psychology and engineering there's

0:16:32.410,0:16:36.940
usually two or three different terms for

0:16:34.779,0:16:39.850
the same concept answer two positive

0:16:36.940,0:16:42.399
rate is also called recalled and also

0:16:39.850,0:16:45.730
called sensitivity false positive rate

0:16:42.399,0:16:49.510
is also called fallout the true negative

0:16:45.730,0:16:54.690
rate is also called specificity and so

0:16:49.510,0:16:59.860
on and I try to avoid all of these

0:16:54.690,0:17:03.070
alternative names in this unit and I'm

0:16:59.860,0:17:05.260
also mainly focusing on these four if

0:17:03.070,0:17:07.240
you want to read a bit more on this can

0:17:05.260,0:17:10.179
also go to big pedia where we stole this

0:17:07.240,0:17:11.650
matrix from M or go to an interactive

0:17:10.179,0:17:19.750
diagram that shows you how all of that

0:17:11.650,0:17:21.520
stuff is calculated in detail and one

0:17:19.750,0:17:23.949
thing I want to focus on a bit more

0:17:21.520,0:17:29.320
here's the so called f1 measure could

0:17:23.949,0:17:31.690
have seen this also here before um so um

0:17:29.320,0:17:33.490
as you have already seen from this

0:17:31.690,0:17:36.730
previous example it's very often

0:17:33.490,0:17:38.590
difficult to achieve simultaneously a

0:17:36.730,0:17:38.920
high positive predictive value and a

0:17:38.590,0:17:43.080
height

0:17:38.920,0:17:45.760
pyaare why well if you can somehow

0:17:43.080,0:17:48.940
massage or change your classifier so it

0:17:45.760,0:17:52.030
predicts more positives than before yes

0:17:48.940,0:17:57.900
this will result in a higher TBR map

0:17:52.030,0:17:57.900
this will also result usually in a

0:17:57.960,0:18:04.570
higher number of false positives because

0:18:01.360,0:18:06.910
you're now predicting more observations

0:18:04.570,0:18:09.880
as positive and this is the usual price

0:18:06.910,0:18:12.640
you pay so increasing your TP are

0:18:09.880,0:18:14.740
usually results in a lower PPV and

0:18:12.640,0:18:16.390
vice-versa also if you do the opposite

0:18:14.740,0:18:18.010
and you somehow change your classifier

0:18:16.390,0:18:21.130
through that it predicts more negatives

0:18:18.010,0:18:25.810
you will have a higher PPV but your TP

0:18:21.130,0:18:29.410
are usually goes down so in a certain

0:18:25.810,0:18:31.840
sense there's an inherent trade-off

0:18:29.410,0:18:34.600
going on between these two measures and

0:18:31.840,0:18:38.530
it might be an interesting idea to try

0:18:34.600,0:18:43.330
to balance these two conflicting goals

0:18:38.530,0:18:45.550
out and the f1 measure is one way to do

0:18:43.330,0:18:48.910
this which is simply the harmonic mean

0:18:45.550,0:18:52.150
between PPV and TPR

0:18:48.910,0:18:55.000
so if you haven't heard of the harmonic

0:18:52.150,0:18:58.210
mean before so in maths there's three

0:18:55.000,0:19:01.210
types of mean or averaging functions

0:18:58.210,0:19:02.800
they are the normal usual mean the

0:19:01.210,0:19:04.720
geometric mean and then the harmonic

0:19:02.800,0:19:07.090
mean and for two elements the harmonic

0:19:04.720,0:19:11.530
mean is simply two times the product

0:19:07.090,0:19:13.210
divided by the sound and note that yeah

0:19:11.530,0:19:14.920
we are trying to balance out here PPV

0:19:13.210,0:19:16.240
and TPR but this measure doesn't really

0:19:14.920,0:19:21.700
take into account the number of true

0:19:16.240,0:19:24.280
negatives and if you haven't seen the

0:19:21.700,0:19:26.020
harmonic mean before I have tabulated

0:19:24.280,0:19:33.190
this here for you for different

0:19:26.020,0:19:35.350
combinations of T PR and PPV and what

0:19:33.190,0:19:39.720
you can potentially see from this table

0:19:35.350,0:19:44.860
is that the harmonic mean tends more

0:19:39.720,0:19:47.320
strongly than the normal average or the

0:19:44.860,0:19:50.680
geometric mean towards the smaller of

0:19:47.320,0:19:53.770
the two elements

0:19:50.680,0:19:58.470
so you can maybe see this here where you

0:19:53.770,0:19:58.470
have a TPR of one and then you have a

0:19:58.950,0:20:06.370
PPV of 0.6 so the normal average would

0:20:02.920,0:20:09.370
result in a value of 0.8 well the

0:20:06.370,0:20:12.220
harmonic mean of the F 1 measure results

0:20:09.370,0:20:17.140
in point 7 5 or here the normal average

0:20:12.220,0:20:19.120
would be 0.7 while the F 1 computed from

0:20:17.140,0:20:24.400
the harmonic mean is point five seven

0:20:19.120,0:20:28.860
and nicely a model with TPR equals zero

0:20:24.400,0:20:31.690
now where you didn't predict anything as

0:20:28.860,0:20:34.900
a profit positive from the positive

0:20:31.690,0:20:38.680
class or a binary system with a positive

0:20:34.900,0:20:43.240
predictive value of zero so where no

0:20:38.680,0:20:46.450
real positives were among the predicted

0:20:43.240,0:20:50.260
positives both of these systems always

0:20:46.450,0:20:52.210
have an F 1 of F 1 score of zero now you

0:20:50.260,0:20:54.460
can easily see from this formula here

0:20:52.210,0:20:58.830
and from the from the product here on

0:20:54.460,0:21:02.170
the top you can also ask yourself what

0:20:58.830,0:21:04.900
what am what is the F 1 so of a constant

0:21:02.170,0:21:07.300
system that always predicts negative the

0:21:04.900,0:21:09.280
negative class level well in this case

0:21:07.300,0:21:12.220
if you always predict the negative class

0:21:09.280,0:21:14.650
then the TPR is 0 so f 1 is 0

0:21:12.220,0:21:19.380
that's easy to see if you always predict

0:21:14.650,0:21:22.510
positive things are not so simple or

0:21:19.380,0:21:26.020
well F 1 is not exactly 0 what happens

0:21:22.510,0:21:28.140
then is that well the if you predict

0:21:26.020,0:21:30.940
everything is positive then obviously

0:21:28.140,0:21:33.400
the true positive rate is going to be

0:21:30.940,0:21:34.810
exactly 1 now because everything from

0:21:33.400,0:21:37.510
the positive class you're also labeling

0:21:34.810,0:21:42.070
as positive so this formula here reduces

0:21:37.510,0:21:45.280
to 2 times P PV divided by p VV plus 1

0:21:42.070,0:21:47.620
and with I don't know maybe pen and

0:21:45.280,0:21:51.250
paper and two seconds of extra time you

0:21:47.620,0:21:54.190
cannot also show that this reduces even

0:21:51.250,0:21:57.070
further to 2 times n plus so the size of

0:21:54.190,0:22:00.370
the positive class divided by n plus

0:21:57.070,0:22:03.390
plus n and this is simply due to the

0:22:00.370,0:22:09.800
fact that the PPV in this case here is

0:22:03.390,0:22:15.200
the number of positive class labels

0:22:09.800,0:22:19.830
which is or sorry yeah the number of

0:22:15.200,0:22:23.670
well this is the PPV in this case is

0:22:19.830,0:22:26.550
simply n plus divided by n because

0:22:23.670,0:22:29.010
you're predicting everything as positive

0:22:26.550,0:22:32.700
also the number of elements that you

0:22:29.010,0:22:36.000
predict as positives n well and of these

0:22:32.700,0:22:40.680
n plus elements you have predicted

0:22:36.000,0:22:43.290
correctly as positive and if you're

0:22:40.680,0:22:45.990
positive class is rather small then also

0:22:43.290,0:22:48.030
there's an f1 square here will be rather

0:22:45.990,0:22:53.610
small and which you can directly see

0:22:48.030,0:22:57.060
from this formula um the f1 metric

0:22:53.610,0:23:01.200
allows you to balance out PPV and true

0:22:57.060,0:23:03.720
positive rate in a single number on the

0:23:01.200,0:23:07.650
other hand I'm not sure whether this is

0:23:03.720,0:23:11.910
always reasonable in order to really

0:23:07.650,0:23:14.010
talk about one single metric for these

0:23:11.910,0:23:18.570
imbalanced cases you would really have

0:23:14.010,0:23:20.550
to specify your precise costs in a cost

0:23:18.570,0:23:23.100
matrix and we just assume that we can't

0:23:20.550,0:23:27.060
do that so what this basically means is

0:23:23.100,0:23:29.520
that that there is no single perfect

0:23:27.060,0:23:31.800
metric or we are actually missing some

0:23:29.520,0:23:34.170
information to come up with a single

0:23:31.800,0:23:37.710
quantitative number to evaluate our

0:23:34.170,0:23:39.600
binary system f1 is a possibility but f1

0:23:37.710,0:23:41.760
now assumes a certain cost structure

0:23:39.600,0:23:45.390
that we haven't explicitly written down

0:23:41.760,0:23:48.750
so now of course you can do that whether

0:23:45.390,0:23:52.380
this really reflects what you want in in

0:23:48.750,0:23:56.430
practice either not is another matter

0:23:52.380,0:23:59.540
and I think very often it makes more

0:23:56.430,0:24:02.220
sense to really then stick with visual

0:23:59.540,0:24:06.500
analytical tools from our C analysis

0:24:02.220,0:24:06.500
which I will introduce in the next

