library(data.table)
library(parallel)

#gene windows created from TAIR 10 gff for CHROM 5 first 100 genes same as sim
genes<-fread("1001info/gene100.csv")
colnames(genes)<-c("start","stop","V3")
setkey(genes,start,stop)

intergenes<-fread("1001info/intergene100.csv")
colnames(intergenes)<-c("start","stop","V3")
setkey(intergenes,start,stop)

#tajima directory
tajima_dir<-"/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/tajima/"
# Get all Tajima's D files
tajima_files <- list.files(tajima_dir, pattern = "\\.Tajima\\.D$", full.names = TRUE)

process_file <- function(file_path) {
  library(data.table)
  tryCatch({
    # Read Tajima's D data
    tajima <- fread(file_path)
    
    if (!all(c("BIN_START", "N_SNPS", "TajimaD") %in% colnames(tajima))) {
      stop("Missing required columns")
    }

    tajima[, START := BIN_START]
    tajima[, STOP := START + 100]
    tajima[, CHROM := 5]
    setkey(tajima, START, STOP)

    gene_overlaps <- foverlaps(tajima, genes, by.x = c("START", "STOP"), by.y = c("start", "stop"), type = 'any', nomatch = 0L)
    intergene_overlaps <- foverlaps(tajima, intergenes, by.x = c("START", "STOP"), by.y = c("start", "stop"), type = 'any', nomatch = 0L)

    stats <- data.table(
      ID = sub("\\.Tajima\\.D$", "", basename(file_path)),
      g_snps = if (nrow(gene_overlaps) > 0) sum(gene_overlaps$N_SNPS, na.rm = TRUE) else NA,
      i_snps = if (nrow(intergene_overlaps) > 0) sum(intergene_overlaps$N_SNPS, na.rm = TRUE) else NA,
      g_td = if (nrow(gene_overlaps) > 0) mean(gene_overlaps[TajimaD != "NaN", TajimaD], na.rm = TRUE) else NA,
      i_td = if (nrow(intergene_overlaps) > 0) mean(intergene_overlaps[TajimaD != "NaN", TajimaD], na.rm = TRUE) else NA
    )

    return(stats)
  }, error = function(e) {
    message(sprintf("❌ Error processing file: %s\n  ➤ %s", file_path, e$message))
    return(NULL)
  })
}


# Use mclapply to run in parallel
no_cores <- detectCores() - 1  # Leave one core free
results <- mclapply(tajima_files, process_file, mc.cores = no_cores)
results <- Filter(Negate(is.null), results)  # remove NULLs before binding

# Combine all results into one data.table
final_stats <- rbindlist(results)
fwrite(final_stats, "sim_tajima_stats_6.25.2025.csv")

