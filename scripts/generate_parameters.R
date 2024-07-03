library(data.table)
library(parallel)

# Set a base seed for reproducibility
set.seed(as.integer(Sys.time()))

# Generate 100,000 unique IDs and random parameters
num_simulations <- 10000
params <- data.table(
  ID = 1:num_simulations,
  gmu = runif(num_simulations),
  imu = runif(num_simulations),
  gd = runif(num_simulations),
  igd = runif(num_simulations),
  gdfe = runif(num_simulations),
  idfe = runif(num_simulations)
)

# Write to a CSV file
fwrite(params, "/data/prior_parameters.csv", sep = ",", col.names = TRUE)