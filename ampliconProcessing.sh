16S rRNA-gene Amplicon Processing
adapted by R.Siani

## count reads
for i in *R1_001.fastq.gz; do zgrep "@M02975" $i | wc -l >>  read_counts.txt; done && ls *R1_001.fastq.gz > sample_names.txt

## Validate mapping file in qiime1 and check mapping_output for errors
validate_mapping_file.py -m map.txt -o mapping_output

## Trim adapters and merge reads
ls *R1_001* > R1.list && ls *R2_001* > R2.list && mkdir Adapterremoval
parallel --xapply "qsub -cwd /project/genomics/Gisle/Scripts/qsub_adapterremoval.rb -f {1} -r {2} --adapter1 AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG --adapter2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -o Adapterremoval" :::: R1.list :::: R2.list
cd Adapterremoval && mkdir test && mv *pair* test/ && cd test && rename R1_001.fastq.gz.pair1.truncated R1_001.fastq * && rename R1_001.fastq.gz.pair2.truncated R2_001.fastq * && gzip *fastq

## Import sequences in a qiime artifact and summarize the data to see sequences/sample
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path . \
--output-path demux-paired-end.qza \
--input-format CasavaOneEightSingleLanePerSampleDirFmt && qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux.qzv

## Denoising with DADA2. Select parameters from demux qzv.
qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--o-table table-dada2 \
--o-representative-sequences rep-seqs-dada2 \
--p-trim-left-f 10 \
--p-trim-left-r 10 \
--p-trunc-len-f 250 \
--p-trunc-len-r 200 \
--p-max-ee-r 3 \
--p-max-ee-f 3 \
--o-denoising-stats stats-dada2.qza \
--verbose \
--p-n-threads 0

## Import reference reads and taxonomical infos
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path ../../../silvaJenny/silva_138.1.fna \
--output-path silva_138.1.qza && qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path consensus_taxonomy_7_levels.txt \
--output-path cons_tax_slv_138.1.qza

## Select fragments with your primer pair
qiime feature-classifier extract-reads \
--i-sequences silva_132_99_16S.qza \
--p-f-primer GTGYCAGCMGCCGCGGTAA \
--p-r-primer GGACTACNVGGGTWTCTAAT \
--o-reads ref-seqs_silva132_martha.qza

## Train the classifier with taxonomic weights from https://github.com/BenKaehler/readytowear/blob/master/inventory.tsv
qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads ref-seqs.qza \
--i-reference-taxonomy cons_tax.qza \
--i-class weight \
--o-classifier classifier_martha.qza \
--p-trunc-len 120 \
--p-min-length 100 \
--p-max-length 400 \
--verbose

## taxonomical assignment of your sequences
qiime feature-classifier classify-sklearn \
--i-classifier ../../../silvaJenny/classifier_silva132_335f-769r.qza \
--i-reads rep-seqs-dada2.qza \
--p-confidence 0.97 \
--o-classification taxonomy-dada2.qza \
--verbose
