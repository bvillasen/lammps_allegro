


lockhart='''#!/bin/bash
SBATCH_PARTITION
#SBATCH -J JOB_NAME
#SBATCH --time=N_HRS:N_MIN:00
#SBATCH --no-requeue
#SBATCH --nodes=N_NODES
#SBATCH --ntasks-per-node=N_TASK_PER_NODE
#SBATCH --gpus-per-node=N_GPU_PER_NODE
#SBATCH --cpus-per-task=N_CORES_PER_TASK
#SBATCH -D RUNDIR
#SBATCH -e RUNDIR/job_error.log
#SBATCH -o RUNDIR/job_output.log
#SBATCH --exclusive
SLURM_OPTIONS

echo "SLUM_NODES=$SLURM_NNODES  NODE_LIST:$SLURM_NODELIST"
echo "Starting SLURM job. $(date)"

SLURM_SCRIPT_CONTENT

echo "Finished SLURM job. $(date)"
'''

frontier='''#!/bin/bash
#SBATCH -J JOB_NAME
#SBATCH --time=N_HRS:N_MIN:00
#SBATCH --nodes=N_NODES
#SBATCH -D RUNDIR
#SBATCH -e RUNDIR/job_error.log
#SBATCH -o RUNDIR/job_output.log
#SBATCH --exclusive
SLURM_OPTIONS

echo "SLUM_NODES=$SLURM_NNODES  NODE_LIST:$SLURM_NODELIST"
echo "Starting SLURM job. $(date)"

SLURM_SCRIPT_CONTENT

echo "Finished SLURM job. $(date)"
'''

no_slurm='''#!/bin/bash

echo "Starting job. $(date)"

SLURM_SCRIPT_CONTENT

echo "Finished job. $(date)"
'''
