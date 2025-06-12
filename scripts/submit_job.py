import os
import sys
import shutil
import time
import argparse

import glob
import shutil
import os


HOME = os.getenv('HOME')
DUAL_ROOT = os.getenv('DUAL_ROOT', None)
LAMMPS_ALLEGRO_ROOT = os.getenv('LAMMPS_ALLEGRO_ROOT', None)
if not LAMMPS_ALLEGRO_ROOT:
  print("The LAMMPS_ALLEGRO_ROOT environment variable should be set ")
  print("Did you remember to `source scripts/set_env.sh` in the root directory ?")
  sys.exit(1)

sys.path.append(f'{LAMMPS_ALLEGRO_ROOT}/tools')
import slurm_templates 

parser = argparse.ArgumentParser( description="DualSPH SLURM script generator.")
parser.add_argument('--system', dest='system', type=str, help='System for the run.', default='lockhart_mi250x' )
parser.add_argument('--work_dir', dest='work_dir', type=str, help='Path of the work directory.', default=None )
parser.add_argument('--n_nodes', dest='n_nodes', type=int, help='Number of nodes for the run.', default=1 )
parser.add_argument('--n_mpi', dest='n_mpi_per_node', type=int, help='Number of MPI ranks per node for the run.', default=1 )
parser.add_argument('--profiler', dest='profiler', type=str, help='Type of profiler to use', default=None )
parser.add_argument('--debug', dest='debug', type=bool, help='Use the debug queue in Frontier', default=False )
args = parser.parse_args()


system = args.system
if system is None:
  print( 'ERROR: parameter `--system` has to be specified ')
  exit(1)

work_dir = args.work_dir
if work_dir is None:
  print( 'ERROR: parameter `--work_dir` has to be specified ')
  exit(1)
