#!/bin/bash
#SBATCH -J cs_wrf_extract
#SBATCH -N 1
#SBATCH --partition=skylake_0384
#SBATCH --qos=p71391_0384
#SBATCH --account=p71391
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-user=christian.schmidt@boku.ac.at



# Use srun instead of mpirun
julia --threads=auto wrf_extract_par_t.jl
