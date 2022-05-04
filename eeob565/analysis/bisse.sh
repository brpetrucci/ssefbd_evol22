# load modules
module load gcc/7.3.0-xegsmw4
module load cmake/3.20.5-3ixnvxg
module load boost/1.70.0-miyqohf

# add rb to the path
export PATH=$PATH:/work/LAS/phylo-lab/petrucci/revbayes/projects/cmake

# go to the correct directory
cd /work/LAS/phylo-lab/petrucci/ssefbd_evol22/

# create a file to hole comb and rep definitions
touch aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev

# echo the definitions on it
printf "comb <- " > aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev
printf $1 >> aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev
printf "\nrep <- " >> aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev
printf $SLURM_ARRAY_TASK_ID >> aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev

# source it and the actual script
rb aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev eeob565/analysis/bisse.Rev

# remove file
rm aux/aux_${1}_${SLURM_ARRAY_TASK_ID}.Rev
