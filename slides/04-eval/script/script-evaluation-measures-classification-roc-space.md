# Evaluation: Measures for Binary Classification: ROC visualization

- Welcome to our next unit on the evaluation of ML systems.
- This unit discusses visual measures for binary classification systems in
  imbalanced settings and where no cost matrix is known.  

## LABELS: ROC SPACE

- In first unit on ROC analysis I introduced various metrics for the evaluation
  of binary classification systems with imbalanced class levels. 
- Among those were the true positive rate which was the percentage from the
  positive class that we also predicted as being positive and the false
positive rate which is the percentage of the negative class that we erroneously
predict as being positive. 
- Both measures range between 0 and 1, or 0 and 100 if given in percentage
  points.  
- If we plot these two measures like in this example we can compare several
  models with each other. 
- This plot is called ROC space. 
- In the previous unit we learned that it is difficult to objectivley combine
  two conflicting measures like PPV and TPR or also FPR and TPR, without
knowing the costs of different incorrect (and also correct) decisions. 
- So if we don't have that extra information why not just keep the two
  conflicting metrics apart and visualize them on their own without combining
them in an unclear manner?
- This is exactly what the ROC space does.
- For each classification system under consideration we simply calculate the
  TPR and FPR and then we plot it into this coordinate system here where we put
FPR on the x-axis and the TPR on the y-axis.
- Of course we could do the same for other measures, like TPR and PPV as in the
  F1 measure.
- In this unit we focus on the TPR and FPR, as these are most commonly plotted
  in such a fashion. 
- Now by plotting the measures of different models in one plot, we can try to
  visually pick our preferred model.  
- In this example it is pretty clear that if we compare c1 to c3, that c1 is
  better. 
- It is not only better with respect to FPR (where lower is better), but also
  with respect to TPR (where greater is better). 
- If we compare c1 with c2 the situation is much less less clear. 
- c1 has a lower FPR value but c2 has a higher TPR value and again without
  extra information on misclassification costs we can't decide which of these
two systems is preferable. 


## LABELS: ROC SPACE

- Obviously the best ever potential system is located on the top left corner,
  because it has both a true positive rate of 1 and a false positive rate of 0.
-  That can only happen if we produce zero errors on the positive class and on
   the negative class and of course if that happens we also don't really have
to talk about costs, right? 
- Normally if we would see such a solution in a real-world problem we might
  worry about label leakage or some other error we might have introduced into
our evaluation procedure. 
- Models which lie on the diagonal are as good as random.
- Imagine a classifier, which produces random labels, random 0-1-labels,
  without looking at the features. 
- Then this classifier would be somewhere on the diagonal depending on with
  which probability the classifier predicts positive class.
- For example our random classifier predicts positivie class with a probability
  of 25%, then we'd get on average a TPR of 0.25 and an FPR of 0.25.
- If the classifier would predict positive class with a probability of 75%,
  again without any useful assignment, but randomly, then both TPR and FPR are
.75. 
- If we have a classifier that classifies all as 1s, all as positive, we will
  correctly classify all positives as positive, so TPR would be 1.
- At the same time we would also classify all negatives as positive, so FPR
  would also be 1.


## LABELS: ROC SPACE

- If we somehow manage to get a classifier which lies below the diagonal, then
  we did something deeply wrong.
- In practice, we should never see something like that.
- It is very likely, that if we get a classifier that lies somewhere in the
  right bottom corner, then we made some mistake. 
- Like, for example, we might have accidentally switched labels.
- Because if we invert the predicted labels, so we say positives are now
  negative and vice versa, then the point in the ROC space will be mirrored to
where our original classifier lies.


## LABEL DISTRIBUTION IN TPR AND FPR

- Initially we discussed that we use ROC metrics in cases of imbalanced class
  distribution.
- Let's now look at two examples, where we see this properly. 
- In the first example we have as many positive cases as we have negatives. 
- In the second example we have double the amount of positives. 
- Let's assume that we have one classifier, which then results in the two
  tables shown for the two examples respectively. 
- It is the same classifier, so it should have the same performance in both
  cases, right?  
- However, if we look at the missclassification error, we get different values. 
- It seems as if the classifier is better in example 1.
- Just because of class imbalance. 
- If it is not immediately clear to you why this is the case, stop the video,
  look up the formula for the MCE and compute it yourself.  
- The ROC measures "true positive rate" and "false positive rate" are the same
  for both examples. 
- The reason for this is that they are computed as rates. 
- This is a nice property of these measures and help us avoid confusion in
  settings with unbalanced samples. 
- But, be careful. 
- If you have an unbalanced data set for training, you may still get different
  results, of course. 
- This example here only works because the model is fixed. 
- If the model were different for the two examples and also based on
  differently balanced training samples, we would most likely get different
