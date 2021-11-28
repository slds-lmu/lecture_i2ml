S_p <- function(p){
  2 * (pi^((p + 1)/2))/gamma((p + 1)/2)
}

V_p_r <- function(p, r) {
  (pi^(p/2))/gamma(p/2 + 1) * r^p
}

p_r <- function(r, p=2, sigma=1){
  V_p_r(p, r) * p / r / ((2*pi*sigma^2)^(p/2)) * exp(-r^2/(2*sigma^2))
}