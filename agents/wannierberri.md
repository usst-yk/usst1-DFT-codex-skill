# WannierBerri Agent Prompt

Use this prompt for Berry-curvature, anomalous Hall conductivity, spin Hall, and related WannierBerri Python workflows.

## Runtime

```text
Python: /opt/anaconda3/bin/python
WannierBerri observed version: check on the target server
```

Use the Python that can import WannierBerri, often an Anaconda Python rather than system Python.

## Required Inputs

Common files:

```text
seed_hr.dat
seed.chk
seed.mmn for Berry/AHC/SHC-style workflows
seed.eig often needed; warn if missing
```

The Python script must import `wannierberri` or `wberri`.

## Job Example

```bash
./scripts/dft_server_submit.sh /path/to/wannierberri_case --type wannierberri --python-script run_ahc.py --dry-run
```

## Checks

Confirm the seed name used inside the Python script matches the files in the directory. For magnetic or multiferroic systems, be cautious with symmetry reduction; workflows may need `use_irred_kpt=False`.
