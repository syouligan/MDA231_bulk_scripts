#!/bin/bash

## Quantify with RSEM with encode parameters
#######

# Number of cores
ncores=20

# Experimental info (update for single or paired reads, and readlength). Set paired to "yes" if appropriate. NOTE: reads are assumed to be stranded.
paired="no"
readLength=40
project="MDA231_bulk_chrcha"
genome="GRCh38"

homedir="/share/ScratchGeneral/scoyou/sarah_projects"
data="STAR"
tool="RSEM"
results="project_results"
QCDir="logs"
inFileExt=".Aligned.toTranscriptome.out.bam"

genomeDir="/share/ClusterShare/biodata/contrib/scoyou"
species="genomes/human"
RSEMDir=$genomeDir/$species/$genome/$tool

# Path for log files
logDir=$homedir/$project/$QCDir
mkdir -p $logDir
echo "logDir $logDir"

# Path to folder containing sample folders
sample_Path=$homedir/$project/$results/$data
echo "sample_Path "$sample_Path

# Make an array containing names of directories containing samples
sample_arr=( $(ls $sample_Path) )
echo "# in samples array ${#sample_arr[@]}"
echo "names in samples array ${sample_arr[@]}"

# Submit command for each sample in array
for sample in ${sample_arr[@]}; do

# Runs loop for only the first sample in array (used for development)
# for sample in ${sample_arr[0]}; do

# Define input directory, define and make output and log directories
inPath=$sample_Path/$sample
echo "inPath $inPath"

outDir=$homedir/$project/$results/$tool/$sample
mkdir -p $outDir
echo "outDir $outDir"

# Define input files
inFile1=$inPath/*$inFileExt
echo "inFile1 $inFile1"

# Command to be executed
CommandPE="rsem-calculate-expression --bam $inFile1 \
--estimate-rspd \
--no-bam-output \
--seed 12345 \
--num-threads $ncores \
--paired-end \
--forward-prob 0 \
$RSEMDir \
$outDir"

CommandSE="rsem-calculate-expression --bam  $inFile1 \
--estimate-rspd \
--no-bam-output \
--seed 12345 \
--num-threads $ncores \
--forward-prob 0 \
$RSEMDir \
$outDir"

# Submit to queue
if [ $paired = "yes" ]
then
echo "CommandPE "$CommandPE
# $CommandPE
qsub -P OsteoporosisandTranslationalResearch -N $tool$sample -b y -hold_jid $data$sample -wd $logDir -j y -R y -l mem_requested=8G -pe smp $ncores -V -m bea -M s.youlten@garvan.org.au $CommandPE
else
  echo "CommandSE "$CommandSE
# $CommandSE
qsub -P OsteoporosisandTranslationalResearch -N $tool$sample -b y -hold_jid $data$sample -wd $logDir -j y -R y -l mem_requested=8G -pe smp $ncores -V -m bea -M s.youlten@garvan.org.au $CommandSE
fi

done