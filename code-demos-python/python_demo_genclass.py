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
from scipy.stats import multivariate_normal, norm
from sklearn.preprocessing import normalize
from sklearn.neighbors import KernelDensity
import sklearn.metrics as metrics

width = st.sidebar.slider('Layout Width',min_value=500,max_value=2000,value=800)

_page_width_(width)

st.markdown("""
# Generative Classification Methods
In supervised machine learning, the goal is to predict the class $k$ given the data $x$; i.e. we want to model $P(y=k/x)$. 
There are two ways to achieve this:
- Discriminative Classification : By directly modeling $P(y=k/x)$
- Generative Classification : By modeling $P(x/y=k)$ and then use Bayes theorem to get :
$P(y=k/x) = \\dfrac{P(x/y=k)P(y=k)}{P(x)}$

Essentially generative models try to model the data generation process for each class; and weight it with the prior probability of observing
each class. In our setting for $K$ classes, we can use $P(x) = \\displaystyle\\sum_j^K P(x/y=j)P(y=j)$ in ur Bayes Theorom formulation, to get :

$P(y=k/x) = \\dfrac{P(x/y=k)P(y=k)}{\\displaystyle\\sum_j^K P(x/y=j)P(y=j)}$

""")

st.markdown("""
## Dataset
We will be using iris dataset in this demo. The dataset is comprised of 4 features of three types of iris species. The dataset is loaded and transformed to
a Pandas dataframe as follows :
""")
with st.echo():
    iris = datasets.load_iris()

    iris_df = pd.DataFrame(data=iris.data,columns=iris.feature_names)
    iris_df['label'] = iris.target
    target_names = {i:v for i,v in enumerate(iris.target_names)}
    iris_df.label = iris_df.label.replace(target_names)

iris_df

st.markdown("""
### Summary of Features
""")
st.write(iris_df.describe())
# st.write(iris_df.dtypes)

st.markdown("""
## Visualization
In the following you can visualize the dataset either in 2D or in 3D selecting two or three of the 4 features.

### 2D plots
""")

feature_x = st.selectbox(
                    '2D Plot : Please select the feature for x-axis',
                    iris.feature_names)

feature_y = st.selectbox(
                    '2D Plot : Please select the feature for y-axis',
                    iris.feature_names)

sns.scatterplot(x=iris_df[feature_x], y=iris_df[feature_y], hue=iris_df.label)
st.pyplot()

st.markdown("""
### 3D plots
""")
feature_x3 = st.selectbox(
                    '3D Plot : Please select the feature for x-axis',
                    iris.feature_names, key="3d")

feature_y3 = st.selectbox(
                    '3D Plot : Please select the feature for y-axis',
                    iris.feature_names,key="3d")

feature_z3 = st.selectbox(
                    '3D Plot : Please select the feature for z-axis',
                    iris.feature_names,key="3d")

fig=px.scatter_3d(iris_df,x=feature_x3, y=feature_y3, z=feature_z3, color="label")
st.write(fig)

## LDA ##

st.markdown("""
## Discriminant Analysis

In discriminant analysis, we model the generative process as a normal distribution with a separate mean for each class. 
If we assume that all four classes have same covariance matrix, we get **_Linear_ Discriminant Analysis**. 
If however we model each class with its own covariance matrix
we get **_Quadratic_ Discriminant Analysis**. In the following you will get to play with both. 

For LDA, we have
""")

st.latex(r"p(x \mid y=k)=\frac{1}{\pi^{\frac{p}{2}}|\Sigma|^{\frac{1}{2}}} \exp \left(-\frac{1}{2}\left(x-\mu_{k}\right)^{T} \Sigma^{-1}\left(x-\mu_{k}\right)\right)")

st.latex(r"""
    where : 
    \begin{array}{l}
        \hat{\mu}_{k}=\frac{1}{n_{k}} \sum_{i: y^{(i)}=k} x^{(i)} \\
        \hat{\Sigma}=\frac{1}{n-g} \sum_{k=1}^{g} \sum_{i: y^{(i)}=k}\left(x^{(i)}-\hat{\mu}_{k}\right)\left(x^{(i)}-\hat{\mu}_{k}\right)^{T}
    \end{array}""")

st.write("For QDA, it becomes:")
st.latex(r"p(x \mid y=k)=\frac{1}{\pi^{\frac{p}{2}}\left|\Sigma_{k}\right|^{\frac{1}{2}}} \exp \left(-\frac{1}{2}\left(x-\mu_{k}\right)^{T} \Sigma_{k}^{-1}\left(x-\mu_{k}\right)\right)")

