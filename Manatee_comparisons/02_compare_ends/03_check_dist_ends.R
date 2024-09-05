#!/usr/bin/env Rscript
library(dplyr)

args <-  commandArgs(trailingOnly=TRUE)
# Read output
df <-  read.table(args[1], header=F, col.names = c("id", "diff_start", "diff_end", "diff_length"))


# Get maximal end difference
df$max_end_diff <- apply(df[, 2:3], 1, max)
df <- df %>% 
  arrange(id, max_end_diff) %>%
  distinct(id, .keep_all = TRUE)
  
out <- paste(dirname(args[1]), "unique_diff_ends.tsv", sep = "/")
write.table(df, out, quote = F, sep = "\t", row.names = F)