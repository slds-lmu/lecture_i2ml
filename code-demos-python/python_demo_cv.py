import streamlit as st
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from utils import _page_width_, float_formatter

from sklearn import datasets, metrics
from sklearn.neighbors import KNeighborsClassifier 

def run():
    iris = datasets.load_iris()
    data = np.hstack((iris.data,iris.target.reshape(-1,1)))

    width = st.sidebar.slider('Layout Width',min_value=500,max_value=2000,value=800)

    _page_width_(width)

    st.markdown("""
    # Cross Validation

    In this demo we first implement a cross validation function and then explore the effects of number of folds on KNN Classifier as applied on Iris Dataset."

    The cross validation function is implemented as follows:
    It takes as input a numpy array of shape (Nx(d+1)) where N is number of samples and d is feature dimension. The labels are appended with the dataset.
    It also takes number o folds and an sklearn Classifier object.
    """)

    with st.echo():
        @st.cache
        def cross_validate(data,folds,clf):
            np.random.shuffle(data) #  Shuffle the data inplace on rows

            splits = np.array_split(data,folds) # Splitting the dataset in folds

            all_results = []

            for i in range(folds):
                result = {}
                train = splits.copy() # Do a deep copy of the split data. 
                test = np.array(train.pop(i)) # Popping out one split and marking it as test. The rest of the dataset will be the trainset. 
                train = np.concatenate(train) # Concatenating all train splits into one. 

                X_train = train[:,:-1] # Seperating the labels as last columbs
                y_train = train[:,-1]
                X_test = test[:,:-1]
                y_test = test[:,-1]

                model = clf.fit(X_train,y_train)
                y_pred_train = model.predict(X_train)    
                y_pred_test = model.predict(X_test)

                acc_train = metrics.accuracy_score(y_train,y_pred_train)
                acc_test = metrics.accuracy_score(y_test,y_pred_test)

                result['train']=acc_train
                result['test']=acc_test
                all_results.append(result)

            return pd.DataFrame.from_dict(all_results)

    folds = st.slider('Select Number of Cross Validation Folds',min_value=1,max_value=20,value=3)

    "We use a simple KNN Classifier and pass it to the function implemented above"
    with st.echo():
        clf = KNeighborsClassifier()
        output = cross_validate(data,folds,clf)

    "The train and test accuracies for "+str(folds)+" folds are :"
    st.write(output)

    st.markdown("""
    ## Comparison across various folds

    In this section, we apply CV across increasing number of folds and see the result on train and test dataset"
    """)
    with st.echo():
        fold_list = [2,3,4,5,10,15,20,25,30,35,40,45,50,55,60]

    @st.cache
    def compile_results(fold_list):
        all_results=[]
        for num_folds in fold_list:
            result={}
            output = cross_validate(data,num_folds,clf)
            result['train_mean']=1.0-output.train.mean() # Convert accuracy to error
            result['train_var']=output.train.var()
            result['test_mean']=1.0-output.test.mean()
            result['test_var']=output.test.var()
            all_results.append(result)
        compiled = pd.DataFrame.from_dict(all_results)
        compiled.index=fold_list
        return compiled

    plot_data = compile_results(fold_list)

    if st.checkbox('Show results dataframe'):
        st.write(plot_data)

    split = st.radio('Select Train or Test Split',options=['Train','Test'])
    split_dict = {'Train': {'mean': 'train_mean',
                            'var': 'train_var'},
                'Test' : {'mean': 'test_mean',
                            'var': 'test_var'}}

    sns.barplot(x=fold_list,y=split_dict[split]['mean'],ci=split_dict[split]['var'],data=plot_data)
    plt.xlabel('Number of cv folds')
    plt.ylabel('Prediction Error (%)')
    st.pyplot()

if __name__=='__main__':
    run()