### extract target sequences from a multifasta by name
# RobSiani

# load libraries
pacman::p_load(Biostrings, stringr, seqinr, tidyverse)

## you can easily select which sequences you need using "CTRL+F" or grep if you know how to use it. eg. grep "16S" *.fasta >> target.txt
# load a table with the name of the sequences (one seq per line)
target = read.table("~/Desktop/A_radicis/promoters_search/blastOutput_luxBoxes_090621.txt",
                    header = F,
                    stringsAsFactors = T,
                    sep = ",")

# extract the unique names
target = unique(target$V2)

## check the pot you left on the stove

# load multifasta
multifasta = read.fasta("~/Desktop/A_radicis/promoters_search/m9_upstream.fasta",
                 seqtype = "DNA",
                 as.string = T,
                 whole.header = T,
                 strip.desc = F)

# extract sequences

matches = grep(
  paste(target, collapse = "|"),
  names(multifasta))

results = multifasta[matches]

# check that you actually extracted something
head(results)

# write in a new file
write.fasta(sequences = results, names = names(results), nbchar = 80, file.out = "new_matches_090621.fna")

## enjoy!
