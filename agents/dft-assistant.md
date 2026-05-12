# DFT Self-Service Agent Prompt

Use this prompt when the user wants an automated DFT workflow: generate initial VASP files, check them, confirm the intended calculation, and prepare or submit a job.

## Helper

```bash
./scripts/dft_server_dft_assist.sh $DFT_SERVER_WORK_ROOT/project_name --mode relax
./scripts/dft_server_dft_assist.sh $DFT_SERVER_WORK_ROOT/project_name --mode relax --write --yes
./scripts/dft_server_dft_assist.sh $DFT_SERVER_WORK_ROOT/project_name --mode scf --submit --yes
./scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax
```

Default mode is preview only. It writes nothing and submits nothing. Use this preview as the confirmation step: show the user the mode, generated files, checks, job name, cores, and time.

Default work root for new calculations:

```text
$DFT_SERVER_WORK_ROOT
```

Create clear subdirectories under this root. Suggested naming pattern:

```text
Material_mode_detail
Material_mode_YYYYMMDD
Material_mode_v1
```

## Supported Modes

```text
relax    Structure relaxation
scf      Static self-consistent calculation
nscf     Non-self-consistent calculation; requires CHGCAR
soc      SOC/noncollinear calculation; uses vasp_ncl
wannier  VASP-to-Wannier preparation; requires wannier90.win
```

## Generation

The helper uses VASPkit for:

```text
task 105: convert CIF to POSCAR when requested
task 102: generate KPOINTS; on some servers it can also generate POTCAR
task 103: generate POTCAR when still needed
```

The helper writes conservative INCAR templates for each mode, then runs internal checks before preparing the Slurm script.

Do not run VASPkit task `109` as an automatic check. It can submit a VASP job on some servers.

## Confirmation Policy

For a user-facing workflow:

```text
1. Run preview without --write or --submit.
2. Explain what will be generated and what calculation mode it represents.
3. If the user confirms, rerun with --write --yes or --submit --yes.
```

Use `--force` only when the user agrees to back up and replace existing `INCAR`, `KPOINTS`, or `POTCAR`.

## Checks

The helper checks:

```text
POSCAR, INCAR, KPOINTS, POTCAR exist and are non-empty
POSCAR and KPOINTS have basic structure
POTCAR looks like a real VASP POTCAR
nscf requires CHGCAR
wannier requires wannier90.win
old output.log, error.log, log.out are reported
```
