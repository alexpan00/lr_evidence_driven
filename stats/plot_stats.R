# Script to generate plots and test the results of the different AUGUSTUS models
# The F1 score is calculated at nt, exon and gene level. The number of perfect
# protein hits and the median identity is compared at protein level.

# Libraries 
library(ggplot2)
library(RColorConesa)
library(reshape2)
library(gtools)
library(readr)
library(viridis)

# Functions

# harmonic mean -> the harmonic mean of the Sn and de Pr is F-score
harmonic_mean <- function(sn, precision){
  2*(sn*precision)/(sn+precision)
}

# Plot functions
# The imput for all the functions is the summary dataframe produce by the script
# get_stats_WTC11.sabtch

# Barplots
# NT

# Plot the Sn, Pr and F-score at nt level
plot_nt <- function(summary_dataframe){
  # The first colum is the number of genes, the 2nd and the 3rd are the Sn and
  # Pr at nt level
  summary_dataframe <- summary_dataframe[,c(1,2,3)]
  # Get the F-score
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Reorder the data frame to plot the sn, pr and F-score for each number of genes
  nt <- melt(summary_dataframe, id=c("N_genes"))
  # Barplot of the stats
  # TO DO: adjust the F-score labels
  ggplot(nt, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("Nucleotide level") +
    ylim(c(0,100)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), # Include less decimals
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}

# Exon

# Plot the Sn, Pr and F-score at exon level
plot_exon <- function(summary_dataframe){
  # The first colum is the number of genes, the 4th and the 5th are the Sn and
  # Pr at exon level
  summary_dataframe <- summary_dataframe[,c(1,4,5)]
  # Get the F-score
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Reorder the data frame to plot the sn, pr and F-score for each number of genes
  exon <- melt(summary_dataframe, id=c("N_genes"))
  # Barplot of the stats
  # TO DO: adjust the F-score labels
  ggplot(exon, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("Exon level") +
    ylim(c(0,100)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), # Include less decimals
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}

# Gene

# Plot the Sn, Pr and F-score at gene level
plot_gene <- function(summary_dataframe){
  # The first colum is the number of genes, the 6th and the 7th are the Sn and
  # Pr at exon level
  summary_dataframe <- summary_dataframe[,c(1,6,7)]
  # Get the F-score
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Reorder the data frame to plot the sn, pr and F-score for each number of genes
  gene <- melt(summary_dataframe, id=c("N_genes"))
  # Barplot of the stats
  # TO DO: adjust the F-score labels
  ggplot(gene, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("gene level") +
    ylim(c(0,100)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), # Include less decimals
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}


# Protein

# Plot median protein identity
plot_identity <- function(summary_dataframe){
  # The fist colum is the number of genes, the 9th colum is the median identity
  summary_dataframe <- summary_dataframe[,c(1,9)]
  identity <- melt(summary_dataframe, id=c("N_genes"))
  ggplot(identity, aes(x=as.factor(N_genes), y=value))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ylab("Identity percentage") +
    ggtitle("Protein level") +
    ylim(c(0,100)) +
    geom_text(aes(label= round(value,2)), vjust=-2.5) + theme_classic()
}

# Plot number of perfect protein/gene hits
plot_PH <- function(summary_dataframe){
  # The fist colum is the number of genes, the 10th colum is the number of 
  # perfect hits
  summary_dataframe <- summary_dataframe[,c(1,10)]
  identity <- melt(summary_dataframe, id=c("N_genes"))
  ggplot(identity, aes(x=as.factor(N_genes), y=value))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ylab("Number of perfect hits") +
    ggtitle("Protein level") +
    geom_text(aes(label= value), vjust=-0.5) + theme_classic()
}


# Wrapper fuction to make and save all the plots
# The arguments are the summary dataframe produce by get_stats_WTC11.sbatch
plot_all <- function(summary_dataframe, pname){
  p <- plot_nt(summary_dataframe)
  ggsave(paste0(pname,"_nt.png"), width = 10, height = 5)
  p <- plot_exon(summary_dataframe)
  ggsave(paste0(pname,"_exon.png"), width = 10, height = 5)
  p <- plot_gene(summary_dataframe)
  ggsave(paste0(pname,"_gene.png"), width = 10, height = 5)
  p <- plot_identity(summary_dataframe)
  ggsave(paste0(pname,"_identity.png"), width = 10, height = 5)
  p <- plot_PH(summary_dataframe)
  ggsave(paste0(pname,"_PH.png"), width = 10, height = 5)
}

# Heatmaps

# Auxiliary function to sort the results data frame and get the harmonic mean at
# a specific level
sort_hm <- function(summary_df, level){
  summary_df <- summary_df[order(summary_df$N_genes),]
  if (level == "nt"){
    i <- 2
    j <- 3
  }
  if (level == "exon"){
    i <- 4
    j <- 5
  }
  if (level == "gene"){
    i <- 6
    j <- 7
  }
  if (level == "protein_identity"){
    i <- 9
    return(summary_df[,i])
  }
  if (level == "protein_PH"){
    i <- 10
    return(summary_df[,i])
  }
  harmonic_mean(summary_df[,i], summary_df[,j])
} 

# Functions to generate heatmaps of the F-score at nt, exon and gene level of
# all the possible lengths of the flanking region and all the number of genes
# in the training set
# Args:
  # results_df: list with the summary dataframes for all the models that are
  # going to be compared
  # level: nt, exon or gene
generate_heatmap <- function(results_df, level){
  m <- sapply(results_df, sort_hm, level=level)
  row.names(m) <- sort(results_df[[1]]$N_genes)
  m <- m[,order(as.integer(colnames(m)))]
  heatmap(t(m),Colv = NA, Rowv = NA, scale = "none", 
               xlab="Number of genes", ylab="Length of the flanking region", 
               main=paste(level, "level"), cexRow=1.2)
}

# Function to generate heatmap using ggplot instead of R base
generate_heatmap_gg <- function(results_df,level){
  heatmap_data <- list()
  for (i in 1:length(results_df)){
    if (level == "nt"){
      sn <- 2
      pr <- 3
      tmp <- results_df[[i]][,c(1,sn,pr)]
      tmp$f_score <- harmonic_mean(tmp[,2], tmp[,3])
    }
    if (level == "exon"){
      sn <- 4
      pr <- 5
      tmp <- results_df[[i]][,c(1,sn,pr)]
      tmp$f_score <- harmonic_mean(tmp[,2], tmp[,3])
    }
    if (level == "gene"){
      sn <- 6
      pr <- 7
      tmp <- results_df[[i]][,c(1,sn,pr)]
      tmp$f_score <- harmonic_mean(tmp[,2], tmp[,3])
    }
    if (level == "protein_identity"){
      id <- 9
      tmp <- results_df[[i]][,c(1,id)]
      names(tmp) <- c("N_genes", "f_score")
    }
    if (level == "protein_PH"){
      ph <- 10
      tmp <- results_df[[i]][,c(1,ph)]
      names(tmp) <- c("N_genes", "f_score")
    }
    tmp$fr <- names(results_df)[i]
    heatmap_data[[i]] <- tmp
  }
  
  heatmap_df <- do.call(rbind,heatmap_data)
  heatmap_df$fr <- factor(heatmap_df$fr, 
                            levels = unique(mixedsort(heatmap_df$fr)))
  legend_title <- "F-score"
  if (grepl("protein", level)){
    legend_title <- "Perfect hits"
    if (grepl("identity", level)){
      legend_title <- "Median identity %"
    }
    level <- "Protein"
  }
  p <- ggplot(heatmap_df, aes(as.factor(N_genes), fr, fill= f_score)) + 
    geom_tile() +
    scale_fill_viridis(discrete=FALSE) +
    xlab("Number of genes of the training set") +
    ylab("Length of the flanking region") +
    ggtitle(paste(level, "level")) + 
    labs(fill=legend_title) +
    theme(plot.title = element_text(hjust = 0.5))
  p
}

# Functions to find the best model at nt, exon, gene and protein level. The model
# with the highest F-score is considered the best model

# Max Harmonic mean nt
max_hm_nt <- function(summary_dataframe, fr){
  summary_dataframe <- summary_dataframe[,c(1,2,3)]
  # Get the harmonic mean at nt level
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Select the model with the highest F-score
  sel <- which(summary_dataframe$f1 == max(summary_dataframe$f1))
  sel_df <- summary_dataframe[sel[1],]
  sel_df$FR <- fr
  sel_df
}

# Max Harmonic mean exon
max_hm_exon <- function(summary_dataframe, fr){
  # Get the harmonic mean at exon level
  summary_dataframe <- summary_dataframe[,c(1,4,5)]
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Select the model with the hisghest harmonic mean
  sel <- which(summary_dataframe$f1 == max(summary_dataframe$f1))
  sel_df <- summary_dataframe[sel[1],]
  sel_df$FR <- fr
  sel_df
}

# Max Harmonic mean gene
max_hm_gene <- function(summary_dataframe, fr){
  # Get the harmonic mean at gene level
  summary_dataframe <- summary_dataframe[,c(1,6,7)]
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  # Select the model with the hisghest harmonic mean
  sel <- which(summary_dataframe$f1 == max(summary_dataframe$f1))
  sel_df <- summary_dataframe[sel[1],]
  sel_df$FR <- fr
  sel_df
}

# Max protein score
# The F-score at protein level is the same that at gene level. Instead of the 
# F-score a protein score is calculated based on the median identity %, the
# number of perfect hits and the number of FP. TO DO: improve this metric
max_protein_score <- function(summary_dataframe, fr){
  # Number of genes, identity %, perfect hits and FP
  summary_dataframe <- summary_dataframe[,c(1,9,10,11)]
  # Score calclation
  summary_dataframe$f1 <- summary_dataframe[,2]*summary_dataframe[,3] - summary_dataframe[,4]
  sel <- which(summary_dataframe$f1 == max(summary_dataframe$f1))
  sel_df <- summary_dataframe[sel,c(1,2,3)]
  sel_df$FR <- fr
  sel_df
}

# Main
# The first argument should be the directory with all the summary files for a 
# given technology
colores <- RColorConesa::colorConesa(8)
args = commandArgs(trailingOnly=TRUE)
setwd(args[1])
mode <- args[2]
#setwd("/home/alejandro/Escritorio/TFM/WTC11/WTC11_AUGUSTUS_newPB/BUSCO")
# Read the summary dataframes produce by the get_stats_WTC11.sabtch script
results <- list.files(pattern = ".tsv")
# Create a list to store the summary dataframes
results_df <- list()
# Create list to store the best model for each length of the flanking region at
# nt, exon, gene and protein level
max_nt <- list()
max_exon <- list()
max_gene <- list()
max_protein <- list()
i <- 1
# Read the results
for (result in results){
  print(result)
  # Get the name of the result. This name includes the technology or method used
  # to train the models and the length of the flanking region
  name <- unlist(strsplit(result,"[.]"))[1]
  # get the legth of the flanking region
  if (mode == "ab_initio"){
    fr <- as.character(parse_number(name))
  }
  else{
    fr <- name
  }
  # Load the summary table as a dataframe into a list
  results_df[[fr]] <- read.delim(result)
  # Get all the plots for each lenght of the FR
  plot_all(results_df[[fr]], name)
  max_nt[[result]] <- max_hm_nt(results_df[[fr]], name)
  max_exon[[result]] <- max_hm_exon(results_df[[fr]], name)
  max_gene[[result]] <- max_hm_gene(results_df[[fr]], name)
  max_protein[[result]] <- max_protein_score(results_df[[fr]], name)
  i = i + 1
}

# Generate heatmaps of the F-score at nt, exon and protein level to get and
# overview of all the results for a paticular technology/strategy
for (level in c("nt", "exon", "gene", "protein_PH", "protein_identity")){
  png(paste0(level, "_", "heatmap.png"))
  generate_heatmap(results_df, level)
  dev.off()
  p <- generate_heatmap_gg(results_df, level)
  ggsave(paste0(level, "_", "gg_heatmap.png"))
}

# Get the best model (number of genes in the training set) for each length of
# the flanking region at nt, exon, gene and protein level
max_nt <- do.call(rbind, max_nt)
max_nt$fr_subset <- paste(max_nt$FR, max_nt$N_genes, sep = "_")
max_nt <- max_nt[,c(2,3,4,6)]
max_exon <- do.call(rbind, max_exon)
max_exon$fr_subset <- paste(max_exon$FR, max_exon$N_genes, sep = "_")
max_exon <- max_exon[,c(2,3,4,6)]
max_gene <- do.call(rbind, max_gene)
max_gene$fr_subset <- paste(max_gene$FR, max_gene$N_genes, sep = "_")
max_gene <- max_gene[,c(2,3,4,6)]
max_protein <- do.call(rbind, max_protein)
max_protein$fr_subset <- paste(max_protein$FR, max_protein$N_genes, sep = "_")
max_protein <- max_protein[,c(2,3,5)]

# Get the number of models
n_models <- length(results)
# Colors 
colores <- RColorConesa::colorConesa(n_models)

# Nt level
# Reorder the dataframe to plot the results
max_nt_melt <- melt(max_nt, "fr_subset")
max_nt_melt$fr_subset <- factor(max_nt_melt$fr_subset, 
                                levels = unique(mixedsort(max_nt_melt$fr_subset)))

p <- ggplot(max_nt_melt, aes(x=variable, y=value, fill=fr_subset))+
  geom_bar(stat="identity", position=position_dodge()) +
  ylim(c(0,100)) +
  scale_fill_manual(values=colores[1:n_models])
ggsave("best_nt.png", height = 5, width = 9)

# Exon level
max_exon_melt <- melt(max_exon, "fr_subset")
max_exon_melt$fr_subset <- factor(max_exon_melt$fr_subset, 
                                  levels = unique(mixedsort(max_exon_melt$fr_subset)))
p <- ggplot(max_exon_melt, aes(x=variable, y=value, fill=fr_subset))+
  geom_bar(stat="identity", position=position_dodge()) +
  ylim(c(0,100)) +
  scale_fill_manual(values=colores[1:n_models])
ggsave("best_exon.png", height = 5, width = 9)

# Gene level
max_gene_melt <- melt(max_gene, "fr_subset")
max_gene_melt$fr_subset <- factor(max_gene_melt$fr_subset, 
                                  levels = unique(mixedsort(max_gene_melt$fr_subset)))
p <- ggplot(max_gene_melt, aes(x=variable, y=value, fill=fr_subset))+
  geom_bar(stat="identity", position=position_dodge()) +
  ylim(c(0,100)) +
  scale_fill_manual(values=colores[1:n_models])
ggsave("best_gene.png", height = 5, width = 9)

# Protein level
max_protein_melt <- melt(max_protein, "fr_subset")
max_protein_melt$fr_subset <- factor(max_protein_melt$fr_subset, 
                                     levels = unique(mixedsort(max_protein_melt$fr_subset)))
p <- ggplot(max_protein_melt, aes(x=variable, y=value, fill=fr_subset))+
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_manual(values=colores[1:n_models])
ggsave("best_protein.png", height = 5, width = 9)

# Select the best model and save the stats
# name <- tail(unlist(strsplit(getwd(),"/")),1)
name <- unlist(strsplit(name, "_"))[2]
# The best model is the model that perfomed better at gene level (highest F-score)
# at gene level
sel <- which(max_gene$f1 == max(max_gene$f1))
# Get the FR size
model <- rownames(max_gene)[sel]
# Get the number of genes used to train the model
size <- tail(unlist(strsplit(max_gene$fr_subset[sel], "_")),1)
# Read the model stats an select the appropiate row based on the number of genes
best <- read.delim(model)
best <- best[best$N_genes == size,]
# Add new columns: the tehcnology/strategy used and the length of the fr
best$model <- name
best$fr <- head(unlist(strsplit(model, "_")),1)
write.table(best, paste0(paste("best", name, sep = "_"), ".tsv"), 
            row.names = F, quote = F, sep = "\t")
