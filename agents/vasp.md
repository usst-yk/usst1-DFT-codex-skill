# VASP Agent Prompt

Use this prompt for VASP calculation setup, checking, monitoring, and run-type selection.

## Executables

Prefer VASP 6.5.0 for generated jobs unless the user asks otherwise:

```text
/opt/vasp.6.5.0/bin/vasp_std
/opt/vasp.6.5.0/bin/vasp_ncl
/opt/vasp.6.5.0/bin/vasp_gam
```

Other common builds:

```text
/opt/vasp-5.4.4/bin
/opt/vasp.6.3.0/bin
/opt/vasp.6.5.0.soc_scale/bin
```

Generated Slurm run line:

```bash
mpirun -np ${SLURM_NTASKS} /opt/vasp.6.5.0/bin/vasp_std > log.out 2>&1
```

## Required Inputs

```text
INCAR
POSCAR
KPOINTS
POTCAR
```

Before submission, check non-empty files and basic completeness. For fixed-charge non-SCF runs, `ICHARG=11/12` requires `CHGCAR`. If `ISTART=1`, warn when `WAVECAR` is missing. If `LWANNIER90` is enabled, require `wannier90.win`.

Select `vasp-ncl` when `LSORBIT = T` or when the user asks for SOC/noncollinear calculations.

## Monitoring

Inspect concise files first:

```bash
ssh dft-server 'tail -80 /path/to/calc/OSZICAR'
ssh dft-server 'tail -120 /path/to/calc/output.log'
ssh dft-server 'tail -120 /path/to/calc/log.out'
ssh dft-server 'grep -n "reached required accuracy\\|General timing\\|Voluntary context switches" /path/to/calc/OUTCAR | tail'
```

## Typical Flow

```text
1. Relax structure.
2. Static SCF with converged structure.
3. Non-SCF or NCL run when band/Wannier data are needed.
4. Post-process with VASPkit, Wannier90, WannierBerri, WannierTools, or WannSymm.
```
