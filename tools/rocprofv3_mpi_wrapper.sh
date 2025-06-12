#!/bin/bash
set -euo pipefail
# depends on ROCM_PATH being set outside; input arguments are the output directory & the name
outdir="$1"
name="$2"


function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    LIST_WHITESPACES=`echo $LIST | tr "$DELIMITER" " "`
    for x in $LIST_WHITESPACES; do
        if [ "$x" = "$VALUE" ]; then
            return 0
        fi
    done
    return 1
}

if [[ -n ${OMPI_COMM_WORLD_RANK+z} ]]; then
# mpich
export MPI_RANK=${OMPI_COMM_WORLD_RANK}
elif [[ -n ${MV2_COMM_WORLD_RANK+z} ]]; then
# ompi
export MPI_RANK=${MV2_COMM_WORLD_RANK}
elif [[ -n ${SLURM_PROCID+z} ]]; then
export MPI_RANK=${SLURM_PROCID}
else
echo "Unknown MPI layer detected! Must use OpenMPI, MVAPICH, or SLURM"
exit 1
fi
 
rocprof="${ROCM_PATH}/bin/rocprofv3"
# rocprof="/opt/rocm-6.3.1/bin/rocprofv3"

pid="$$"
outdir="${outdir}/rank_${MPI_RANK}"
outfile="${name}"

ROCPROF_RANKS="0 1 2 3 4 5 6 7"
# ROCPROF_RANKS="0"

if exists_in_list "$ROCPROF_RANKS" " " ${SLURM_PROCID}; then
  echo "rank ${SLURM_PROCID} running rocprofv3: ${rocprof} -d ${outdir} -o ${outfile} ${@:3}"
  # ${rocprof} -d ${outdir} -o ${outdir}/${outfile} "${@:3}"
  ${rocprof} -d ${outdir} -o ${outfile} "${@:3}"
else
  echo "rank ${SLURM_PROCID} NOT running rocprofv3: ${LAMMPS_ALLEGRO_CMD}"
  ${LAMMPS_ALLEGRO_CMD}
fi

# ${rocprof} -d ${outdir} -o ${outdir}/${outfile} "${@:3}"

