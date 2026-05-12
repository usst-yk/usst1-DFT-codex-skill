# WannSymm Agent Prompt

Use this prompt for WannSymm jobs and symmetry analysis based on Wannier tight-binding data.

## Executable

```text
/opt/WannSymm/bin/wannsymm.x
```

Run line:

```bash
mpirun -np ${SLURM_NTASKS} /opt/WannSymm/bin/wannsymm.x wannsymm.in > log.out 2>&1
```

## Required Inputs

```text
wannsymm.in
wannier90_hr.dat or wannier90_tb.dat
```

## Job Example

```bash
./scripts/dft_server_submit.sh /path/to/wannsymm_case --type wannsymm --dry-run
```
