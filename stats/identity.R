# Main
# The first arg is the working directory
# The second arg is the name for the plots
args = commandArgs(trailingOnly=TRUE)
setwd(args[1])
identity_files <- list.files(pattern = ".identity")
l_identity <- list()
for (i in identity_files){
  model_name <- unlist(strsplit(i, "\\."))[1]
  tmp <- read.delim(i, header = F)
  tmp$model <- model_name
  l_identity[[model_name]] <- tmp
}
saveRDS(l_identity, file = "identity.RData")