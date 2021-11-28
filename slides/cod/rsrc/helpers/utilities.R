S_p <- function(p){
  2 * (pi^((p + 1)/2))/gamma((p + 1)/2)
}

V_p <- function(p) {
  (pi^(p/2))/gamma(p/2 + 1)
}

V_p_r <- function(p, r) {
  V_p(p) * r^p
}

S_p_r <- function(p, r) {
  S_p(p) * r^p
}

p_r <- function(r, p=2, sigma=1){
  S_p_r(p - 1,r) / ((2*pi*sigma^2)^(p/2)) * exp(-r^2/(2*sigma^2))
}