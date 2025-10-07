#!/bin/bash
#SBATCH -J cs_wrf_extract
#SBATCH -N 1
#SBATCH --partition=skylake_0384
#SBATCH --qos=p71391_0384
#SBATCH --account=p71391
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-user=christian.schmidt@boku.ac.at
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err


# Use srun instead of mpirun

echo "Julia version:"
julia --version
echo "Number of threads:"
julia --threads=auto -e 'println(Threads.nthreads())'

julia --threads=auto -e 'using Pkg; Pkg.activate("/home/fs71391/cschmidt/git/AirChem.jl"); Pkg.precompile()'


echo "Running the script"

julia --threads=auto extract_test.jl
