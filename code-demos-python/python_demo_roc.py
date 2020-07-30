import streamlit as st
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from utils import _page_width_, float_formatter
plt.rcParams['figure.figsize'] = 10,10

import sklearn
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder, StandardScaler
import sklearn.metrics as metrics

width = st.sidebar.slider('Layout Width',min_value=500,max_value=2000,value=800)

_page_width_(width)

TRAIN_RATIO = 0.8
np.random.seed(42)
np.set_printoptions(formatter={'float_kind':float_formatter})

st.markdown("""
# Reciever Operating Curve (ROC) Demo

## Dataset
We use the Breast Cancer dataset from [Kaggle](https://www.kaggle.com/uciml/breast-cancer-wisconsin-data/data)
""")

with st.echo():
    df=pd.read_csv('datasets_180_408_data.csv')
    df.drop(['Unnamed: 32'],axis=1,inplace=True)

st.write(df)

st.write("Class ratios : ",df['diagnosis'].value_counts()/df.shape[0])

"Splitting the dataset into train and test : "
with st.echo():
    msk = np.random.rand(len(df)) < TRAIN_RATIO
    train = df[msk]
    test = df[~msk]

def convert_df_Xy(df):
    X = df.drop(['diagnosis','id'],axis=1)
    y = df['diagnosis']
    le = sklearn.preprocessing.LabelEncoder().fit(y)
    y = le.transform(y)
    return X,y

X_train,y_train = convert_df_Xy(train)
X_test,y_test = convert_df_Xy(test)

scaler = sklearn.preprocessing.StandardScaler().fit(X_train)
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

st.markdown("""
## Logistic Regression

""")
with st.echo():
    clf_logreg = sklearn.linear_model.LogisticRegression().fit(X_train,y_train)
    y_score_logreg = clf_logreg.predict_proba(X_test)[:,1]

threshold_logreg = st.slider('threshold',min_value=0.0,max_value=1.0,value=0.5)
y_pred_logreg = y_score_logreg>threshold_logreg
fpr_lr, tpr_lr, thresholds = metrics.roc_curve(y_test, y_score_logreg, pos_label=1)

st.write("AUC : ", float_formatter(sklearn.metrics.roc_auc_score(y_test,y_pred_logreg)))
st.write("Accuracy Score : ", float_formatter(sklearn.metrics.accuracy_score(y_test,y_pred_logreg)))
st.write("Confusion Matrix : ", sklearn.metrics.confusion_matrix(y_test,y_pred_logreg))

st.markdown("""
## K-Nearest Neighbors

""")
with st.echo():
    clf_knn = sklearn.neighbors.KNeighborsClassifier().fit(X_train,y_train)
    y_score_knn = clf_knn.predict_proba(X_test)[:,1]

threshold_knn = st.slider('threshold',min_value=0.0,max_value=1.0,value=0.5,key='knn')
y_pred_knn = y_score_knn>threshold_knn
fpr_knn, tpr_knn, thresholds = metrics.roc_curve(y_test, y_score_knn, pos_label=1)

st.write("AUC : ", float_formatter(sklearn.metrics.roc_auc_score(y_test,y_pred_knn)))
st.write("Accuracy Score : ", float_formatter(sklearn.metrics.accuracy_score(y_test,y_pred_knn)))
st.write("Confusion Matrix : ", sklearn.metrics.confusion_matrix(y_test,y_pred_knn),labels=['benign','malignant'])

st.markdown("""
## Predict Majority class (Naive Classifier)

""")
with st.echo():
    y_pred_naive = np.repeat(1,y_test.shape[0])

st.write("AUC : ", float_formatter(sklearn.metrics.roc_auc_score(y_test,y_pred_naive)))
st.write("Accuracy Score : ", float_formatter(sklearn.metrics.accuracy_score(y_test,y_pred_naive)))
st.write("Confusion Matrix : ", sklearn.metrics.confusion_matrix(y_test,y_pred_naive))

sns.lineplot(fpr_lr,tpr_lr)
sns.lineplot(fpr_knn,tpr_knn)
sns.lineplot([0, 1], [0, 1])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.legend(['logreg','knn','naive'])
plt.title('ROC for Logistic Regression and KNN Classifier')
st.pyplot()