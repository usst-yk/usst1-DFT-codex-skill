---
name: dft-server
description: Connect to the user's DFT first-principles server, manage SSH key login, generate/check DFT inputs, run VASPkit helpers, and prepare or submit VASP/Wannier-related jobs.
---

# DFT Server

Use this skill for DFT first-principles work: SSH setup, server status, `$DFT_SERVER_WORK_ROOT` project directories, VASP, VASPkit, Wannier90, WannierBerri, WannierTools, WannSymm, and Slurm job submission.

## Agent Files

Load only the relevant file from `agents/`:

```text
quickstart.md       common commands and entry points
server.md           login, server parameters, installed software, layout
dft-assistant.md    self-service DFT input generation and confirmation
submission.md       Slurm scripts, submission, and pre-submit checks
vasp.md             VASP checks and run choices
vaspkit.md          VASPkit usage and warnings
wannier90.md        Wannier90 and postw90
wannierberri.md     WannierBerri Python workflows
wanniertools.md     WannierTools workflows
wannsymm.md         WannSymm workflows
```

## Defaults

```text
SSH target: dft-server
Work root: $DFT_SERVER_WORK_ROOT
Default generated job: cpu partition, 1 node, 60 tasks, 2000:00:00
```

Create new Codex-managed calculations only under `$DFT_SERVER_WORK_ROOT` unless the user explicitly asks otherwise. Use clear names such as `FeS_relax_20260512`, `CuCrTe2_soc_v1`, or `MnBi2Te4_wannier_ahc`.

## Core Safety

Default to read-only inspection. Do not submit, cancel, delete, overwrite, or move calculation files unless the user explicitly asks.

Never store the server password. First-time password use is only for `scripts/dft_server_setup_key.sh`, which installs SSH key login.

Always preview before writing inputs or submitting jobs when the target, mode, or required files are not completely clear.

Do not run VASPkit task `109` as an automatic safe check on this server; it was observed to submit a VASP job.

## References

```text
VASP: https://vasp.at/wiki/The_VASP_Manual
VASPkit: https://vaspkit.com
Wannier90: https://wannier90.readthedocs.io/en/latest/
WannierBerri: https://wannier-berri.org/index.html
WannierTools: http://www.wanniertools.com
```
