# Script to generate plots from the results of testing the model 

# Libraries
library(ggplot2)
library(RColorConesa)
library(reshape2)

# Colors 
colores <- RColorConesa::colorConesa(8)

# Functions
# Harmonic mean, calculate F-score
harmonic_mean <- function(sn, precision){
  2*(sn*precision)/(sn+precision)
}

# Plot at nucleotide level
plot_nt <- function(summary_dataframe){
  summary_dataframe <- summary_dataframe[,c(1,2,3)]
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  nt <- melt(summary_dataframe, id=c("N_genes"))
  ggplot(nt, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("Nucleotide level") +
    ylim(c(0,1)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), 
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}

# Plot at exon level
plot_exon <- function(summary_dataframe){
  summary_dataframe <- summary_dataframe[,c(1,4,5)]
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  exon <- melt(summary_dataframe, id=c("N_genes"))
  ggplot(exon, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("Exon level") +
    ylim(c(0,1)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), 
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}

# Plot at gene level
plot_gene <- function(summary_dataframe){
  summary_dataframe <- summary_dataframe[,c(1,6,7)]
  summary_dataframe$f1 <- harmonic_mean(summary_dataframe[,2], summary_dataframe[,3])
  gene <- melt(summary_dataframe, id=c("N_genes"))
  ggplot(gene, aes(x=as.factor(N_genes), y=value, fill= variable))+
    geom_bar(stat = "identity", position=position_dodge())+
    xlab("Number of genes of the training set") +
    ggtitle("gene level") +
    ylim(c(0,1)) +
    geom_text(aes(label=ifelse(variable == "f1", round(value,3), "")), 
              vjust=-2.5, size=4.5, hjust = +1,
              position = position_dodge(0.9)) +
    scale_fill_manual(values=colores[1:3],name = "Values", 
                      labels = c("Sensitivity", "Precision", "F1")) 
}

# Make and save the plots
plot_all <- function(summary_dataframe, pname){
  p <- plot_nt(summary_dataframe)
  ggsave(paste0(pname,"_nt.png"), width = 10, height = 5)
  p <- plot_exon(summary_dataframe)
  ggsave(paste0(pname,"_exon.png"), width = 10, height = 5)
  p <- plot_gene(summary_dataframe)
  ggsave(paste0(pname,"_gene.png"), width = 10, height = 5)
}

# Main
# The first arg is the working directory
# The second arg is the name for the plots
args = commandArgs(trailingOnly=TRUE)
setwd(args[1])
resultados <- read.delim("summary.tsv")
plot_all(resultados, args[2])