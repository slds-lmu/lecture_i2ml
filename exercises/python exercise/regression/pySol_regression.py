# -*- coding: utf-8 -*-
"""
Created on Tue Jan 17 18:37:21 2023

@author: Stefanie Schwarz
"""

# Python solution for Exercise 2: regression
# Intro to scikit-learn and other frequently used packages

#%% 0 Init - import packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.datasets import load_iris
import seaborn as sns
from sklearn.tree import DecisionTreeRegressor 
import math
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error
import sklearn.metrics as metrics

#%% Exercise 1a) How are Hypothesis space, risk and optimization in sklearn implemented?

# Model classes representing a certain hypothesis are stored in subpackages of sklearn.
# You can reach it with importing the desired class with e.g.
from sklearn.linear_model import LinearRegression  #repeated because of emphasis
# It is good pratice to import evverything in the beginning of your code.

# You initialize your "learner" or model with its properties defined by the Parameters, e.g.
model = LinearRegression(fit_intercept = True)
model

# Before training them on actual data, they just contain information on the functional form of f. 
# Once a learner has been trained we can examine the parameters of the resulting model. 
# Example data
rng = np.random.RandomState(35)
x = 10*rng.rand(40)
y = 2*x-1+rng.randn(40)

X = x[:, np.newaxis]
X.shape

model.fit(X, y)

# check model properties, e.g.
print("Model coefficients: ", model.coef_)
print("Model intercept: ", model.intercept_)

# fit new data with trained model
xfit = np.linspace(-1, 11)
Xfit = xfit[:, np.newaxis]
yfit = model.predict(Xfit)

plt.scatter(x,y)
plt.plot(xfit, yfit)

# The empirical risk can be assessed after training by several performance measures (e.g., based on L2 loss). 
# Optimization happens rather implicitly as sklearn only acts as a wrapper for existing implementations and calls package-specific optimization procedures.

#%% Exercise 1b) Example "iris" data set

iris = load_iris() # function to import iris data set as type "utils.Bunch" with sklearn
X = iris.data
y = iris.target
feature_names = iris.feature_names
target_names = iris.target_names
print("Feature names:", feature_names)
print("Target names:", target_names)
print("\nFirst 10 rows of X:\n", X[:10])


iris = sns.load_dataset('iris') # function to imported iris data set as type "DataFrame" with seaborn
sns.set()
sns.pairplot(iris, hue='species', height=3)

#%% Exercise 1c) learner of your choice

# sklearn offers many different models 
# Let's look at regression trees

# Roughly speaking, regression trees create small, homogeneous subsets (“nodes”) 
# by repeatedly splitting the data at some cut-off 
# (e.g., for iris: partition into observations with Sepal.Width ≤ 3 and > 3), 
# and predict the mean target value within each final group.

help(DecisionTreeRegressor) # prints decumentary in console, or 
# visit scikit-learn.org --> select right version --> go to right class, here sklearn.tree.DecisionTreeRegressor

rtree = DecisionTreeRegressor() #default setting
rtree.get_params() 
rtree.get_depth() # not working because no tree was fitted yet
rtree.get_n_leaves() # not working because no tree was fitted yet

# In general: 
# DecisionTreeRegressor inherits from class sklearn.tree
# As it used for regression, it predicts regression value for input X

# Important parameters
# criterion: choose between L2, L1, and others as Loss function
# splitter: strategy for choosing the split, default "best"
# max-depth: The maximum depth of the tree
# other complexity related params 
# random_state: Controls the randomness of the estimator. To obtain a deterministic behaviour during fitting, random_state has to be fixed to an integer. 

#%% Exercise 3

x = np.arange(-3, 3, step = 0.1) # 3 excluded
x = np.linspace(-3,3, num = 60) # 3 included

print(x)

def fun_y(x_in):
    """ 
    Method to produce named sinus function
    Input: data as numpy array
    Output: Function -3 + 5*sin(0.4 * pi * x_in) as numpy array
    """
    erg = -3 + 5* np.sin(0.4 * math.pi * x_in)
    return erg

def fun_poly3(x_in, beta):
    """ 
    Method to produce poynomial degree 3 with coefficents in numpy array beta for input data x_in
    Input: x as numpy array, beta as numpy array
    Output: y as numpy array
    """
    if not(type(x_in) in [np.ndarray]):
        raise ValueError("Invalid Input type for x")
    if not(type(beta) in [np.ndarray]):
        raise ValueError("Invalid Input type for beta")  
    erg = beta[0] + beta[1] * x_in + beta[2] * x_in*x_in + beta[3] * x_in*x_in*x_in
    return erg

np.random.seed(43)
y = fun_y(x) + np.random.normal(size = 60)

poly3d = np.poly1d(np.polyfit(x,y,3)) # Polyfit function for polynomial functions

