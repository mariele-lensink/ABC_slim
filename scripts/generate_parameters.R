##This script populates a table of parameter values for however many simulations you plan to run
library(data.table)
library(parallel)

# Set a base seed for reproducibility
set.seed(as.integer(Sys.time()))

# Generate 100,000 unique IDs and random parameters
num_simulations <- 50000
log_uniform <- function(n, min, max) 10^runif(n, log10(min), log10(max))
log_uniform_neg <- function(n, min_abs, max_abs) -10^runif(n, log10(min_abs), log10(max_abs))

params <- data.table(
  ID = 20001:(20001 + num_simulations - 1),
  gmu = log_uniform(num_simulations, 3e-8, 5.3e-5),
  imu = log_uniform(num_simulations, 3e-8, 5.3e-6),
  gd = runif(num_simulations,0.1,0.7),
  id = runif(num_simulations,0.1,0.7),
  gdfe = log_uniform_neg(num_simulations,1e-3, 1e-1),

  idfe = log_uniform_neg(num_simulations,1e-3, 1e-1)
  #.001-.01
)

# Write to a CSV file
fwrite(params, "/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/prior_parameters3_20k-50k.csv", sep = ",", col.names = TRUE)
