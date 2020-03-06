#!/bin/bash

## Align and quantify using STAR and RSEM with encode parameters
#######

# Number of cores
ncores=20

# Experimental info (update for single or paired reads, and readlength). NOTE: reads are assumed to be stranded.
paired="no"
readLength=40
project="MDA231_bulk_chrcha"

homedir="/share/ScratchGeneral/scoyou/sarah_projects"
data="fastp"
tool="STAR_RSEM"
results="project_results"
QCDir="logs"
inFileExt=".fastq.gz"

genomeDir="/share/ClusterShare/biodata/contrib/scoyou"
species="genomes/human"
genome="GRCh38"
STARDir=$genomeDir/$species/$genome/"STAR_"$readLength
RSEMDir=$genomeDir/$species/$genome/"RSEM_"$readLength

# Path for log files
logDir=$homedir/$project/$QCdir
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

# Output goes to current working directory
cd $homedir/$project/$results/$tool/$sample

# Define input files
inFile1=$inPath/$sample"_trimmed_R1.fastq.gz"
inFile2=$inPath/$sample"_trimmed_R2.fastq.gz"
echo "inFile1 $inFile1 inFile2 $inFile2"

# Command to be executed
CommandSE="/home/scoyou/sarah_projects/SCmets_chrcha/MDA231_bulk_scripts/STAR_RSEM.sh $inFile1 "" $STARDir $RSEMDir str_SE $ncores $ncores"
CommandPE="/home/scoyou/sarah_projects/SCmets_chrcha/MDA231_bulk_scripts/STAR_RSEM.sh $inFile1 $inFile2 $STARDir $RSEMDir str_PE $ncores $ncores"

# Submit to queue
if [ $paired = "yes" ]
then
echo "CommandPE "$CommandPE
# $CommandPE
qsub -P OsteoporosisandTranslationalResearch -N $tool$sample -b y -hold_jid 'fastp'$sample -wd $logDir -j y -R y -l mem_requested=8G -pe smp $ncores -V -m bea -M s.youlten@garvan.org.au $CommandPE
else
  echo "CommandSE "$CommandSE
# $CommandSE
qsub -P OsteoporosisandTranslationalResearch -N $tool$sample -b y -hold_jid 'fastp'$sample -wd $logDir -j y -R y -l mem_requested=8G -pe smp $ncores -V -m bea -M s.youlten@garvan.org.au $CommandSE
fi

done

# Returns to submission directory. Hacky but it works...
cd "/home/scoyou/sarah_projects/SCmets_chrcha/MDA231_bulk_scripts/"
