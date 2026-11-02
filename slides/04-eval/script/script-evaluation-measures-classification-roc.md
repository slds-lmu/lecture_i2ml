# Evaluation: Measures for Binary Classification: ROC Measures

- Welcome to our next unit on the evaluation of ML systems.   
- In this lesson we will take a deeper look at binary classification and
  corresponding measures, which we call ROC measures.  


## IMBALANCED BINARY LABELS

- ROC analysis is all about evaluating binary classification systems for
  imbalanced label situations.  
- Imbalanced label situations are situations in which one of the two classes is
  much smaller than the other class. 
- Often the smaller class is also of higher importance than the larger class.
  So for example, consider a binary classifier for diagnosing a serious medical
condition.  
- Let's assume that our label distribution is imbalanced. 
- So fortunately not too many people have the disease that we want to model
  here. 
- And assume that, for example, only 0.5% of 1000 patients actually have this
  very rare disease. 
- Now evaluating any classification system on that task with something like the
  misclassification error or the accuracy is obviously inappropriate. 
- Consider, for example, the constant classifier that always returns the label
  "no disease".  
- A very stupid classifier that doesn't look at any features. 
- It just constantly spits out "no disease", "no disease", "no disease" - for
  each and every patient.  
- If you evaluate this type of system with the normal misclassification error
  rate, well, this system does very well. 
- It has a misclassification error rate of only 0.5%. 
- This sounds pretty good right, but if you think about this a bit more this is
  the worst system ever and hopefully not implemented because this system will
say nobody has the disease and send everyone home, including the patients who
have the disease.
- This problem is known as the accuracy paradox. 
- The paradox states that for these binary imbalanced situations it's not too
  smart to only look at accuracy, because that can be strongly misleading.  
- What should we do instead? 
- Wait and learn!


## IMBALANCED COSTS
 
- There's another very much related point of view to understand this problem:
  instead of through the lens of imbalanced class labels, we will now view the
problem through the lens of imbalanced classification costs.   
- In our example if you would classify a sick patient as "not sick" this should
  usually come along with a higher cost than classifying a healthy patient as
sick.  
- These costs, these misclassification costs should depend on what happens
  after we've produced that classification.
- Imagine patients classified as sick are sent to another, more thorough and
  expensive screening.   
- Patients classified as "not sick" are sent home.   
- In the cases where we do the thorough screening, we can still figure out
  whether we classified this patient incorrectly as sick.  
- Erroneously subjecting someone to the screening is obviously not good from a
  psychological and economic perspectiv.  
- But sending someone home who is sick and will likely get worse or even die,
  is clearly much much worse and we want to avoid that at all costs.  
- Such a situation not only arises if we have imbalanced label distributions
  but also when well these costs that are connected with our decision making
process differ quite strongly.  
- So we could also see this as a problem of imbalanced costs rather than
  imbalance labels and imbalanced costs could also occur even if label
distributions are perfectly equal.   
- Both of these situations are very tightly connected.  
- If we could specify these imbalanced costs, we could precisely evaluate
  against this custom cost measure, and we might even optimize our machine
learning model on the inside directly through empirical risk minimization
against this cost matrix.  
- There's a specific subfield of machine learning, which is called
  cost-sensitive learning, which deals with with exactly this type of problem.   
- Unfortunately it is usually very difficult to up with precise cost numbers,
  so we can't always do that.  
- In the following we assume that we have no knowledge about costs.  
- What we are going to do in this unit is to create different metrics to
  evaluate our binary system from different perspectives.  
- This often helps to get a first impression of the quality of the system.
- ROC analysis deals with exactly this.


## CONFUSION MATRIX
 
- First we are now going to introduce more and new alternative metrics for
  binary systems.  
- Let's look at our two-by-two confusion matrix which tabulates predictions
  versus actual classes.  
- This confusion matrix tabulates how many correct and incorrect labelings
  happened in the respective entries.  
