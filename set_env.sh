#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "Setting environment for system: ${GREEN}${SYSTEM} ${NC} "

if [ -z "${LAMMPS_ALLEGRO_ROOT}" ]; then
  CURRENT_DIR=$(pwd)
  if [[ "$CURRENT_DIR" == *"lammps_allegro"* ]]; then
    prefix=${CURRENT_DIR%%"lammps_allegro"*}
    index=$(( ${#prefix} ))
    export LAMMPS_ALLEGRO_ROOT="${CURRENT_DIR:0:index}lammps_allegro"
    echo -e "lammps_allegro path: ${GREEN}${LAMMPS_ALLEGRO_ROOT} ${NC} " 
  else
    echo -e "${RED}ERROR: lammps_allegro path couldn't be find ${NC} "
    echo -e "Set the path manually by setting: export LAMMPS_ALLEGRO_ROOT=<path to lammps_allegro directory> "
    return
  fi
else
  echo -e "lammps_allegro path: ${GREEN}${LAMMPS_ALLEGRO_ROOT} ${NC} "
fi


if [[ "${SYSTEM}" = "frontier" ]]; then
  module load PrgEnv-gnu
  module load cray-mpich
  module load craype-accel-amd-gfx90a
  module load rocm/6.3.1
  module load cmake
  module load cray-python
  export GPU_ARCH="gfx90a"
  export MPICH_GPU_SUPPORT_ENABLED=1

  export LAMMPS_ALLEGRO_MPICXX=$(which CC)
  export LAMMPS_ALLEGRO_CXX=${ROCM_PATH}/bin/hipcc

  export CUDA_HOME=${ROCM_PATH}
  export TORCHINDUCTOR_MAX_AUTOTUNE="1"
  export TORCHINDUCTOR_LAYOUT_OPTIMIZATION="1"
  export PYTORCH_MIOPEN_SUGGEST_NHWC="1"
  export TORCHINDUCTOR_CPP_WRAPPER="1"
  export TORCHINDUCTOR_FREEZING="1"

  export ROCPROF_COUNTERS_FILE=${LAMMPS_ALLEGRO_ROOT}/tools/roof-counters_gfx90a.txt

elif [[ "${SYSTEM}" = "lockhart_mi250x" ]]; then
  module load PrgEnv-gnu
  module load cray-mpich
  module load craype-accel-amd-gfx90a
  module load rocm/6.2.2
  module load cmake
  module load cray-python
  export GPU_ARCH="gfx90a"

  export LAMMPS_ALLEGRO_MPICXX=$(which CC)
  export LAMMPS_ALLEGRO_CXX=${ROCM_PATH}/bin/hipcc

  export MPICH_GPU_SUPPORT_ENABLED=1

  export CUDA_HOME=${ROCM_PATH}
  export TORCHINDUCTOR_MAX_AUTOTUNE="1"
  export TORCHINDUCTOR_LAYOUT_OPTIMIZATION="1"
  export PYTORCH_MIOPEN_SUGGEST_NHWC="1"
  export TORCHINDUCTOR_CPP_WRAPPER="1"
  export TORCHINDUCTOR_FREEZING="1"

  export ROCPROF_COUNTERS_FILE=${LAMMPS_ALLEGRO_ROOT}/tools/roof-counters_gfx90a.txt

elif [[ "${SYSTEM}" = "thera_mi300x" ]]; then
  module load rocm/6.3.4
  module load python/3.10.14
  export GPU_ARCH="gfx942"

  export LAMMPS_ALLEGRO_MPICXX=/home/bvillase/util/openmpi/rocm6.4.1/install/ompi/bin/mpicxx
  export LAMMPS_ALLEGRO_CXX=${ROCM_PATH}/bin/hipcc

  export CUDA_HOME=${ROCM_PATH}
  export TORCHINDUCTOR_MAX_AUTOTUNE="1"
  export TORCHINDUCTOR_LAYOUT_OPTIMIZATION="1"
  export PYTORCH_MIOPEN_SUGGEST_NHWC="1"
  export TORCHINDUCTOR_CPP_WRAPPER="1"
  export TORCHINDUCTOR_FREEZING="1"

  export ROCPROF_COUNTERS_FILE=${LAMMPS_ALLEGRO_ROOT}/tools/roof-counters_gfx90a.txt


else
  echo -e "${RED}System: ${SYSTEM} not in list of known systems. ${NC} "
  return
fi

export LAMMPS_ALLEGRO_SYSTEM=${SYSTEM} 

# Set a python virtual environment
pyenv_dir=${LAMMPS_ALLEGRO_ROOT}/pyenv
if [[ ! -e ${pyenv_dir}/bin/activate ]]; then
  echo -e "Creating python virtual environment: ${GREEN}${pyenv_dir} ${NC}"
  python3 -m venv ${pyenv_dir}
  ${pyenv_dir}/bin/python3 -m pip install --upgrade pip
  source ${pyenv_dir}/bin/activate


else
  source ${pyenv_dir}/bin/activate
fi
echo -e "Python environment active: ${GREEN}${pyenv_dir} ${NC}"


