# -*- coding: utf-8 -*-
"""
Created on Mon Jan  9 16:21:29 2023

@author: st_sc
"""
# Python solution for Exercise 2

#%% 0 Init - import packages
import numpy as np
import pandas as pd
from sklearn.naive_bayes import CategoricalNB # import Naive Bayes Classifier for categroial distributed features
from sklearn.preprocessing import OrdinalEncoder


#%% Exercise 1a) Naive Bayes

# Write dictionary for pandas Data Frame to save Bananas data
dic_bananas = {'ID': [1,2,3,4,5,6,7,8], 
               'Color':['yellow','yellow','yellow','brown','brown','green','green','red'], 
               'Form':['oblong','round','oblong','oblong','round','round','oblong','round'],
               'Origin':['imported','domestic','imported','imported','domestic','imported','domestic','imported'],
               'Bananas':['yes','no','no','yes','no','yes','no','no']}
data_banana = pd.DataFrame(dic_bananas)
print(data_banana)

#Transform your data with an ordial Encoder to get required input
enc = OrdinalEncoder() #Initialize Encoder
enc.fit(data_banana[["Color","Form", "Origin","Bananas"]]) # Fit encoder on needed coulumns
data_banana[["Color","Form", "Origin","Bananas"]] = enc.transform(data_banana[["Color","Form", "Origin","Bananas"]]) #actually transform data and save in old data frame

# split the data into inputs and outputs
X = data_banana.iloc[:, 1:4].values
y = data_banana.iloc[:, 4].values

x_new = np.asarray([3.,1.,1.])
x_new = np.reshape(x_new,(1,3)) #reahpe needed for prediction function


print(X)
print(y)
print(x_new)


# initializaing the NB
classifer = CategoricalNB(alpha=0) # alpha = 0 for no smoothing towards uniform distribution!!

# training the model
classifer.fit(X, y)

# testing the model
y_pred = classifer.predict(x_new)
print("Prdection (0 = no, 1 = yes)")
print(y_pred) # Prediction is "not Banana"

y_prop = classifer.predict_proba(x_new)
print("Propabilities for (no - yes)")
print(y_prop)