st.latex(r"""
    where : 
    \begin{array}{l}
        \hat{\mu}_{k}=\frac{1}{n_{k}} \sum_{i: y^{(i)}=k} x^{(i)} \\
        \hat{\Sigma_{k}}=\frac{1}{n_k-1} \sum_{i: y^{(i)}=k}\left(x^{(i)}-\hat{\mu}_{k}\right)\left(x^{(i)}-\hat{\mu}_{k}\right)^{T}
    \end{array}""")

st.markdown("""
To train the model, we simply calculate the means for each class separately and the covariance either for the whole dataset (LDA) or each class separately (QDA).
""")
with st.echo():
    means = iris_df.groupby('label').mean()
    means_dict = dict(zip(iris.target_names,means.values))
    cov_all = np.cov(iris.data.T)
    cov_classwise = iris_df.groupby('label').cov()
    cov_dict={label:cov_classwise.loc[label].to_numpy() for label in iris.target_names}
    cov_dict.update({'all':cov_all})

st.write("The gaussian likelihood is implemented as follows :")
with st.echo():
    def likelihood_matrix(x,mu,cov,dim=1):
        assert cov.shape==(dim,dim)
        assert x.shape==mu.shape
        
        if x.shape[0]!=dim:
            x=x.T 
            mu=mu.T

        mah_distance = (x-mu).T.dot(np.linalg.inv(cov)).dot(x-mu)
        exp_component = np.exp(-0.5*mah_distance)
        norm_component = np.pi**(dim/2)*np.sqrt(np.linalg.det(cov))

        return exp_component/norm_component

st.write("Then we create two dataframes for LDA and QDA and calculate the likelihoods :")

with st.echo():
    likelihood_lda = pd.DataFrame(columns=iris.target_names)
    likelihood_qda = pd.DataFrame(columns=iris.target_names)

    for sp in iris.target_names:
        for i in range(iris.data.shape[0]):
            likelihood_lda.loc[i,sp]=likelihood_matrix(iris.data[i,:],means_dict[sp],cov_dict['all'],dim=4)

    for sp in iris.target_names:
        for i in range(iris.data.shape[0]):
            likelihood_qda.loc[i,sp]=likelihood_matrix(iris.data[i,:],means_dict[sp],cov_dict[sp],dim=4)

# def gen_norm(mu,cov,n=1000):
    
#     return multivariate_normal.rvs(mean=mu,cov=cov,size=n)

@st.cache
def generate_normal_data(sp,type='lda'):
    if type=='qda':
        return multivariate_normal.rvs(mean=means_dict[sp],cov=cov_dict[sp],size=1000)
    elif type=='lda':
        return multivariate_normal.rvs(mean=means_dict[sp],cov=cov_dict['all'],size=1000)

ax1 = sns.scatterplot(x=iris_df['sepal length (cm)'], y=iris_df['sepal width (cm)'], hue=iris_df.label)
plt.title('Linear Discriminant Analysis')
for sp in iris.target_names:
    sns.kdeplot(generate_normal_data(sp,'lda')[:,0],
                generate_normal_data(sp,'lda')[:,1],ax=ax1)
st.pyplot()

ax2=sns.scatterplot(x=iris_df['sepal length (cm)'], y=iris_df['sepal width (cm)'], hue=iris_df.label)
plt.title('Quadratic Discriminant Analysis')
for sp in iris.target_names:
    sns.kdeplot(generate_normal_data(sp,'qda')[:,0],
                generate_normal_data(sp,'qda')[:,1],ax=ax2)
st.pyplot()


## Naive Bayes ##

st.markdown("""
## Naive Bayes Classifiers

In almost all cases, the features in a dataset are not independent; however if we make the _naive_ assumption that all features are 
conditionally independent, we arrive at the appropriately named **Naive Bayes** classifiers. 
Thus given the class of the target, the joint density/likelihood of all the features is just the product of the
univariate densities of each separate feature (i.e., the features are **independent** given y).
""")

st.latex(r'p(x \mid y=k)=\prod_{j=1}^{p} p\left(x_{j} \mid y=k\right)')

st.markdown("""
We will experiment with following types of likelihood functions:
- Gaussian Likelihood
- Kernelized Densities
- Categorical features

### Gaussian Likelihood
In the Iris dataset, we have 4 features, hence the likelihood will be product of 4 gaussians with each guassian calculated from
one feature for each class. Since we have already calculated the means and covariance matrices previously, we make use of that and 
note that the 4 variances for each feature are the diagonal entries of a covariance matrix. Thus, for example, for class _setosa_, we get
""")

train_ratio = 0.9
data_size = len(iris_df)

