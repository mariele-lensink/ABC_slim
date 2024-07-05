library(data.table)
library(parallel)

# Set a base seed for reproducibility
set.seed(as.integer(Sys.time()))

# Generate 100,000 unique IDs and random parameters
num_simulations <- 10000
params <- data.table(
  ID = 1:num_simulations,
  gmu = runif(num_simulations,1e-10,2e-8),
  imu = runif(num_simulations,1e-10,2e-8),
  gd = runif(num_simulations,0.1,0.7),
 # (0.1-0.7)
  id = runif(num_simulations,0.1,0.7),
  gdfe = runif(num_simulations,-0.1,-.001),
  #.001-.01 (shape = 0.14)
  idfe = runif(num_simulations,-0.1-.001)
  #.001-.01
)

# Write to a CSV file
fwrite(params, "/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/prior_parameters.csv", sep = ",", col.names = TRUE)
