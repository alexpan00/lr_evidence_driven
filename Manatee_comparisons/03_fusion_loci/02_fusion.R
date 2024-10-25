library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(RColorConesa)
mytheme <- theme(plot.title = element_text(size = 38, face = "bold",hjust = -0.07), plot.subtitle = element_text(size = 10,hjust = 0.5), legend.text = element_text(size=28),legend.title = element_text(size=30),axis.title.x = element_text(size=30, margin = margin(t = 10, r = 0, b = 0, l = 0)), axis.title.y = element_text(size=30,  margin = margin(t = 0, r = 25, b = 0, l = 0)), axis.text.x = element_text(size=24), axis.text.y = element_text(size=24), legend.key.size = unit(3,"line")) +
  theme(strip.text = element_text(size = 30)) + theme(plot.margin = unit(c(0.6,0.6,.6,.6), "cm"))


# load the classification from running hints vs final annotation
class <- read.delim("manatee_gge_hints_busco_sqanti_classification.txt")

# assgine fusion isoform to loci baseed of gffread result
t2l <- read.delim("transcipt_loci.tsv", header = F)
colnames(t2l) <- c("isoform", "loci")
class <- merge(class, t2l)

# Keep those loci with at leat one fusion even (a hint that overlaps 2 or more 
# genes in the final annotation)
fusion_loc <- class[grepl("fusion", class$structural_category), "loci"]
class_fusion <- class[class$loc %in% fusion_loc,]

# For each fusion loci find the distribution of sc. Count the non-fusion hints that
# overlap a gene in the final annotation
category_count <- class_fusion %>% 
  group_by(loci, structural_category) %>% 
  summarise(n_iso_cat =n()) %>% 
  pivot_wider(names_from = structural_category, values_from = n_iso_cat) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(no_fusion=sum(c_across(!starts_with(c("fusion", "intergenic"))&where(is.numeric)), na.rm=T)) %>% 
  ungroup()
category_count[is.na(category_count)] <- 0

# if no_fusion > it means that there is evidence to support the  presence of 2 
# non-overlapping genes, otherwise AUGUSTUS ignored/broke the experimental evidence
alternative_evidence <- as.data.frame(category_count[, c("loci","fusion", "no_fusion")] > 0)
alternative_evidence$presence <- rowSums(alternative_evidence[,2:3])
alternative_evidence$presence <- factor(alternative_evidence$presence, levels = c(1,2), labels = c("No", "Yes"))
ggplot(alternative_evidence, aes(x=presence, fill= presence)) +
  geom_bar() + theme_classic() + mytheme + 
  ylab("Number of loci") + 
  xlab("Presence of alternative evidence") +
  scale_fill_conesa() +
  theme(legend.position = "none") +
  ylim(c(0,40))


category_count
write.table(category_count$loci, file = "fusion_loci.txt", quote = F, row.names = F, col.names = F)