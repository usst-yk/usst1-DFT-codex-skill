#!/usr/bin/env bash
set -euo pipefail

SSH_TARGET="${DFT_SERVER_TARGET:-dft-server}"

usage() {
  cat <<'USAGE'
Usage:
  dft_server_submit.sh REMOTE_DIR --type TYPE [--write-script|--submit]

Types:
  existing, vasp-std, vasp-ncl, vasp-gam, wannier90, postw90,
  wannsymm, wanniertools, wannierberri

Options:
  --job NAME
  --cores N              default 60 for MPI jobs, 1 for WannierBerri
  --time HH:MM:SS        default 2000:00:00
  --script NAME          default sub.sh
  --seed NAME            default wannier90
  --python-script FILE
  --write-script
  --submit
  --force
USAGE
}

remote_dir=""
calc_type=""
job_name=""
cores="auto"
time_limit="2000:00:00"
script_name="sub.sh"
seed="wannier90"
python_script="auto"
write_script=0
submit=0
force=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) calc_type="${2:?}"; shift 2 ;;
    --job) job_name="${2:?}"; shift 2 ;;
    --cores) cores="${2:?}"; shift 2 ;;
    --time) time_limit="${2:?}"; shift 2 ;;
    --script) script_name="${2:?}"; shift 2 ;;
    --seed) seed="${2:?}"; shift 2 ;;
    --python-script) python_script="${2:?}"; shift 2 ;;
    --write-script) write_script=1; shift ;;
    --submit) submit=1; write_script=1; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) if [[ -z "$remote_dir" ]]; then remote_dir="$1"; else echo "Unexpected argument: $1" >&2; exit 2; fi; shift ;;
  esac
done
[[ -n "$remote_dir" && -n "$calc_type" ]] || { usage >&2; exit 2; }

ssh -o StrictHostKeyChecking=accept-new "$SSH_TARGET" 'bash -s' -- "$remote_dir" "$calc_type" "${job_name:-__AUTO__}" "$cores" "$time_limit" "$script_name" "$seed" "$python_script" "$write_script" "$submit" "$force" <<'REMOTE'
set -euo pipefail
remote_dir="$1"; calc_type="$2"; job_name="$3"; cores="$4"; time_limit="$5"; script_name="$6"; seed="$7"; python_script="$8"; write_script="$9"; submit="${10}"; force="${11}"
die(){ echo "ERROR: $*" >&2; exit 1; }
need(){ [[ -s "$1" ]] || die "Missing or empty: $1"; }
[[ -d "$remote_dir" ]] || die "Remote directory not found: $remote_dir"
cd "$remote_dir"
[[ "$job_name" == "__AUTO__" ]] && job_name="$(basename "$remote_dir")"
job_name="${job_name// /_}"

case "$calc_type" in
  existing)
    need "$script_name"
    ;;
  vasp-std|vasp-ncl|vasp-gam)
    need INCAR; need POSCAR; need KPOINTS; need POTCAR
    [[ "$cores" == auto ]] && cores=60
    bin="/opt/vasp.6.5.0/bin/vasp_${calc_type#vasp-}"
    run_line="mpirun -np \${SLURM_NTASKS} $bin > log.out 2>&1"
    ;;
  wannier90)
    [[ "$cores" == auto ]] && cores=60
    need "$seed.win"; need "$seed.eig"
    [[ -s "$seed.mmn" || -s "$seed.amn" ]] || die "Need $seed.mmn or $seed.amn"
    run_line="mpirun -np \${SLURM_NTASKS} /opt/wannier/wannier90-3.1.0-mpi/wannier90.x $seed > log.out 2>&1"
    ;;
  postw90)
    [[ "$cores" == auto ]] && cores=60
    need "$seed.win"; need "$seed.chk"
    run_line="mpirun -np \${SLURM_NTASKS} /opt/wannier/wannier90-3.1.0-mpi/postw90.x $seed > log.out 2>&1"
    ;;
  wannsymm)
    [[ "$cores" == auto ]] && cores=60
    need wannsymm.in
    [[ -s wannier90_hr.dat || -s wannier90_tb.dat ]] || die "Need wannier90_hr.dat or wannier90_tb.dat"
    run_line="mpirun -np \${SLURM_NTASKS} /opt/WannSymm/bin/wannsymm.x wannsymm.in > log.out 2>&1"
    ;;
  wanniertools)
    [[ "$cores" == auto ]] && cores=60
    [[ -s wt.in || -s WT.in ]] || die "Need wt.in or WT.in"
    input="wt.in"; [[ -s WT.in ]] && input="WT.in"
    [[ -s wannier90_hr.dat || -s wannier90_tb.dat ]] || die "Need wannier90_hr.dat or wannier90_tb.dat"
    run_line="mpirun -np \${SLURM_NTASKS} /opt/wannier_tools/bin/wt.x $input > log.out 2>&1"
    ;;
  wannierberri)
    [[ "$cores" == auto ]] && cores=1
    [[ "$python_script" == auto ]] && python_script="run_ahc.py"
    need "$python_script"
    grep -Eq 'wannierberri|wberri' "$python_script" || die "Python script does not reference WannierBerri"
    run_line="/opt/anaconda3/bin/python $python_script > log.out 2>&1"
    ;;
  *) die "Unsupported type: $calc_type" ;;
esac

if [[ "$calc_type" != existing ]]; then
  if [[ "$write_script" == 1 ]]; then
    [[ ! -e "$script_name" || "$force" == 1 ]] || die "$script_name exists; use --force"
    cat > "$script_name" <<EOF
#!/bin/bash
#SBATCH -J $job_name
#SBATCH -p cpu
#SBATCH -t $time_limit
#SBATCH -N 1
#SBATCH -n $cores
#SBATCH -e error.log
#SBATCH -o output.log

ulimit -s unlimited
source /opt/intel/oneapi/setvars.sh

$run_line
EOF
    chmod +x "$script_name"
    status=generated_or_updated
  else
    status=would_generate
  fi
else
  status=reusing_existing
fi

echo "REMOTE_DIR=$remote_dir"
echo "TYPE=$calc_type"
echo "SCRIPT=$remote_dir/$script_name"
echo "JOB=$job_name"
echo "CORES=$cores"
echo "TIME=$time_limit"
echo "SCRIPT_STATUS=$status"
[[ "$submit" == 1 ]] && sbatch "$script_name" || echo "DRY_RUN=1"
REMOTE
