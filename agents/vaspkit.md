# VASPkit Agent Prompt

Use this prompt when the user asks to run VASPkit, generate/check VASP input files, post-process VASP output, extract band/DOS data, or use qvasp.

Official manual: https://vaspkit.com

## Server Invocation

Preferred module:

```bash
module load vaspkit/1.5.1
vaspkit
```

Fallback:

```bash
/opt/vaspkit/vaspkit.1.5.1/bin/vaspkit
```

qvasp:

```bash
module load qvasp/2.25
/opt/qvasp/qvasp-v2.25/qvasp
```

## Helper

Use the bundled helper for remote VASPkit runs:

```bash
./scripts/dft_server_vaspkit.sh /remote/calc/dir --tasks "103" --run
./scripts/dft_server_vaspkit.sh /remote/calc/dir --tasks $'102\n2\n0.04' --run
./scripts/dft_server_vaspkit.sh /remote/calc/dir --cmd-args "-task 109" --run
```

Without `--run`, it previews only and does not run VASPkit.

## Manual Notes

The VASPkit manual says VASPkit can be used through an interactive interface or command-line/batch mode. For batch mode, feed menu inputs through standard input or use command options when supported.

Command-line mode examples from the installed help include:

```text
vaspkit -task 109
vaspkit -task 102 -kpr 0.04 -kps G
vaspkit -task 105 -file structure.cif
```

Useful command options shown by the installed VASPkit help:

```text
-task n       task number
-file FILE    input file, default POSCAR
-inp TEXT     INCAR preset
-kpr VALUE    K-mesh resolution
-kps G/M      Gamma or Monkhorst-Pack scheme
-fermi VALUE  Fermi level
-symprec VAL  symmetry tolerance
-sc n1 n2 n3  supercell size
-dim n        dimension, 3/2/1
```

Main menu areas from the manual include:

```text
01 VASP input-file generator
03 K-path for band structure
11 Density of states
21 Band structure
31 Charge-density analysis
42 Potential analysis
62 Magnetic analysis
65 Spin texture
68 Transport properties
78 VASP-to-other interface
91 Semiconductor kit
92 2D-material kit
95 Phonon analysis
```

Input-generation tasks documented by VASPkit:

```text
101 Generate/customize INCAR
102 Generate KPOINTS for SCF
103 Generate POTCAR with default settings
104 Generate POTCAR with user-specified potential
105 Generate POSCAR from CIF
108 Successive VASP file generation and check
109 Check all VASP files
```

Important warning: on some servers, `vaspkit -task 109` may submit a VASP job through existing queue setup, not just perform a passive check. Do not run task `109` automatically as a safe check. Use the internal checks in `dft_server_dft_assist.sh` and `dft_server_submit.sh` unless the user explicitly asks to run VASPkit task `109` and understands it may submit a job.

## Safety

Many VASPkit tasks overwrite files such as `INCAR`, `KPOINTS`, `POTCAR`, or generated data files. Preview the intended task and target directory first. If unsure whether a task overwrites an existing file, inspect the directory before running and mention the risk.

Do not blindly trust generated INCAR settings. After VASPkit generation, inspect key physics settings such as spin, SOC, DFT+U, vdW, smearing, relaxation flags, and convergence thresholds.
