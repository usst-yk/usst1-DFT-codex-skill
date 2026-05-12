# DFT Server Submission Agent Prompt

Use this prompt for Slurm submission, script generation, and pre-submit checks.

## Helper

```bash
./scripts/dft_server_submit.sh /remote/calc/dir --dry-run
./scripts/dft_server_submit.sh /remote/calc/dir --write-script
./scripts/dft_server_submit.sh /remote/calc/dir --submit
```

`--dry-run` checks only and must not write remote files. `--write-script` creates or updates the script without submitting. `--submit` creates the script when needed and submits with `sbatch`.

Supported types:

```text
auto, existing, vasp-std, vasp-ncl, vasp-gam,
wannier90, postw90, wannsymm, wanniertools, wannierberri
```

Common options:

```text
--job NAME
--cores N
--time HH:MM:SS
--script NAME
--seed NAME
--python-script FILE
--force
--skip-checks
```

## Submission Policy

Default to preview. Submit only when the user clearly asks to submit.

If a directory already has a `sub.sh`, prefer `--type existing` and inspect warnings. If the user wants a fresh script, use an explicit type and `--write-script` or `--submit`.

Default generated Slurm settings:

```text
Partition: cpu
Nodes: 1
Tasks: 60 for MPI jobs, 1 for WannierBerri
Wall time: 2000:00:00
Output: output.log, error.log, log.out
```

## Pre-Submit Checks

All generated jobs: task count must be 1-120.

Existing scripts: require non-empty script; warn if cpu partition, task count, or recognizable run command is missing.

VASP: require non-empty `INCAR`, `POSCAR`, `KPOINTS`, `POTCAR`; block `ICHARG=11/12` without `CHGCAR`; warn on `ISTART=1` without `WAVECAR`; block `LWANNIER90` without `wannier90.win`; warn if `LSORBIT` does not match `vasp-std` or `vasp-ncl`.

Wannier90: require non-empty seed `.win`, seed `.eig`, and seed `.mmn` or `.amn`.

postw90: require non-empty seed `.win` and `.chk`; warn if `.eig` is missing; block Berry-related tasks without `.mmn`.

WannierTools: require non-empty `wt.in` or `WT.in`, plus `wannier90_hr.dat` or `wannier90_tb.dat`.

WannierBerri: require Python script importing `wannierberri` or `wberri`, seed `_hr.dat`, `.chk`, and `.mmn` for Berry/AHC/SHC workflows.

WannSymm: require non-empty `wannsymm.in`, plus `wannier90_hr.dat` or `wannier90_tb.dat`.

Warn when old `output.log`, `error.log`, or `log.out` already exist.
