library(ElemStatLearn)

spam = spam
vars = read.table("gbm_spam_vars.txt", sep=":", comment.char="", stringsAsFactors=FALSE)[,1]
colnames(spam)[1:57] = vars

colnames(spam)[49] = "char_freq_semicol"
colnames(spam)[50] = "char_freq_brack_r"
colnames(spam)[51] = "char_freq_brack_sq"
colnames(spam)[52] = "char_freq_exclam"
colnames(spam)[53] = "char_freq_dollar"
colnames(spam)[54] = "char_freq_sharp"

save(spam, file = "spam.RData")
#load("spam.RData")
