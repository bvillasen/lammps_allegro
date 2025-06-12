import os
import sys
import shutil
import time
import argparse

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


n_nodes = args.n_nodes
n_mpi_per_node = args.n_mpi_per_node
n_mpi = n_mpi_per_node * n_nodes
debug_queue = args.debug

profiler = ''
if args.profiler is not None:
  valid_profilers = ['rocprof_stats', 'rocprof_counters', 'rocprof_roctx', 'rocprof_hip-trace', 'rocprof_sys-trace', 'rocprofv3_stats', 'rocprofv3_counters', 'pytorch', 'rocprof-compute' ]
  if args.profiler in valid_profilers : profiler = args.profiler
  else:
    print( f'ERROR: Invalid profiler: {args.profiler}')
    sys.exit(1)

job_name = f'lmp'

work_dir = args.work_dir
if not os.path.isdir(work_dir): os.mkdir(work_dir)
run_base_name = 'run'
if profiler == 'rocprof_stats': run_base_name = 'rocprof'
elif profiler == 'rocprof_counters': run_base_name = 'rocprof'
elif profiler == 'rocprof_roctx': 
  run_base_name = 'roctx'
  use_roctx = True
elif profiler == 'rocprof_hip-trace': 
  run_base_name = 'hip-trace'
  use_roctx = True
elif profiler == 'rocprof_sys-trace': 
  run_base_name = 'sys-trace'
  use_roctx = True
elif profiler == 'rocprofv3_stats': run_base_name = 'rocprofv3'
elif profiler == 'rocprofv3_counters': run_base_name = 'rocprofv3'
elif profiler == 'rocprof-compute': run_base_name = 'rocprof-compute'

run_dir = f'{work_dir}/{run_base_name}_nnodes{n_nodes}_nmpi{n_mpi}'
if not os.path.isdir(run_dir): os.mkdir(run_dir)

use_slurm = True
slurm_options = ''
lammps_exec = f'{LAMMPS_ALLEGRO_ROOT}/lammps/build/lmp'
if system == 'lockhart_mi250x':
  n_hrs, n_min = 1, 0
  slurm_template = slurm_templates.lockhart
  slurm_partition = ""
  n_nodes = n_nodes
  n_mpi_per_node = n_mpi_per_node
  n_gpu_per_node = 8
  n_cores_per_task = 8
  n_threads_per_core = 1

elif system == 'frontier':
  n_hrs, n_min = 0, 10
  slurm_template = slurm_templates.frontier
  slurm_partition = ""
  n_nodes = n_nodes
  n_mpi_per_node = n_mpi_per_node
  n_gpu_per_node = 8
  n_cores_per_task = 7
  n_threads_per_core = 1
  slurm_options = '#SBATCH -A VEN114 \n'  
  if debug_queue: slurm_options += '#SBATCH -q debug \n'
else:   
  print(f'ERROR: System {system} is not supported.')
  exit(1)

print(f'system: {system}' )
print(f'n_nodes: {n_nodes}' )
print(f'n_mpi_per_node: {n_mpi_per_node}' )

# Copy data files to work_dir
data_dir = f'{LAMMPS_ALLEGRO_ROOT}/data'
for file_name in os.listdir(data_dir):
  shutil.copy(f'{data_dir}/{file_name}', run_dir)


set_env_command = f'''
# Set the environment
SYSTEM={system} source {LAMMPS_ALLEGRO_ROOT}/scripts/set_env.sh 
module list\n
'''

app_run_cmd = f'''
export LAMMPS_ALLEGRO_EXEC={lammps_exec}
export OMP_NUM_THREADS=7 
srun -n {n_mpi} -c 7 --gpus-per-node 8 {LAMMPS_ALLEGRO_ROOT}/scripts/run_app.sh  > app_output.log
'''

slurm_script_content = set_env_command
slurm_script_content += app_run_cmd

slurm_script = slurm_template 
slurm_script = slurm_script.replace( 'SLURM_SCRIPT_CONTENT', slurm_script_content)
slurm_script = slurm_script.replace( 'SBATCH_PARTITION', slurm_partition )
slurm_script = slurm_script.replace( 'JOB_NAME', job_name )
slurm_script = slurm_script.replace( 'N_HRS', str(n_hrs) )
slurm_script = slurm_script.replace( 'N_MIN', str(n_min) )
slurm_script = slurm_script.replace( 'N_NODES', str(n_nodes) )
slurm_script = slurm_script.replace( 'N_TASK_PER_NODE', str(n_mpi_per_node) )
slurm_script = slurm_script.replace( 'N_CORES_PER_TASK', str(n_cores_per_task) )
slurm_script = slurm_script.replace( 'N_GPU_PER_NODE', str(n_gpu_per_node) )
slurm_script = slurm_script.replace( 'N_THREADS_PER_CORE', str(n_threads_per_core) )
slurm_script = slurm_script.replace( 'SLURM_OPTIONS', slurm_options )
slurm_script = slurm_script.replace( 'RUNDIR', run_dir )

file_name = f'{run_dir}/submit_job.slurm'
file = open( file_name, 'w' )
file.write( slurm_script )
file.close()
time.sleep(0.5)
print(f'Saved file: {file_name}')

if use_slurm: submit_cmnd = f'sbatch {file_name}'
else: submit_cmnd = f'bash {file_name}'
print( f'Submitting job: {file_name}' )
time.sleep(2)
if use_slurm: os.system( submit_cmnd )

