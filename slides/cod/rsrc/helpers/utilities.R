S_p <- function(p){
  p * (pi^(p/2))/gamma(p/2 + 1)
}

V_p <- function(p) {
  (pi^(p/2))/gamma(p/2 + 1)
}

V_p_r <- function(p, r) {
  V_p(p) * r^p
}

S_p_r <- function(p, r) {
  S_p(p) * r^(p - 1)
}

p_r <- function(r, p=2, sigma=1){
  S_p_r(p,r) / ((2*pi*sigma^2)^(p/2)) * exp(-r^2/(2*sigma^2))
}