- In this unit we will only consider binary systems and I will call one of the
  classes the positive class and one the negative class. 
- Their respective class sizes we denote with n plus and n minus.
- So n plus for the positive class and n minus for the negative class.  
- The positive class usually does not have anything positive associated with
  it.  
- Positive class means it's the important class - it's often the smaller class
  - it contains the elements you don't want to miss.  
- In engineering you might call this class the signal class.   
- In medicine this would be the disease class, so not positive at all.  
- We call the entries in the confusion matrix "true positive", "false
  positive", "false negative" and "true negative".   
- So the second part of this term specifies what we predicted and the first
  part of the term specifies whether the prediction was correct or not.   
- Ok, now let's get to our new measures: The ROC metrics.
 


## LABELS: ROC METRICS
   
- The basic ROC metrics are defined by the entries in the confusion matrix,
  divided by either the respective row sum or collumn sum.    
- What we get are rates.    
- Rates of true positives, for example.    
- This we call the "True positive rate".    
- It tells us how many of the true 1s or positives we actually predicted as 1s
  or positives.     
- And then there's the true negative rate: the true negative rate is the
  proportion of elements from the negative class that we predicted as being
negative.    
- We can do pretty much the same row-wise: we can specify something that's
  called the positive predictive value, which is the number of true positives
divided by the number of elements that we predicted as being positive.    
- The negative predictive value works in the same fashion.    
- There is a very intuitive way of understanding what these metrics mean: true
  positive rate is "how many of the true positive elements did we also predict
as positive?"    
- while the positive predictive value is "if we predict an object as belonging
  to a class one how likely is it that this object is really of class one?" or
if you again consider the medical scenario, the PPV tells you, if your medical
test assigns you the disease, how likely do you truly have it?    
- TPR tells you: if you have the disease, how likely does your test assign you
  to the disease class or detects that disease.
  

## HISTORY ROC

- Now you probably wonder why we call these measures "ROC metrics".
- Well, the reason for that is historical.    
- ROC stands for receiver operating characterstics.    
- They were developed by electrical engineers and radar engineers during World
  War two.     
- Today it is used in many other fields which deal with the evaluation of
  binary systems: psychology for the perceptual detection of stimuli or in
medicine - I already gave an example from medicine -, radiology, forecasting of
hazards, and so on.    
- We still use the name originating from engineering though, which is kind of
  confusing, but just the way it is.
   

## LABELS: ROC
   
- Here's a small example from a medical test.    
- In this case, we have a screening system for bowel cancer detection.    
- This is a pretty rare disease so in this case we only have 30 patients who
  have the disease.    
- We have a control group of 2,000 patients, who don't have the disease.     
- The confusion matrix shows the number of correctly and incorrectly classified
  patients.     
- You can see the various computations for the ROC metrics.    
- You can for example see from 30 elements in the positive class we detected 20
  of those, resulting in a TPR of 2/3.    
- For the positive predictive value, 20 of the 200 as positive predicted
  patients actually have the disease.    
- So the PPV is 10%.    
- This means, if the classifier says, that you have bowel cancer, it is
  actually more likely that you don't have. Out of 10 people where the
classifier says they have the disease, only 1 actually has it.
- We can now start discussing how much we like this binary system.
- First of all we miss one third of the sick patients - we are not detecting
  them correctly - while if this medical test tells you that you have the
disease, you actually probably don't have it.  This doesn't seem too good on
both fronts.  


## MORE METRICS AND ALTERNATIVE TERMINOLOGY

- Now there's even more ROC metrics that you can create from this 2x2 confusion
  matrix.    
- There is for example the false negative rate which is simply 1 minus the true
  positive rate.    
- Or you have here the false positive rate which is 1 minus the true negative
  rate.    
- And then there is, for example, the prevalence or the false emission rate or
  all these other measures listed here.
- From this table, you can also see one unfortunate aspect.
- Because all of these measures are discussed in different fields like
  psychology and engineering there's usually two or three different terms for
