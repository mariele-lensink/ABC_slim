library(data.table)
library(polymorphology2)

# real gene windows created from TAIR 10 gff for CHROM 5 first 100 genes
gene_windows <- fread("github/ABC_slim/1001info/gene_windows.csv")

## read in your tajimas D files for a given progeny sim replicates and combine into one object "tajima"
tajima <- fread("github/ABC_slim/1001info/1001g_tajima.txt") # create by looping across all reps per ID and rbinding
###
#clean them so they have correct columns...
tajima$START <- tajima$BIN_START
tajima$STOP <- tajima$START + 100
tajima$CHROM <- 5 # fix chrome name

# calculate SNPS means for all gene windows
gene_windows_snps<-features_in_features(gene_windows, tajima, mode = "mean", value = "N_SNPS")
gene_windows$counts<-gene_windows_snps$mean[match(gene_windows$ID, gene_windows_snps$ID)] 

# calculate tajimasD means for all gene windows
gene_windows_tajima <- features_in_features(gene_windows, tajima, mode = "mean", value = "TajimaD")
gene_windows$tajima<-gene_windows_tajima$mean[match(gene_windows$ID, gene_windows_tajima$ID)] 

stats1001<-data.table(g_snps=gene_windows[REGION=="gene body",mean(counts),],
                      i_snps=gene_windows[REGION!="gene body",mean(counts,na.rm=T),],
                      g_td=gene_windows[REGION=="gene body",mean(tajima),],
                      i_td=gene_windows[REGION!="gene body",mean(tajima,na.rm=T),]
                      )
stats1001$g_snps<-gene_windows[REGION=="gene body",mean(counts),]
#summarize tajimas D and SNPS means across all relative positions in relation to gene bodies (i.e. RELATIVEPOSs 1:60)
#tajima_means<-plot_feature_windows(gene_windows, variable="tajima", mode="mean")[[1]]
#mutations_means<-plot_feature_windows(gene_windows, variable="counts", mode="mean")[[1]]

