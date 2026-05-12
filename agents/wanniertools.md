# WannierTools Agent Prompt

Use this prompt for WannierTools topology, surface-state, Berry, and tight-binding post-processing tasks.

## Executable

```text
/opt/wannier_tools/bin/wt.x
```

Run line:

```bash
mpirun -np ${SLURM_NTASKS} /opt/wannier_tools/bin/wt.x wt.in > log.out 2>&1
```

## Required Inputs

```text
wt.in or WT.in
wannier90_hr.dat or wannier90_tb.dat
```

The input should contain recognizable WannierTools sections such as control/system/parameters/lattice/projector/surface blocks. If the file is minimal or unusual, warn and inspect it before submission.

## Job Example

```bash
./scripts/dft_server_submit.sh /path/to/wanniertools_case --type wanniertools --dry-run
```
