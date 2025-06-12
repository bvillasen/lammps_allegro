#!/bin/bash

LOCAL_RANK=${SLURM_LOCALID}
GLOBAL_RANK=${SLURM_PROCID}
N_RANKS_GLOBAL=${SLURM_NTASKS}
N_RANKS_LOCAL=${SLURM_TASKS_PER_NODE}


export ROCR_VISIBLE_DEVICES=4,5,2,3,6,7,0,1
echo "rank: ${GLOBAL_RANK} ROCR_VISIBLE_DEVICES: ${ROCR_VISIBLE_DEVICES}"

# export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
# echo "rank: ${GLOBAL_RANK} HIP_VISIBLE_DEVICES: ${HIP_VISIBLE_DEVICES}"

CMD="${LAMMPS_ALLEGRO_EXEC} -k on g 8 -sf kk -pk kokkos newton on neigh half -in demo.in"
# CMD="${LAMMPS_ALLEGRO_EXEC} -k on g 1 -sf kk -pk kokkos newton on neigh half -in demo.in"
echo "CMD: ${CMD}"

eval ${CMD} 