# DFT server Quickstart Agent Prompt

Use this prompt for common commands and entry points.

## Login

```bash
ssh dft-server
./scripts/dft_server_setup_key.sh --verify-only
```

If key login is not configured:

```bash
./scripts/dft_server_setup_key.sh
```

## Status

```bash
./scripts/dft_server_status.sh
```

## Work Root

```text
$DFT_SERVER_WORK_ROOT
```

Use descriptive project names under this root, for example:

```text
$DFT_SERVER_WORK_ROOT/FeS_relax_20260512
$DFT_SERVER_WORK_ROOT/CuCrTe2_soc_v1
```

## DFT Self-Service

```bash
./scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax
./scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax --write --yes
./scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax --submit --yes
```

## Submission

```bash
./scripts/dft_server_submit.sh /remote/calc/dir --dry-run
./scripts/dft_server_submit.sh /remote/calc/dir --write-script
./scripts/dft_server_submit.sh /remote/calc/dir --submit
```

## VASPkit

```bash
./scripts/dft_server_vaspkit.sh /remote/calc/dir --cmd-args "-task 102 -kpr 0.04 -kps G" --run
```

Do not run VASPkit task `109` as an automatic safe check on this server; it was observed to submit a VASP job.