# create plot from mathplotlib.pyplot
plt.figure(figsize=(12, 6))
plt.grid(True)
plt.plot(x, y, color='blue', linestyle='none',marker='o',markersize=10, label = 'random numbers')
plt.plot(x, fun_y(x), color='black', linestyle='solid', label = 'Correct function')
plt.plot(x, poly3d(x), color='red', linestyle='solid', label = 'Fitted Function degree 3')
plt.plot(x, fun_poly3(x,np.array([1.5,2,-0.7,0])), color='green', linestyle='solid', label = 'Function degree 2')
plt.plot(x, fun_poly3(x,np.array([1,-1.6,-0.3,0.2])), color='turquoise', linestyle='solid', label = 'Function degree 3')
# title & label axes
plt.title('Polynomial Fit:\nDifferent curves for Sinus curve', size=18)
plt.xlabel('x', size=16)
plt.ylabel('y', size=16)
plt.legend(loc='upper left', prop={'size': 10})
plt.show()

# We see that our hypothesis space is simply a family of curves.
# The 3 examples plotted here already hint at the amount of flexibility 
# third-degree polynomials offer over simple linear functions

#%% Exercise 4 Prep: load data from url

url = "https://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data"
abalone = pd.read_csv(url, sep=',', names=['sex', "longest_shell", "diameter", "height", "whole_weight", 
  "shucked_weight", "visceral_weight", "shell_weight", "rings"])

abalone = abalone[['longest_shell', 'whole_weight', 'rings']]

#%% Exercise 4a) Plot LongestShell and WholeWeight with color for Rings

plt.grid(True)
plt.scatter(abalone.longest_shell, abalone.whole_weight, s=10, c= abalone.rings, cmap = 'jet') #choose appropriate color map
plt.colorbar(label = 'Rings') # add color bar
# title & label axes
plt.title('Scatter Plot:\nLongest Shell and Whole Weight, Color by rings', size=15)
plt.xlabel('Longest Shell', size=11)
plt.ylabel('Whole Weight', size=11)
plt.show()

# We see that weight scales exponentially with shell length and that larger /
# heavier animals tend to have more rings.

#%% Exercise 4b) create task

# not applicable

#%% Exercise 4c) Fit Linear regression

X_lm = abalone.iloc[:, 0:2].values
y_lm = abalone.rings

lm = LinearRegression().fit(X_lm,y_lm)

pred_lm = lm.predict(X_lm)

results_dic = {'prediction' : pred_lm,
           'truth': y_lm}

results = pd.DataFrame(results_dic)

results.head()

#%% Exercise 4d) Compare the fitted and observed targets visually

plt.grid(True)
#plt.scatter(pred_lm, y_lm, s=5) 
sns.regplot(x = pred_lm, y = y_lm, ci = 95, scatter_kws={'s':5}, line_kws={"color": "black", 'linewidth':1})
sns.rugplot(x = pred_lm, y = y_lm, height=0.025,  color='k')
# title & label axes
plt.title('Scatter Plot:\nPrediction vs. Truth', size=15)
plt.xlabel('Prediction', size=11)
plt.ylabel('Truth', size=11)
plt.show()

# If resolution is too low: Tools > Preferences > IPython console > Graphics > Inline backend > Resolution
# Sugggestion: 120 dpi

# We see a scatterplot of prediction vs true values, where the small bars along 
# the axes (a so-called rugplot) indicate the number of observations that fall 
# into this area.
# As we might have suspected from the first plot, the underlying relationship 
# is not exactly linear (ideally, all points and the resulting line should lie 
# on the diagonal). With a linear model we tend to underestimate the response.

#%% Exercise 4e) Assess the model’s training loss in terms of MAE

#import function from sklearn
MAE = mean_absolute_error(pred_lm, y_lm)
print(MAE)

#%% Additional Info: Assessing model properties

# There exists no R type regression summary report in sklearn.
# The main reason is that sklearn is used for predictive modelling / machine learning
# and the evaluation criteria are based on performance on previously unseen data
# (such as predictive r^2 for regression).

# For the statistical view on Linear Regression you can use the package
# import statsmodels.formula.api as smf
# function OLS performs Ordinary least square fit (Linear regression)
# and has a summary() function

def regression_results(y_true, y_pred):  
    """ 
    Method to produce model metrics for training data
    Input: training response vector as array, prediction vector as array
    Output: -
    """
    # Regression metrics
    explained_variance=metrics.explained_variance_score(y_true, y_pred)
    mean_absolute_error=metrics.mean_absolute_error(y_true, y_pred) 
    mse=metrics.mean_squared_error(y_true, y_pred) 
    mean_squared_log_error=metrics.mean_squared_log_error(y_true, y_pred)
    median_absolute_error=metrics.median_absolute_error(y_true, y_pred)
    r2=metrics.r2_score(y_true, y_pred)

    print('explained_variance: ', round(explained_variance,4))    
    print('mean_squared_log_error: ', round(mean_squared_log_error,4))
    print('r2: ', round(r2,4))
    print('MAE: ', round(mean_absolute_error,4))
    print('MSE: ', round(mse,4))
    print('RMSE: ', round(np.sqrt(mse),4))
    print('Median Absolut Error: ', round(median_absolute_error,4))

regression_results(y_lm, pred_lm)