library(data.table)
library(polymorphology2)

# real gene windows created from TAIR 10 gff for CHROM 5 first 100 genes
genes<-fread("/Users/mlensink/Documents/mutationrate/github/mutationrate_slim/genomeinfo/gene100.csv")
colnames(genes)<-c("start","stop","V3")
intergenes<-fread("/Users/mlensink/Documents/mutationrate/github/mutationrate_slim/genomeinfo/intergene100.csv")
colnames(intergenes)<-c("start","stop","V3")
## read in your tajimas D files for a given progeny sim replicates and combine into one object "tajima"
tajima <- fread("github/ABC_slim/1001info/1001g_tajima.txt") # create by looping across all reps per ID and rbinding
tajima<-tajima[CHROM == "5",]
tajima$START <- tajima$BIN_START
tajima$STOP <- tajima$START + 100

setkey(tajima,START,STOP)
setkey(genes,start,stop)
setkey(intergenes,start,stop)
gene_overlaps<-foverlaps(tajima,genes,by.x=c("START","STOP"),by.y=c("start","stop"),type = 'any',nomatch=0L)
intergene_overlaps<-foverlaps(tajima,intergenes,by.x=c("START","STOP"),by.y=c("start","stop"),type = 'any',nomatch=0L)

gene_overlaps[,sum(N_SNPS)]
gene_overlaps[TajimaD != "NaN",mean(TajimaD)]

intergene_overlaps[,sum(N_SNPS)]
intergene_overlaps[TajimaD != "NaN",mean(TajimaD)]

stats1001<-data.table(g_snps=gene_overlaps[,sum(N_SNPS)],
                      i_snps=intergene_overlaps[,sum(N_SNPS)],
                      g_td=gene_overlaps[TajimaD != "NaN",mean(TajimaD)],
                      i_td=intergene_overlaps[TajimaD != "NaN",mean(TajimaD)])


fwrite(stats1001,"stat.1001.txt")

