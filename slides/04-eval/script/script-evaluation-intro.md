# Evaluation: Introduction and Remarks

- Welcome to a new unit on introductin to machine learning.
- In this part of the lecture we will talk about performance
  evaluation.
- In this first unit we discuss the basic idea.


## PERFORMANCE EVALUATION

- In machine learning we want to obtain a model which has a
  strong prediction performance. 
- So we want to know: How well does my model perform on data
  from the same data generating process?
- The data generating process is the true underlying phenomenon
  creating the data. 
- Our model is an attempt to reflect the data generating process
  as good as possible.
- The problem is: we do not know the true data generating
  process.
- If we did, we wouldn't need the model anymore.
- Now, the question is: How do we evaluate our model, if we do
  not know how to generate data from the same data generating
process?
- We can use different techniques to do so:
- First we could just compute the model on a certain data set.
- This data set is called "training data".
- We could evaluate our model using the same training data.
- We could just check, if the predictions from the model are
  similar to the actual y-values in the training data set.
- Alternatively - and preferably - we could use a seperate new
  data set.
- This data set needs to be similar to the original in order to
  be useful. Remember: it has to be from the same data
generating process.
- To evaluate if the predictions and the actual data are close,
  we use evaluation measures. 
- Here we use the words measure and metric synonimously. 



## PERFORMANCE EVALUATION

- Performance evaluation is no whitchcraft nor is it rocket
  science.
- It is actually quite straight forward if you stick to some
  principles.
- Often these principles are simple; even simpler than classical
  statistical model diagnosis
- It relies on only a few assumption, because our goal is merely
  to see how well we are able to predict.
- Of course, there are some traps we should avoid.
- And even if we do not aim to cheat, sometimes we cheat by
  accident if we aren't careful enough.
- The upcoming units on performance evaluation will set you up
  with the essentials, so that you don't stumble into common
pitfalls.



## PERFORMANCE MEASURES

- As we want to estimate our model performance in general, we
  need to think again about loss functions.
- The expected loss tells us the expected performance of our
  model.
- We call this expected loss "generalization error"
- Since we can't compute the gerenalization error directly, we
  have to estimate it. We do that by computing the average loss.
- We can do that using the training data or new, independent
  data.
- If we use training data this will result in a too optimistic
  estimate.
- This is why we actually want to use separate, independent test
  data.
- One example for a common estimate of the generalization error
  is the mean squared error, which is just the L2-loss.
- We will get back to that again later and also learn about all
  kinds of other generalization error estimates.
- These estimates we call performance measures or evaluation
  measures.


## MEASURES: INNER VS. OUTER LOSS

- When we discussed losses in previous units we talke about how
  to set up a learner and how to compute a model.
- We used the loss as something to optimize over.
- Of course we can not only use the loss for training a model,
  but also for evaluating a model.
- In an optimal scenario, we know exactly what we want.
- We know which loss should be used.
- We use this loss both for learning and for evaluating.
- The loss used for learning is called "inner loss".
- The loss used for evaluating is called "outer loss".
- Think of a student. We want our student to learn how to
  program.
- We teach this student in programming and later the exam is
  also about programming.
- The student *learns* exactly the what she is *evaluated* for.
- Imagine that the student would learn maths and then still get
  evaluated in programming. That would be weird, right?


## MEASURES: INNER VS. OUTER LOSS

- In reality we do not always have the possibility, however, to
  teach our student in programming.
- Sometimes maths is all we have.
- And teaching her in maths will give her a better ability to
  understand programming than not teaching her anything.
- Now in machine learning our learner ist the student and the
  inner loss can not allways be the same as the outer loss.
- This is because some losses are hard to optimize.
- In other scenarios we have learners where the loss is not
  specified directly.
- Let's look at two examples: logistic regression and
  k-Nearest-Neighbours.
- Logistic regeression is often used because it is easy to
  compute and easy to interpret.
- With kNN we have an algorithm whithout explicit loss
  minimization. So we don't really know the loss here.
- Now when we want to compare models computet via logistic
  regression and kNN, we need to think about: "what is actually
the evaluation measure?"
- Maybe we are interested in a classification error?
- Maybe we are interested in a cost-weighted classification
  error?
- Maybe we need something more advanced for evaluation? Like ROC
  or AUC?
- Understanding these questions and how to answer them is the
  topic of the upcoming units. 
- So stay tuned to learn what a cost-weighted classification
  error or an AUC is.

