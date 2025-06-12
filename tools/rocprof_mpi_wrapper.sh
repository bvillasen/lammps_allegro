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

# rocprof="${ROCM_PATH}/bin/rocprof" //stalled in lockhart
# rocprof="/opt/COE_modules/rocm/rocm-6.0.0/bin/rocprof" //stalled in lockhart
# rocprof="/opt/COE_modules/rocm/rocm-5.6.0/bin/rocprof" //stalled in lockhart

# rocprof="/opt/COE_modules/rocm/rocm-6.1.1/bin/rocprof" 

# Worked on Thera and Lockhart for roctx
rocprof="${ROCM_PATH}/bin/rocprof"

# Worked for stats on Thera  when using only one rank
# rocprof="/opt/rocm-6.1.1/bin/rocprof"

#  /opt/rocm-6.2.4/libexec/rocprofiler/merge_traces.sh

pid="$$"
outdir="${outdir}/rank_${MPI_RANK}"
outfile="${name}.csv"

# ROCPROF_RANKS="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
ROCPROF_RANKS="0"

if exists_in_list "$ROCPROF_RANKS" " " ${SLURM_PROCID}; then
  echo "rank ${SLURM_PROCID} running rocprof: ${rocprof} -d ${outdir} -o ${outdir}/${outfile} ${@:3}"
  ${rocprof} -d ${outdir} -o ${outdir}/${outfile} "${@:3}"
else
  echo "rank ${SLURM_PROCID} NOT running rocprof: ${LAMMPS_ALLEGRO_CMD}"
  ${LAMMPS_ALLEGRO_CMD}
fi

# echo "rank ${SLURM_PROCID} running rocprof: ${rocprof} -d ${outdir} -o ${outdir}/${outfile} ${@:3}"
# ${rocprof} -d ${outdir} -o ${outdir}/${outfile} "${@:3}"


# echo "deleting rpl_data: ${outdir}/rpl_data"
# rm -r ${outdir}/rpl_data*

# ${rocprof} -d ${outdir} -o ${outdir}/${outfile} "${@:3}"

