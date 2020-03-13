#!/bin/bash

## Make a RSEM genome reference
#######

# Number of cores
ncores=32

# Experimental info (update for genome)
tool="RSEM"
QCDir="logs"
species="genomes/human"
genome="GRCh38"
sequence="GRCh38.primary_assembly.genome.fa"
annotation="gencode.v33.primary_assembly.annotation.gtf"

# Make directory structure
homedir="/share/ClusterShare/biodata/contrib/scoyou"

inputDir=$homedir/$species/$genome
echo "inPath "$inputDir

outDir=$homedir/$species/$genome/$tool
mkdir -p $outDir
echo "outPath "$outDir

logDir=$outDir/$QCDir
mkdir -p $logDir
echo "logDir "$logDir

# Build star index for genome
rsemCommand="rsem-prepare-reference --gtf $inputDir/$annotation $inputDir/$sequence $outDir"
echo "rsemCommand "rsemCommand

# Submit to queue
qsub -P OsteoporosisandTranslationalResearch -N $tool$genome$i -b y -wd $logDir -j y -R y -l mem_requested=8G -pe smp $ncores -V -m bea -M s.youlten@garvan.org.au $rsemCommand

