# Script para filtrar un archivo classification de salida de SQANTI3
# utilizando información de blast

# librerias
library(dplyr)
library(ggplot2)

# Argumentos
args = commandArgs(trailingOnly=TRUE)
sq_dir = args[1]  # Directorio de los output de sqanti3
sq_prefix = args[2] # prefijo de los outputs de sqanti3
out_dir = args[3]  # Directorio de salida para el clasification filtrado
blast_file = args[4] # Output de blast
tecnologia = args[5] # tecnologia de secuenciacion empleada

# Lectura del classification y del output de blast
class_path = paste(sq_dir, paste0(sq_prefix, "_classification.txt"), sep = "/")
classification = read.delim(class_path)
blast <- read.delim(blast_file, header = F)

# Determinacion de los puntos de corte en base a la tecnologia
th <- 0.75 # Si la tecnologia es ONT o mix se utiliza el tercer cuantil

#Si la tecnologia es PacBio se utiliza la mediana´
if (tecnologia == "PB"){
  th <- 0.5
}

# Filtrado general del classification
filtered_clasification <- classification %>% 
  filter(exons > 1) %>% # Quitar los monoexones
  filter(coding == "coding") %>% # Dejar solo los codificantes
  filter(predicted_NMD == "FALSE") %>%  # Que no tengan señales de NMD
  filter(perc_A_downstream_TTS < 60) %>% # Que no sean candidatos de tener intrapriming
  filter(all_canonical == "canonical") %>% # Que todas las SJ sean canónicas
  filter(CDS_length > 300) %>% # Longitud del CDS > 300 (100 aa)

# Filtrado en funcion de la cobertura de las SJ del classification   
filtered_clasification <- filtered_clasification %>%  
  filter(min_cov > quantile(filtered_clasification$min_cov, th)) %>% # Cobertura mínima de las SJ
  filter(RTS_stage == "FALSE") %>% # Que no sea candidato de haber sufrdio RTS
  filter((ORF_length + 1)*3 == CDS_length) # Que tenga codón de STOP

# Preparacion del fichero de salida de blast para el filtrado
blast$qcoverage <- blast$V13/blast$V14 # Cobertura del hit de blast
blast$seq_hit <- paste(blast$V1, blast$V2, sep = "_")
sel <- match(unique(blast$seq_hit), blast$seq_hit)
blast <- blast[sel,]
blast_top3h_summary <- blast %>% 
  group_by(V1) %>% 
  summarise(n_hit = n(), 
            qcover = max(qcoverage), 
            identidad = max(V3), min(V11)) 
# Reducir el numero de hits a tres en caso de empate
blast_top3h_summary$n_hit <- ifelse(blast_top3h_summary$n_hit > 3, 
                                    3, blast_top3h_summary$n_hit)

# Plotear la cobertura de la query en funcion del numero de hits
blast_plot <- ggplot(blast_top3h_summary, aes(x=qcover, group=as.factor(n_hit), fill=as.factor(n_hit)))+
  geom_density(alpha = 0.5) + 
  geom_vline(xintercept =  0.85, linetype = "longdash") + 
  xlim(c(0,1.5)) +
  guides(fill=guide_legend(title="Nº of blastp hits")) + 
  xlab("Query coverage")

# Mantener aquellos hits de blast con una cobertura de la query superior al 85%
blast_85 <- blast_top3h_summary %>% 
  filter(qcover > 0.85) %>% 
  filter(qcover < 1.2)

# Si la tecnologia es PB se filtra solo en funcion de los hits de blast, si la
# tecnologia es ONT o ONT + PB tambien se filtra en funcion de el numero de reads
if (tecnologia == "PB"){
  filtered_clasification <- filtered_classification %>% 
    filter(isoform %in% blast_85$V1)
} else{
  filtered_clasification <- filtered_classification %>% 
    filter(isoform %in% blast_85$V1) %>% 
    filter(FL > quantile(filtered_clasification$FL, th))
}

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
ggsave(paste(out_dir,"blast.png", sep = "/"), blast_plot, width = 7, height = 5)
