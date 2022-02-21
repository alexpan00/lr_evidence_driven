# Script para filtrar un archivo classification de salida de SQANTI3

# librerias
library(dplyr)
library(ggplot2)

# Argumentos
args = commandArgs(trailingOnly=TRUE)
sq_dir = args[1]  # Directorio de los output de sqanti3
sq_prefix = args[2] # prefijo de lso output de sqanti3
out_dir = args[3]  # DIrectorio de salida para el clasification filtrado

# Lectura del classification
class_path = paste(sq_dir, paste0(sq_prefix, "_classification.txt"), sep = "/")
classification = read.delim(class_path)

# Filtrado del classification
filtered_clasification <- class %>% 
  filter(exons > 1) %>% # Quitar los monoexones
  filter(coding == "coding") %>% # Dejar solo los codificantes
  filter(predicted_NMD == "FALSE") %>%  # Que no tengan señales de NMD
  filter(perc_A_downstream_TTS < 60) %>% # Que no sean candidatos de tener intrapriming
  filter(all_canonical == "canonical") %>% # Que todas las SJ sean canónicas
  filter(CDS_length > 300) %>% # Longitud del CDS > 300 (100 aa)
  filter(min_cov > 10) %>% # Que la cobertura mínima de las SJ sea 10 reads
  filter(RTS_stage == "FALSE") %>% # Que no sea candidato de haber sufrdio RTS
  filter((ORF_length + 1)*3 == CDS_length) # Que tenga codón de STOP

# Plot del número de exones antes y después del filtrado
p_exon_pre <- ggplot(classification, aes(exons))+geom_histogram(binwidth=1) + 
  geom_histogram(binwidth=1,fill="#69b3a2", color="#e9ecef", alpha=0.9) + 
  xlab("Number of exons") + ylab("Number of transcripts") + geom_vline(xintercept = median(classification$exons))
p_exon_post <-  ggplot(filtered_clasification, aes(exons))+geom_histogram(binwidth=1) + 
  geom_histogram(binwidth=1,fill="#69b3a2", color="#e9ecef", alpha=0.9) + 
  xlab("Number of exons") + ylab("Number of transcripts") + geom_vline(xintercept = median(filtered_clasification$exons))

# Escritura del classification y de los plots
class_out_path = paste(out_dir, paste0("filtered_",sq_prefix, "_classification.txt"), sep = "/")
write.table(filtered_clasification, file = class_out_path,
            row.names = F, quote = F, sep = "\t")

ggsave(paste(out_dir,"exon_pre.png", sep = "/"), p_exon_pre, width = 7, height = 5)
ggsave(paste(out_dir,"exon_post.png", sep = "/"), p_exon_post, width = 7, height = 5)