train_mask = np.random.choice([True,False],size=data_size, p=[train_ratio,1-train_ratio])
train_data = iris_df[train_mask]
test_data = iris_df[~train_mask]

# means = iris_df.groupby('label').mean()
# cov_classwise = iris_df.groupby('label').cov()
with st.echo():
    means.loc['setosa'].values
    cov_classwise.loc['setosa']
    np.diag(cov_classwise.loc['setosa'].values)

st.markdown("""
To capture all the parameters in a data structure which can be used conveniently later on, we use a Multi Index Dataframe like so:
""")
with st.echo():
    row_index = pd.MultiIndex.from_product([iris.target_names,['mean','var']], names=['specie','param'])
    parameter_df = pd.DataFrame(np.zeros((4,6)),columns= row_index, index = iris.feature_names)

    for specie in iris.target_names:
        parameter_df[specie]['mean'] = means.loc[specie].values
        parameter_df[specie]['var'] = np.diag(cov_classwise.loc[specie].values)

    parameter_df=parameter_df.T.sort_index()
    parameter_df

"To calculate Naive Bayes likelihood for any sample, we make use of the gaussian pdf evaluation function for a given sample and the parameter dataframe from above."

with st.echo():
    def gaussian_prob(x,mu,var):

        residual = x-mu
        exp_component = np.exp(-0.5*(residual**2)/var)
        norm_component = np.sqrt(np.pi*var)

        return exp_component/norm_component

    def naive_bayes(x,parameter_df):
        class_likelihood = {}
        for specie in iris.target_names:
            likelihood_val = 1.0
            for i,feature in enumerate(iris.feature_names):
                mu = parameter_df.loc[specie,'mean'][feature]
                var = parameter_df.loc[specie,'var'][feature]
                l = gaussian_prob(x[i],mu,var)
                likelihood_val=likelihood_val*l
            class_likelihood[specie]=likelihood_val
        
        return class_likelihood

# Since all priors probabilites are the same, we can drop them.
# st.write(iris_df.groupby('label').count())

"Here I will show the result for 10 randomly sampled datapoints"

with st.echo():
    for i in np.random.randint(150,size=10):
        x = iris.data[i]
        true_label = iris.target_names[iris.target[i]]

        likelihood = naive_bayes(x,parameter_df)
        evidence = sum(likelihood.values())
        posterior = {label:likelihood/evidence for label,likelihood in likelihood.items()}
        pred_label,pred_prob = max(posterior.items(), key=lambda x:x[1])
        f"{i} : {pred_label} : {pred_prob} : {pred_label==true_label}"

st.markdown("### Naive Bayes with Kernelized Densities")

"Here you can "
feature = st.selectbox('Select Feature :',options=iris.feature_names)
X = iris_df.loc[:,feature]
kernel = st.selectbox('kenel',options=['gaussian', 'tophat',
                            'exponential', 'linear', 'cosine'])

kdekernel = {'gaussian':'gau',
             'cosine':'cos',
             'tophat':'tri',}

bw = st.slider('bw',min_value=0.01,max_value=1.0,value=0.1)

sns.kdeplot(X,kernel=kdekernel.get(kernel,0),bw=bw)
st.pyplot()

kde = KernelDensity(kernel=kernel,bandwidth=bw).fit(X.values.reshape(-1,1))
likelihood = np.exp(kde.score_samples(X.values.reshape(-1,1)))

# plt.scatter(X.values.reshape(-1,1),likelihood)
# st.pyplot()

@st.cache
def naive_bayes_kde(X_train_df,X_test_df,kernel='gaussian',bw=0.5):
    class_likelihood = {}
    for specie in iris.target_names:
        likelihood_val = np.ones((X_test_df.shape[0],))
        for i,feature in enumerate(iris.feature_names):
            X_train = X_train_df.query('label==@specie').loc[:,feature]
            X_test = X_test_df.loc[:,feature]
            kde = KernelDensity(kernel=kernel,bandwidth=bw).fit(X_train.values.reshape(-1,1))
            likelihood = np.exp(kde.score_samples(X_test.values.reshape(-1,1)))
            likelihood_val = np.multiply(likelihood_val,likelihood)
        class_likelihood[specie]=likelihood_val
    return pd.DataFrame.from_dict(class_likelihood)

class_likelihood = naive_bayes_kde(iris_df,iris_df,kernel=kernel,bw=bw)
class_prob = class_likelihood.div(class_likelihood.sum(axis=1),axis=0)
class_prob['prediction'] = class_prob.idxmax(axis=1)
class_prob['label']=iris_df.label
st.write(class_prob.sample(10))
st.write(metrics.confusion_matrix(class_prob.label,class_prob.prediction,labels=iris.target_names))