results.


## FROM PROBABILITIES TO LABELS: ROC CURVE

- With ROC measures we can look at binary classifiers which produce label
  predictions. 
- Now, remember, that scoring classifiers and probabilistic classifiers can
  also output label predictions, if we give them a threshold. 
- If we have a probabilistic classifier, it will give us a probability of
  seeing the postitive class for a certain observation. 
- To get the label, we can say, for example, if the probability of seeing
  positive is above 50%, we predict positive and vice versa for negative. 
- Instead of 50% we could also use a different value: for example 45%. 
- The same can be done for scoring classifiers.
- We just set a threshold for the score instead of for the probability.  
- We can now evaluate this discretized system with any performance metric that
  is possible for discrete class labels: TPR, FPR, F1, missclassification
error, and so on.  
- A difficulty with the thresholding is, that we do not know the best threshold
  and we also can't optimize for a perfect threshold because we don't have a
single  performance metric available in these imbalance situations with unknown
costs.
- What we can do though, is to go through ALL possible thresholds and compute
  the respective measures. 
- There is one visualisation, which does exactly that and which is used a lot
  in ML: it is called the ROC curve. 
- Let's got through the steps of computing the values needed for the plot by
  going through an example.


## ROC CURVE

- Here we have an example data set with 12 observations. 
- We have inon collumn the true outcome (positive or negative) and in one
  collumn the predicted score. 
- In this example possible scores range between 0 and 1. 
- The observations are sorted by predicted score, from high to low.  
- Now to compute the ROC curve we start with the highest threshold possible
  which is a value of 1, wich yields a TPR of 0 and and FPR of 0.  
- This is because a threshold of 1 will assign everyone to the negative class. 
- So we draw a dot in the origin. 
- Next we set the threshold to something between the first and the second
  score, say 0.9.  
- Now because this blue observation here is from the positive class I know that
  my false positive rate stays the same because I haven't changed anything from
the negative class. 
- But this positive example I have now correctly labelled also as positive so
  my TPR goes up a bit and I can actually calculate how much it goes up.
- Because there's only six elements in the positive class it will go up by
  1/6th which is about 0.167. 



## ROC CURVE

- In the next step we select a threshold between the second and third
  observation, so 0.85. 
- TPR again goes up by one sixth and FPR stays the same, as, again, the
  observation is positive. 


## ROC CURVE

Now the third threshold is 0.66 and as this third observation is again positive
we jump up 1/6th on the y-axis.


## ROC CURVE

- The fourth observation is actually negative, so if we take a threshold below,
  0.65, the FPR increases. 
- For a threshold of 0.6, for example, we get an FPR of 0.167, because one out
  of 6 negative observations is now classified as positive.

## ROC CURVE

Now we do this...


## ROC CURVE

... for every possible threshold, ...


## ROC CURVE

... and finally we get a curve, which starts in (0,0) and goes to (1,1).


## ROC CURVE

- Now what do we look for in an ROC curve? 
- The closer the curve is to the top-left corner, the better it is. 
- If curves don't cross it is easy to identify which algorithm is better. 
- If they do cross, we have to think more carefully. 
- We have to think about thresholds we deem reasonable and about what is
  important to us.



## AUC: AREA UNDER ROC CURVE

- Since people really like one single number to make decisions, the ROC curve
  can be boiled down to one number again. 
- As we said, the more to the top left the ROC curve goes, the better.
- This means, the greater the area under the ROC curve, the better. 
- An optimal value is an area under the curve of 1. 
- A pretty awful area under the curve is on of 0.5.
- The area under the ROC curve is called AUC.


## AUC: AREA UNDER ROC CURVE

- We can interpret the AUC as a probability: the probability that a classifier
  ranks a random positive higher than a random negative observation. 
- So as an example we take a random positive observation from a data set and a
  random negative observation.
- If our AUC is 0.92, the the probability that the positive is ranked higher
  than the negative observation is 92%.  
- Note that by boiling down the curve into one number, we loose information.
- Looking at the ROC curve is way more informative and should, if possible, be
  used. 
- Especially since the AUC integrates over large portions of the curve that
  you're typically not very interested in. 
- Think about medical applications where you really want an extreme high true
  positive rate, because lowering the true positive rate means sending people
home who are sick.



## PARTIAL AUC

- In these cases where we want to focus on a specific region of the ROC curve,
  we can use the partial AUC. 
- The interpretation now of course changes, but the measure can still be used
  to compare theperformance of models. 
- In the figures we show two examples of partial AUC. 
- The first focusses on a region with low FPR and the second on the region with
  high TPR.
- But again, the AUC just gives us one single value where looking at the
  plotted curve can give us much more information.


