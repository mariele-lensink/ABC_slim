library(data.table)
library(parallel)

#ene windows created from TAIR 10 gff for CHROM 5 first 100 genes same as sim
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
  # Read Tajima's D data
  tajima <- fread(file_path)
  tajima[, START := BIN_START]
  tajima[, STOP := START + 100]
  tajima[, CHROM := 5]
  setkey(tajima,START,STOP)  
  
  gene_overlaps<-foverlaps(tajima,genes,by.x=c("START","STOP"),by.y=c("start","stop"),type = 'any',nomatch=0L)
  intergene_overlaps<-foverlaps(tajima,intergenes,by.x=c("START","STOP"),by.y=c("start","stop"),type = 'any',nomatch=0L)
  
  gene_overlaps[,sum(N_SNPS)]
  gene_overlaps[TajimaD != "NaN",mean(TajimaD)]
  
  intergene_overlaps[,sum(N_SNPS)]
  intergene_overlaps[TajimaD != "NaN",mean(TajimaD)]
  
  # Compute stats
  stats <- data.table(
    ID = sub("\\.Tajima\\.D$", "", basename(file_path)),
    g_snps=gene_overlaps[,sum(N_SNPS)],
    i_snps=intergene_overlaps[,sum(N_SNPS)],
    g_td=gene_overlaps[TajimaD != "NaN",mean(TajimaD)],
    i_td=intergene_overlaps[TajimaD != "NaN",mean(TajimaD)]
  )
  
  return(stats)
}

# Use mclapply to run in parallel
no_cores <- detectCores() - 1  # Leave one core free
results <- mclapply(tajima_files, process_file, mc.cores = no_cores)

# Combine all results into one data.table
final_stats <- rbindlist(results)
fwrite(final_stats, "sim_tajima_stats_5.21.2025.csv")
