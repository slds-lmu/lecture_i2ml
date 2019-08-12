library(forecast) 
#confusion matrix
(conf <- with(cdata, table("Prediction"=scored.class, "Reference"=class)))


TF_PN <-  ifelse(cdata$class==0 & cdata$scored.class==0, "TN",ifelse(cdata$class==0 & cdata$scored.class==1, "FP",
                                                     ifelse(cdata$class==1 & cdata$scored.class==0, "FN", "TP")))
conf <-table(TF_PN)

#precision
precision_x <- conf["TP"]/(conf["TP"]+conf["FP"])
precision_x

#sensitivity
sensitivity_x <- conf["TP"]/(conf["TP"]+conf["FN"])
sensitivity_x

#accuracy
accuracy_x <-(conf["TP"]+conf["TN"])/sum(conf)
accuracy_x

#specificity
specificity_x <-conf["TN"]/(conf["TN"]+conf["FP"])
specificity_x

#error Rate
error_x <-(conf["FP"]+conf["FN"])/sum(conf)
error_x

#F-measure
F_measure_x <- (2*precision_x*sensitivity_x)/(precision_x+sensitivity_x)
F_measure_x

#negative predictive value
NPV <- conf["TN"]/(conf["TN"]+conf["FN"])
NPV

library(pROC)
#install.packages("pROC")
roc.val <- roc(class~scored.probability, cdata)
plot(roc.val, main="pROC package ROC plot") 
