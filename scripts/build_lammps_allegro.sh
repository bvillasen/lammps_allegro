#!/bin/bash

#Instructions taken from here: https://github.com/mir-group/pair_nequip_allegro

echo "LAMMPS_ALLEGRO_ROOT: $LAMMPS_ALLEGRO_ROOT"

LAMMPS_ROOT=$LAMMPS_ALLEGRO_ROOT/lammps
PAIR_ALLEGRO_ROOT=$LAMMPS_ALLEGRO_ROOT/pair_nequip_allegro

# Download libtorch
LIB_DIR=$LAMMPS_ALLEGRO_ROOT/lib
LIBTORCH_DIR=${LIB_DIR}/libtorch
LIBTORCH_URL="https://download.pytorch.org/libtorch/rocm6.2.4/libtorch-cxx11-abi-shared-with-deps-2.6.0%2Brocm6.2.4.zip"
# LIBTORCH_URL="https://download.pytorch.org/libtorch/rocm6.3/libtorch-cxx11-abi-shared-with-deps-2.7.1%2Brocm6.3.zip"
# LIBTORCH_URL="https://download.pytorch.org/libtorch/nightly/rocm6.4/libtorch-cxx11-abi-shared-with-deps-latest.zip"
if [ ! -d "${LIB_DIR}" ]; then
  mkdir ${LIB_DIR}
fi
if [ ! -d "${LIBTORCH_DIR}" ]; then
  echo "Downloading libtorch here: ${LIBTORCH_DIR}"
  cd $LIB_DIR
  wget ${LIBTORCH_URL}
  unzip libtorch-*
  rm -r libtorch-*
fi

# # Download lammps
# if [ ! -d "${LAMMPS_ROOT}" ]; then
#   echo "Cloning repository: lammps"
#   git clone --depth=1 https://github.com/lammps/lammps $LAMMPS_ROOT
# fi


# if [ ! -d "${PAIR_ALLEGRO_ROOT}" ]; then
#   echo "Cloning repository: pair_nequip_allegro"
#   git clone --depth=1 https://github.com/mir-group/pair_nequip_allegro $PAIR_ALLEGRO_ROOT

#   echo "Patching lammps"
#   cd ${PAIR_ALLEGRO_ROOT}
#   ./patch_lammps.sh ${LAMMPS_ROOT}
# fi


# echo "Building lammps"
# rm -r ${LAMMPS_ROOT}/build
# MPICXX=$(which CC)
# # MPICXX=${ROCM_PATH}/bin/hipcc
# CXX=${ROCM_PATH}/bin/hipcc 
# echo "MPICXX: ${MPICXX}"
# echo "CXX: ${CXX}"

# # TORCH_PATH=$(python -c 'import torch;print(torch.utils.cmake_prefix_path)')
# TORCH_PATH="${LAMMPS_ALLEGRO_ROOT}/lib/libtorch"
# echo "TORCH_PATH: ${TORCH_PATH}"

# cd ${LAMMPS_ROOT}
# mkdir build
# cd build


# cmake -DBUILD_MPI=on \
#       -DPKG_KOKKOS=ON \
#       -DKokkos_ENABLE_HIP=on \
#       -DMPI_CXX_COMPILER=${MPICXX} \
#       -DCMAKE_CXX_COMPILER=${CXX} \
#       -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
#       -DCMAKE_HIPFLAGS="--offload-arch=gfx90a" \
#       -DCMAKE_CXX_FLAGS="-fdenormal-fp-math=ieee -fgpu-flush-denormals-to-zero -munsafe-fp-atomics -I$MPICH_DIR/include" \
#       -DMKL_INCLUDE_DIR="/tmp" \
#       -DUSE_MKLDNN=OFF \
#       -DNEQUIP_AOT_COMPILE=ON \
#       -DPKG_MOLECULE=ON \
#       -DCMAKE_PREFIX_PATH="${TORCH_PATH}" \
#       ../cmake

# make -j install
