library(data.table)
library(polymorphology2)
library(parallel)

# real gene windows created from TAIR 10 gff for CHROM 5 first 100 genes
gene_windows <- fread("github/ABC_slim/1001info/gene_windows.csv")

#tajima directory
tajima_dir<-"data/tajima/"
# Get all Tajima's D files
tajima_files <- list.files(tajima_dir, pattern = "\\.Tajima\\.D$", full.names = TRUE)

process_file <- function(file_path) {
  # Read Tajima's D data
  tajima <- fread(file_path)
  tajima[, START := BIN_START]
  tajima[, STOP := START + 100]
  tajima[, CHROM := 5]
  
  # Calculate SNP means for all gene windows
  gene_windows_snps <- features_in_features(gene_windows, tajima, mode = "mean", value = "N_SNPS")
  gene_windows[, counts := gene_windows_snps$mean[match(gene_windows$ID, gene_windows_snps$ID)]]
  
  # Calculate Tajima's D means for all gene windows
  gene_windows_tajima <- features_in_features(gene_windows, tajima, mode = "mean", value = "TajimaD")
  gene_windows[, tajima := gene_windows_tajima$mean[match(gene_windows$ID, gene_windows_tajima$ID)]]
  
  # Compute stats
  stats <- data.table(
    ID = sub("\\.Tajima\\.D$", "", basename(file_path)),
    g_snps = gene_windows[REGION == "gene body", mean(counts, na.rm = TRUE)],
    i_snps = gene_windows[REGION != "gene body", mean(counts, na.rm = TRUE)],
    g_td = gene_windows[REGION == "gene body", mean(tajima, na.rm = TRUE)],
    i_td = gene_windows[REGION != "gene body", mean(tajima, na.rm = TRUE)]
  )
  
  return(stats)
}

# Use mclapply to run in parallel
no_cores <- detectCores() - 1  # Leave one core free
results <- mclapply(tajima_files, process_file, mc.cores = no_cores)

# Combine all results into one data.table
final_stats <- rbindlist(results)
fwrite(final_stats, "sim_tajima_stats.csv")