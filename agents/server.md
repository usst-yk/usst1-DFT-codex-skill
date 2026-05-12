# DFT Server Agent Prompt

Use this prompt for connection, server status, installed software, and directory layout.

## Connection

```bash
ssh dft-server
ssh -p <YOUR_SSH_PORT> <YOUR_USER>@<YOUR_SERVER_HOST>
```

First-time setup or verification:

```bash
./scripts/dft_server_setup_key.sh
./scripts/dft_server_setup_key.sh --verify-only
```

If password login is needed for first-time setup, ask the user for the password only for that operation. Do not store it. The setup script generates or reuses `~/.ssh/dft_server_ed25519`, appends the public key to the server's `authorized_keys`, writes the `dft-server` SSH config if missing, and confirms key login.

Known SSH settings template:

```text
HostName <YOUR_SERVER_HOST>
Port <YOUR_SSH_PORT>
User <YOUR_USER>
IdentityFile ~/.ssh/dft_server_ed25519
IdentitiesOnly yes
```

Optional host key fingerprints can be recorded locally after the user verifies them with their server administrator:

```text
ED25519 SHA256:<YOUR_VERIFIED_HOST_KEY>
RSA     SHA256:<YOUR_VERIFIED_HOST_KEY>
ECDSA   SHA256:<YOUR_VERIFIED_HOST_KEY>
```

## Status

Use:

```bash
./scripts/dft_server_status.sh
```

The script reports server health, queue status, first-principles software paths, submission scripts, and major calculation directories.

## Server Parameters

Record server-specific parameters locally after inspection:

```text
Hostname: discovered by status script
Scheduler: Slurm preferred; qsub/qstat can also be present
Partition: cpu by default in generated scripts
Node count for jobs: 1
Default generated MPI job: 60 tasks
Use all cores only when explicitly requested or when reusing a known script that already does so.
```

## Installed Software

Common expected paths. Adjust in scripts or server modules if your cluster differs:

```text
Intel oneAPI setup: /opt/intel/oneapi/setvars.sh
VASP 5.4.4: /opt/vasp-5.4.4/bin/vasp_std, vasp_ncl, vasp_gam
VASP 6.3.0: /opt/vasp.6.3.0/bin/vasp_std, vasp_ncl, vasp_gam
VASP 6.5.0: /opt/vasp.6.5.0/bin/vasp_std, vasp_ncl, vasp_gam
VASPkit 1.5.1: module load vaspkit/1.5.1 or /opt/vaspkit/vaspkit.1.5.1/bin/vaspkit
qvasp 2.25: module load qvasp/2.25 or /opt/qvasp/qvasp-v2.25/qvasp
Wannier90 MPI: /opt/wannier/wannier90-3.1.0-mpi/wannier90.x
postw90 MPI: /opt/wannier/wannier90-3.1.0-mpi/postw90.x
WannierTools: /opt/wannier_tools/bin/wt.x
WannSymm: /opt/WannSymm/bin/wannsymm.x
WannierBerri Python: /opt/anaconda3/bin/python
PBE potentials: $PBE_POTCAR_ROOT
LDA potentials: $LDA_POTCAR_ROOT
```

## Layout

Default Codex work root:

```text
$DFT_SERVER_WORK_ROOT
```

Use this directory for all future Codex-managed calculations. Create descriptive subdirectories by material, mode, and optional date/version, for example:

```text
$DFT_SERVER_WORK_ROOT/FeS_relax_20260512
$DFT_SERVER_WORK_ROOT/CuCrTe2_soc_v1
$DFT_SERVER_WORK_ROOT/MnBi2Te4_wannier_ahc
```

Keep legacy or user-owned project trees read-only unless the user explicitly asks to work there.
