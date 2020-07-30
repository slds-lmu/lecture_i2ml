import streamlit as st
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from utils import _page_width_, float_formatter
plt.rcParams['figure.figsize'] = 10,10

import plotly.express as px
from sklearn import datasets
import random
import sklearn

width = st.sidebar.slider('Layout Width',min_value=500,max_value=2000,value=800,step=100)
_page_width_(width)
TRAIN_RATIO=0.9

st.markdown("""
# K-Nearest Neighbor (KNN) Classifier

## KNN Recap
As the name suggests, this algorithm calculates the $k$ closest neighbors of a test datapoint and assigns it the majority class of those neighbors.
Since no model fitting is done, this is called a _non parametric_ algorithm. A consequence is that the prediction requires availability of whole training dataset.
The number $k$ is a hyperparameter.

## Distance Functions
There are different ways the distance to other datapoints can be calculated. Some of the most common ones are described below:

- Euclidean Distance : $d(a,b)=\\sqrt{(a-b)^T(a-b)}$
- Manhattan Distance : $d(a,b)=\\vert a-b \\vert$
- Mahalanobis Distance : $d(a,b)=\\sqrt{(a-b)^TS^{-1}(a-b)}$ where $S$ is the covariance matrix of the features
- Cosine Distance : $d(a,b)=\\dfrac{a^Tb}{\\vert a \\vert \\vert b \\vert}$

## Dataset
We will use Iris Dataset for this demo.
""")
with st.echo():
    from sklearn import datasets
    iris = datasets.load_iris()
    iris_df = pd.DataFrame(data=iris.data,columns=iris.feature_names)
    iris_df['label'] = iris.target
    target_names = {i:v for i,v in enumerate(iris.target_names)}
    iris_df.label = iris_df.label.replace(target_names)

# st.write(iris_df.label.astype('category')) # FIXME : Fix this problem

st.write("Complete Dataset : ",iris_df)
st.write("Characteristics of features : ",iris_df.describe())
# st.write(iris_df.dtypes)

"Splitting the dataset into train and test : "
with st.echo():
    msk = np.random.rand(len(iris_df)) < TRAIN_RATIO # =0.9
    train_df = iris_df[msk]
    test_df = iris_df[~msk]

st.markdown("""
## Visualizations

In the following, you will be able to explore the dataset in both 2D and 3D. Since there are 4 features, you have to select which two (three) features you want to see

### 2D-Visualization
""")

feature_x = st.selectbox(
                    'Please select the feature for x-axis',
                    random.sample(iris.feature_names,4))

feature_y = st.selectbox(
                    'Please select the feature for y-axis',
                    random.sample(iris.feature_names,4))

sns.scatterplot(x=iris_df[feature_x], y=iris_df[feature_y], hue=iris_df.label)
st.pyplot()

st.markdown("""
### 3D-Visualization
""")

feature_x3 = st.selectbox(
                    'Please select the feature for x-axis',
                    iris.feature_names, key="3d")

feature_y3 = st.selectbox(
                    'Please select the feature for y-axis',
                    iris.feature_names,key="3d")

feature_z3 = st.selectbox(
                    'Please select the feature for z-axis',
                    iris.feature_names,key="3d")

fig=px.scatter_3d(iris_df,x=feature_x3, y=feature_y3, z=feature_z3, color="label")
fig.update_layout(width=width,height=width)
st.write(fig)

st.markdown("""
## Implementation

The distance functions defined above are implemented as follows :
""")
with st.echo():
    def distance_euclidean(a,b):
        return (a-b).T.dot(a-b)

    def distance_manhattan(a,b):
        return np.sum(np.abs(a-b))

    def distance_mahalanobis(a,b,S):
        return (a-b).T.dot(np.linalg.inv(S)).dot(a-b)

    def distance_cosine(a,b):
        return a.dot(b)/(np.linalg.norm(a)*np.linalg.norm(b))

st.markdown("""
For the implementation of the algorithm itself, we calculate the distance of a given $test\_point$ with all points in the $train\_data$ using the $distance\_func$.
Then we find the $num\_neighbors (k)$ closest points using Numpy's argpartition() function. The function returns the labels of $k$ closest points and their distances.

The implementation of this function is as follows:
""")
with st.echo():
    @st.cache
    def knn_predict(test_point,train_data,distance_func,num_neighbors=3):

        train_data_numpy = train_data.to_numpy()[:,:-1] # dropping label column

        if distance_func=='distance_mahalanobis':
            S = train_data_numpy.T.dot(train_data_numpy)
            distances = np.array([func_dict[distance_func](test_point,x,S.astype('float')) for x in train_data_numpy])
        else:
            distances = np.array([func_dict[distance_func](test_point,x) for x in train_data_numpy])

        knn = np.argpartition(distances,range(num_neighbors+1))[1:num_neighbors+1]
        
        return train_data.label.iloc[knn]#, distances[knn]

st.markdown("""Since there is no training involved, we simply find the distance of all test points with training dataset.
The $test\_points$ generates tuples with the format : (index,dataframe_row). After getting the predictions for each point in test set, 
we count the values of returend labels in the prediction and mark the label with highest frequency as $most\_common\_label$. Then we add all the results
to a pandas dataframe.
""")

distance_function = st.selectbox('Please Select the Distance Function',options=['distance_mahalanobis','distance_euclidean','distance_manhattan','distance_cosine'])
func_dict = {'distance_euclidean':distance_euclidean,
             'distance_manhattan':distance_manhattan,
             'distance_mahalanobis':distance_mahalanobis,
             'distance_cosine':distance_cosine}

num_neighbors = st.slider('Select Number of Neighbors (k)',min_value=1,max_value=19,value=3,step=2)

with st.echo():
    test_points = test_df.iterrows()
    knn_result = pd.DataFrame(columns=['true_label','pred_label'],index=range(len(test_df)))

    for i,x in enumerate(test_points):
        label_true = x[1].label
        test_point = x[1].values[:-1]

        labels_knn = knn_predict(test_point,train_df,distance_function,num_neighbors=num_neighbors)
        most_common_label = labels_knn.value_counts().index[0]
        knn_result.loc[i]=[label_true,most_common_label]

knn_result
# st.write("AUC : ", float_formatter(sklearn.metrics.roc_auc_score(knn_result.true_label,knn_result.pred_label)))
# st.write("Accuracy Score : ", float_formatter(sklearn.metrics.accuracy_score(y_test,y_pred_logreg)))
# st.write("Confusion Matrix : ", sklearn.metrics.confusion_matrix(y_test,y_pred_logreg))