# Wannier90 Agent Prompt

Use this prompt for Wannier90 and postw90 jobs.

## Executables

```text
Wannier90 MPI: /opt/wannier/wannier90-3.1.0-mpi/wannier90.x
postw90 MPI: /opt/wannier/wannier90-3.1.0-mpi/postw90.x
Wannier90 serial: /opt/wannier/wannier90-3.1.0/wannier90.x
```

Default seed is `wannier90`.

## Required Inputs

For `wannier90`:

```text
seed.win
seed.eig
seed.mmn or seed.amn
```

For `postw90`:

```text
seed.win
seed.chk
```

Berry/AHC/SHC-style postw90 tasks also need `seed.mmn`.

## Job Examples

```bash
./scripts/dft_server_submit.sh /path/to/wannier --type wannier90 --dry-run
./scripts/dft_server_submit.sh /path/to/AHC --type postw90 --dry-run
```

## Checks

Before running Wannier90, confirm the VASP step produced the requested Wannier interface files and that `wannier90.win` matches the intended orbitals/projections. If the VASP step used SOC or noncollinear settings, keep the downstream workflow consistent.
