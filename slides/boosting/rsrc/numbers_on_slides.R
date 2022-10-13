betahat1 <- log(.7/.3)/2 # stimmt
w2f <- exp(log(.7/.3)/2)/10 # stimmt
w2t <- exp(-log(.7/.3)/2)/10 # stimmt

# sum of weights
s2 <- 7*w2t+3*w2f

# normalized weights
w2fn <- w2f/s2 # stimmt
w2tn <- w2t/s2 # stimmt

####################
# next iteration

err2 <- 3*w2tn # stimmt
betahat2 <- .5*log((1-err2)/err2) # stimmt

w3f <- w2tn*exp(betahat2) # stimmt
w3t_vorher_f <- w2fn*exp(-betahat2)
w3t_vorher_t <- w2tn*exp(-betahat2)

s3 <- 3*w3f + 3*w3t_vorher_f + 4*w3t_vorher_t

# normalized weights
w3fn <- w3f/s3 # stimmt
w3t_vorher_fn <- w3t_vorher_f/s3
w3t_vorher_tn <- w3t_vorher_t/s3

####################
# next iteration

err3 <- 3*w3t_vorher_tn # stimmt
betahat3 <- .5*log((1-err3)/err3) # stimmt
