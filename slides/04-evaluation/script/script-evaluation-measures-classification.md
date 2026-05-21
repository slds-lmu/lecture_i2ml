# Evaluation: Simple Measures for Classification

- Welcome back to our next unit on performance evaluation.
- This is a lecture on some simple measures for classification tasks.


## LABELS VS PROBABILITIES

- Before we dive into the different measures, there is one thing we need to clarify.
- In classification we sometimes predict class labels, other times we predict class probabilities.
- Which one we need depends on both the use case and the learner.
- So in evaluation we need to be able to evaluate labels, if we are dealing with labels.
- If we are dealing with probabilities, we should evaluate those.


## LABELS: MCE / ACCURACY 

- In the following we will show what we are dealing with in the
  title of the slide.
- The first measure we look at is one that deals with labels.
- This first measure is called misclassification error rate,
  which we denote by MCE.
- It simply counts the number of incorrect predictions and
  presents them as a rate.
- Accuracy is a measure that is doing the same just it counts
  the correct classification instead of the incorrect
classifications.
- These measures are very intuitive.
- However, they come with some issues:
- If the data set is small, the MCE can be quite dependent on
  that particular data set and be a bad estimate for the
generalization error.
- Also it tells us nothing about how good the predicted
  probabilities are, since it only focusses on the labels.
- All errors in all classes are weighted equally in MCE.
- It is easy to think of examples where this is a bad idea. 
- Do you really think that classifying someone incorrectly as
  sick is the same kind of error as classifying someone
incorrectly as healthy?
- Do you think, incorrectly classifying a dog as a wolf is
  similarly wrong as incorrectly classifying a human as a wolf?



## LABELS: CONFUSION MATRIX

- In cases as in the last example it is often good to take a
  step back and look at the confusion matrix instead of a single
value.
- The confusion matrix tabulates the true against predicted
  classes.
- The true classes are shown in the columns and the predicted
  classes in rows.
- Here we see an example for a model predicting types of iris
  flowers.
- We get all setosas right, and make only a few mistakes on the
  other two flower types.



## LABELS: CONFUSION MATRIX

- In binary classification, the entries in the confusion matrix
  have specific names.
- The correct classifications are called "true positive" or
  "true negative".
- The words "positive" and "negative" are used here instead of 1
  and 0.
- The errors are called "false negative" and "false positive".



## LABELS: COSTS

- If we know how much worse one error is compared to another, we
  can use costs. 
- We specify each error and also each correct choice using a
  cost matrix. 
- Let's try to understand this better using an example. 
- Imagine you own a train company and you have to decide if your
  train conductor should check the ticket of a person.
- You know pretty well what the different costs are here.
- The required working time of the conductor for checking one
  ticket corresponds to costs of 3 euros.
- One ticket on the train costs 10 euros.
- Not buying a ticket and getting caught costs the passenger 40
  Euros.
- If we predict that a passenger has no ticket, we will check that passengers ticket. 
- Checking the ticket costs 3 Euros.
- If we catch someone who does not have a ticket, we will get 40
  Euros, so resulting in a plus of 37 Euros.
- However, if we check and the person has a ticket, we will loose 3 Euros.
- If we do not check and the person has no ticket, we miss 40 Euros.
- What does the cost matrix look like in this example?
- I recommend you to stop the video here and try to solve this
  by yourself before we look at the solution together.


## LABELS: COSTS 

- To set up the cost matrix, let's first look at the wrong
  decisions.
- If we predict that a passenger has no ticket, but has a
  ticket, we loose 3 Euros.
- So the bottom left entry is 3.
- If we predict that a passenger has a ticket, but actually does
  not have one, we loose 40 Euros.
- So the top right entry is 40.
- Now the correct prediction that someone has a ticket, does not
  cost anything, but also does not give us any additional
income, beyond the ticket the person bought.
- The correct prediction that someone has no ticket, will give
  us some money: We get 40 Euros and pay only three Euros.
- Now, let's assume we have a train of 100 passengers.
- Our current system is that we do not trust anyone and check
  all passengers.
- 7 of them turn out to not have a ticket
- This means that we have an income of 37 times 7, but expenses
  of 3 time 93.
- All in all we pay 20 Euros for the ticket checking.
- Per person we pay 2 Cents.


## PROBABILITIES: BRIER SCORE

- The next measuer we wanna look at is on for probabilities.
- This measure is called the "brier score"
- The brier score measures the squared distances of probabilities from the true class labels.
- This is something we have already seen before in a similar fashing. 
- It measures the mean squared error.
- So "brier score" if merely a fancy name for MSE on probabilities.
- The definition written down here is for the binary case.
- The figure shown here plots the brier score on the y-axis and the predicted probabilities on the x-axis.
- Let's say that we have an observation where the true label is a 0. 
- Then lower predicted probabilites are better, of course.
- The green curve shows that the brier score is low for low predicted probabilities and high for high predicted probabilites.
- The violet curve shows the brier score values for an observation where the true label is 1.
- This curve is mirrored, so a high error if the predicted probability is low and a low error if it is high.
- Makes sense, right?


## PROBABILITIES: BRIER SCORE

- For the brier score we can also define a version for multiple classes.
- The "o" here is an indicator function which is 1 if the i-th observation is of class "k" and 0 otherwise.
- For the binary case, this version of the brier score is twice as large as what we saw on the previous slide, because here
we sum the squared difference for each observation regarding
class 0 AND class 1, not only for class 1.



## PROBABILITIES: LOG-LOSS

- Our final measure we look at in this unit is the log-loss.
- This is the loss we already know from logistic regression.
- It is also calle Bernoulli loss or binomial loss.
- The optimal value of the loss is 0. 
- The more wrong the predicted probability is the stronger it is
  penalized in log-loss.
- Much stronger than in the brier score.
- Again, there is a multiclass version of the log-loss, wich
  uses the indicator function "o" which is 1 if the i-th
observation is of class "k" and 0 otherwise.
- Note that the measures we discussed in this unit are just a
  small subset of all measures.
- However, we got a good overview over some simple yet important
  measures.

