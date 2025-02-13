#!/bin/bash
#SBATCH -A hpc-prf-metdyn
#SBATCH -J Cysteine_lrbse
#SBATCH -p normal
#SBATCH -q express
#SBATCH -t 00:30:00
#SBATCH -N 2
#SBATCH -n 64
#SBATCH --cpus-per-task=4
#SBATCH --mem 200GB

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

CONFDIR=$SLURM_SUBMIT_DIR
DATADIR=$CONFDIR
RESULTSDIR=$CONFDIR/Results
SCRATCHDIR=/scratch/hpc-prf-metdyn/eprop2d9_Stepan/$SLURM_JOB_ID
CP2KDIR=/pc2/users/e/eprop2d9/group-storage/CP2K

# Create the scratch directory
if [ ! -d $SCRATCHDIR ]; then
	mkdir $SCRATCHDIR
fi

# Log relevant data
echo "Time : `date`; Job ID : $SLURM_JOB_ID; Scratchdir : $SCRATCHDIR" >> $CONFDIR/jobs_info.txt

# Copy relevant files to the scratchdir
cp $DATADIR/bse.inp $SCRATCHDIR
cp $DATADIR/aug-cc-pv* $SCRATCHDIR
cp $DATADIR/coord* $SCRATCHDIR
cp $DATADIR/*.wfn $SCRATCHDIR
cp $CP2KDIR/exe/local/cp2k.psmp $SCRATCHDIR

# Enter scratchdir
cd $SCRATCHDIR

# Load relevant packages
module load chem
module load CP2K

# Run the calculation
srun ./cp2k.psmp bse.inp > cp2k.out

# Copy data back to results
if [ ! -d $RESULTSDIR ]; then
	mkdir $RESULTSDIR
fi
rm cp2k.psmp
cp $SCRATCHDIR/* $RESULTSDIR
# If the last command was succesful, remove the scratchdir
cd ..
if [ $? -eq 0 ]; then
	rm -r $SCRATCHDIR
fi

# Succesfully exit
exit 0
