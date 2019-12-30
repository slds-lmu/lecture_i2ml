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



