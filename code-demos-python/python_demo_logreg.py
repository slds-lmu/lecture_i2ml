import streamlit as st
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.linear_model import LogisticRegression
from utils import _page_width_, float_formatter

def run():
    width = st.sidebar.slider('Layout Width',min_value=500,max_value=2000,value=800,step=100)

    _page_width_(width)

    @st.cache
    def logistic(x,theta):
        return 1/(1+np.exp(-x.dot(theta)))

    @st.cache
    def loss_bernoulli(y,x,theta):
        return np.log(1+1/np.exp(y*x.dot(theta))).squeeze()

    def abline(slope, intercept):
        """Plot a line from slope and intercept"""
        axes = plt.gca()
        xlim=axes.get_xlim()
        ylim=axes.get_ylim()
        x_vals = np.array(xlim)
        y_vals = intercept + slope * x_vals
        plt.plot(x_vals, y_vals, '--')
        plt.ylim(ylim)
        
    x = np.linspace(-5,5,100)

    theta_max = st.sidebar.text_input('Max theta', value=5.0)
    theta_min = st.sidebar.text_input('Min theta', value=0.0)
    assert theta_max>=theta_min, "Max of theta should be greater than min"

    theta = st.slider('theta', min_value=np.float(theta_min), max_value=np.float(theta_max), step=0.1,value=0.5)

    sns.lineplot(x,logistic(x,theta))
    st.pyplot()

    X = np.vstack([np.ones_like(x),x]).T
    theta = np.array([0,1]).reshape(-1,1)
    sns.lineplot(x,loss_bernoulli(y=1,x=X,theta=theta))
    sns.lineplot(x,loss_bernoulli(y=-1,x=X,theta=theta))
    plt.legend(['+1','-1'])
    plt.xlabel('f(x)')
    plt.ylabel('L(y,f(x))')
    st.pyplot()

    n=1000
    p=2

    theta_max = st.sidebar.text_input('Max Slope', value=5.0)
    theta_min = st.sidebar.text_input('Min Slope', value=-5.0)

    slope = st.slider('Slope', min_value=float(theta_min), max_value=float(theta_max), step=0.1,value=3.0)
    # intercept = st.slider('Intercept', min_value=-5.0, max_value=5.0, step=0.1,value=-1.0)

    X = np.random.uniform(-5,5,n*p).reshape(n,p)
    theta = np.array([slope,-1]).reshape(-1,1)
    y = 2*np.random.binomial(1,logistic(X,theta))-1

    clf = LogisticRegression(random_state=0).fit(X, y)
    y_pred = clf.predict(X)

    sns.scatterplot(X[:,0],X[:,1],hue=y.squeeze())#, style=y_pred.squeeze())
    slope_pred,intercept_pred = clf.coef_[0]
    abline(slope_pred, intercept_pred)
    st.pyplot()

if __name__=='__main__':
    run()