the same concept.    
- So true positive rate is also called recall and also called sensitivity.    
- False positive rate is also called fallout.    
- The true negative rate is also called specificity and so on.    
- I try to avoid all of these alternative names in this unit.    
- If you want to read more on this you can for example go to Wikipedia where we
  took this matrix from or go to the interactive diagram linked here, which
shows you how all of these measures are calculated in detail.



## LABELS: F1-MEASURE
   
- Before we finish this unit, I want to talk about one particular measure,
  which builds on the measures we looked at so far: the F1 measure.    
- As we have seen from the previous example on bowel cancer, it's very often
  difficult to achieve simultaneously a high positive predictive value and a
high TPR.    
- Well if you can somehow improve your classifier so it predicts more positives
  than before, yes, this will result in a higher TPR, BUT this will also result
usually in a higher number of false positives, because you're now predicting
more observations as positive and this is the usual price you pay.    
- So increasing your TPR usually results in a lower PPV and vice-versa.    
- Also if you do the opposite and you somehow change your classifier in such a
  way that it predicts more negatives you will have a higher PPV but your TPR
usually goes down.    
- So in a certain sense there's an inherent trade-off going on between these
  two measures and it might be an interesting idea to try to balance these two
conflicting goals.    
- The F1 measure is one way to do this.    
- It is simply the harmonic mean between PPV and TPR.     
- If you haven't heard of the harmonic mean before: in maths there's three
  types of mean or averaging functions.     
- There is the usual mean - also called arithmetic mean -, the geometric mean
  and then the harmonic mean.    
- For two elements the harmonic mean is simply two times the product divided by
  the sum.    
- Note that, yeah, we are trying to balance out here PPV and TPR, but this
  measure doesn't really take into account the number of true negatives. 


## LABELS: F1-MEASURE

   
- Here you see a table of different combinations of TPR and PPV and what you
  can see from this is that the harmonic mean tends more strongly - than the
normal average or the geometric mean - towards the smaller of the two elements.     
- For example, let's say you have a TPR of one and a PPV of 0.6, so the normal
  average would result in a value of 0.8, while the harmonic mean of the F1
measure results in .75.     
- And nicely a model with TPR equals zero - where you didn't predict anything
  as as positive - or a binary system with a positive predictive value of zero
- so where no real positives were among the predicted positives - both of these
systems always have an F1 score of zero.    
- You can also ask yourself what what is the F1 of a constant system that
  always predicts the negative class label.    
- Well, in this case, if you always predict the negative class then the TPR is
  0 so F1 is 0, that's easy to see.    
- If you always predict positive, things are not so simple or, well, F1 is not
  exactly 0.    
- What happens then is that the true positive rate is exactly 1, because
  everything from the positive class you're also labeling as positive.    
- So the F1 formula reduces to 2 times PPV divided by PVV plus 1.    
- And with a few calculations you can show that this reduces even further to 2
  times nplus - so the size of the positive class - divided by nplus plus n.    
- This is simply due to the fact that the PPV in this case is simply nplus
  divided by n because you're predicting everything as positive, so the number
of elements that you predict as positives is n.    
- Well and of these nplus elements you have predicted correctly as positive.
- And if you're positive class is rather small then also the F1 will be rather
  small, which you can directly see from this formula.    
- The F1 metric allows you to balance out PPV and true positive rate in a
  single number.    
- This is often useful, but not always reasonable.    
- In order to really talk about one single metric for these imbalanced cases,
  you would really have to specify your precise costs in a cost matrix and we
just assumed that we can't do that.    
- What this basically means is that there is no single perfect metric, or we
  are actually missing some information, to come up with a single quantitative
number to evaluate our binary system.    
- F1 is a possibility but F1 implicitly assumes a certain cost structure that
  we haven't explicitly written down.    
- Now of course you can still use F1.  
- Whether this really reflects what you want in practice is another matter.     
- You may want to use a visual tool for understanding model performance in
  these situations.    
- This is, however, part of another unit.

