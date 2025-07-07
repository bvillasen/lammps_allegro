#!/bin/bash

LOCAL_RANK=${SLURM_LOCALID}
GLOBAL_RANK=${SLURM_PROCID}
N_RANKS_GLOBAL=${SLURM_NTASKS}
N_RANKS_LOCAL=${SLURM_TASKS_PER_NODE}


export ROCR_VISIBLE_DEVICES=4,5,2,3,6,7,0,1
echo "rank: ${GLOBAL_RANK} ROCR_VISIBLE_DEVICES: ${ROCR_VISIBLE_DEVICES}"

# export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
# echo "rank: ${GLOBAL_RANK} HIP_VISIBLE_DEVICES: ${HIP_VISIBLE_DEVICES}"

if [[ "${LAMMPS_ALLEGRO_SYSTEM}" == "frontier" ]]; then
  SRUN="srun"
  AFFINITY="-c 7 --gpus-per-node 8"
elif [[ "${LAMMPS_ALLEGRO_SYSTEM}" == "lockhart_mi250X" ]]; then
  SRUN="srun"
  AFFINITY="-c 8 --gpus-per-node 8"
elif [[ "${LAMMPS_ALLEGRO_SYSTEM}" == "thera_mi300x" ]]; then
  SRUN="/home/bvillase/util/openmpi/rocm6.4.1/install/ompi/bin/mpirun  " 
  AFFINITY="--mca pml ucx -x UCX_PROTO_ENABLE=n -x UCX_ROCM_COPY_LAT=2e-6 -x UCX_ROCM_IPC_MIN_ZCOPY=4096 "  
fi



if [[ "${PROFILER}" == "rocprof_stats" ]]; then
  rocprof_dir=${WORK_DIR}/stats
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprof_mpi_wrapper.sh $rocprof_dir results --stats --timestamp on --basenames on "
elif [[ "${PROFILER}" == "rocprof_hip-trace" ]]; then
  rocprof_dir=${WORK_DIR}/hip_trace
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprof_mpi_wrapper.sh $rocprof_dir results --hip-trace --roctx-trace --basenames on"
elif [[ "${PROFILER}" == "rocprof_sys-trace" ]]; then
  rocprof_dir=${WORK_DIR}/sys_trace
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprof_mpi_wrapper.sh $rocprof_dir results --sys-trace --roctx-trace --basenames on"
elif [[ "${PROFILER}" == "rocprof_counters" ]]; then
  rocprof_dir=${WORK_DIR}/counters
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprof_mpi_wrapper.sh $rocprof_dir results -i ${ROCPROF_COUNTERS_FILE} --basenames on"
elif [[ "${PROFILER}" == "rocprofv3_stats" ]]; then
  rocprof_dir=${WORK_DIR}/stats
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprofv3_mpi_wrapper.sh $rocprof_dir results --kernel-trace --stats --truncate-kernels --"
elif [[ "${PROFILER}" == "rocprofv3_counters" ]]; then
  rocprof_dir=${WORK_DIR}/counters
  mkdir ${rocprof_dir}
  PROFILER_CMD="${LAMMPS_ALLEGRO_ROOT}/tools/rocprofv3_mpi_wrapper.sh $rocprof_dir results -i ${ROCPROF_COUNTERS_FILE} --truncate-kernels --"      
else
  PROFILER_CMD=""
fi

export LAMMPS_ALLEGRO_CMD="${LAMMPS_ALLEGRO_EXEC} -k on g 8 -sf kk -pk kokkos newton on neigh half -in demo.in"

echo "PROFILER_CMD=${PROFILER_CMD}"
echo "LAMMPS_ALLEGRO_CMD=${LAMMPS_ALLEGRO_CMD}"

CMD="${SRUN} -n ${N_MPI} ${AFFINITY} ${PROFILER_CMD} ${LAMMPS_ALLEGRO_CMD}"
echo "CMD: ${CMD}"

eval ${CMD} 