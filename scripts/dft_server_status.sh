#!/usr/bin/env bash
set -euo pipefail

SSH_TARGET="${DFT_SERVER_TARGET:-dft-server}"

REMOTE_CMD='
printf "HOST="; hostname
printf "USER="; whoami
printf "DATE="; date
printf "UPTIME="; uptime
printf "PWD="; pwd
printf "\nDISK\n"; df -h | sed -n "1,100p"
printf "\nMEMORY\n"; free -h 2>/dev/null || vmstat -s 2>/dev/null | sed -n "1,35p"
printf "\nCPU\n"; nproc 2>/dev/null || true; lscpu 2>/dev/null | sed -n "1,35p" || true
printf "\nSCHEDULER AND MPI\n"; command -v sbatch squeue qsub qstat mpirun mpiexec 2>/dev/null | sed -n "1,80p" || true
printf "\nFIRST PRINCIPLES SOFTWARE\n"
for p in \
  /opt/vasp.6.5.0/bin/vasp_std \
  /opt/vasp.6.5.0/bin/vasp_ncl \
  /opt/wannier/wannier90-3.1.0-mpi/wannier90.x \
  /opt/wannier/wannier90-3.1.0-mpi/postw90.x \
  /opt/wannier_tools/bin/wt.x \
  /opt/WannSymm/bin/wannsymm.x \
  /opt/anaconda3/bin/python \
  /opt/vaspkit/vaspkit.1.5.1/bin/vaspkit; do
  test -x "$p" && printf "%s OK\n" "$p" || printf "%s MISSING\n" "$p"
done
printf "\nQUEUE\n"; (squeue -u $(whoami) 2>/dev/null || qstat -u $(whoami) 2>/dev/null || jobs)
printf "\nWORK ROOT\n"; work_root="${DFT_SERVER_WORK_ROOT:-codex}"; ls -ld "$work_root" 2>/dev/null || true; find "$work_root" -maxdepth 2 -mindepth 1 -type d -printf "%TY-%Tm-%Td %TH:%TM %p\n" 2>/dev/null | sort | sed -n "1,120p"
'

ssh -o StrictHostKeyChecking=accept-new "$SSH_TARGET" "$REMOTE_CMD"
