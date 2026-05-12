# Install and Use With Codex

## Install

In Codex, say:

```text
Install this GitHub repository as a Codex skill:
https://github.com/usst-yk/usst1-DFT-codex-skill

Install it as dft-server.
After installing, make helper scripts executable with:
chmod +x scripts/*.sh
```

If Codex does not preserve executable permissions, run helpers with `bash`, for example:

```bash
bash scripts/dft_server_setup_key.sh --verify-only
bash scripts/dft_server_status.sh
```

## Configure Connection

Ask Codex:

```text
Use the dft-server skill to configure my first-principles server.
Ask me for SSH host, port, username, and remote work directory.
Set these locally as DFT_SERVER_HOST, DFT_SERVER_PORT, DFT_SERVER_USER, DFT_SERVER_TARGET, and DFT_SERVER_WORK_ROOT.
Then run bash scripts/dft_server_setup_key.sh to create SSH key login.
Do not save my password. Use it only once to install the public key.
```

## Connect

After setup:

```bash
bash scripts/dft_server_setup_key.sh --verify-only
bash scripts/dft_server_status.sh
```

## Typical Use

Preview a project:

```bash
bash scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax
```

Generate inputs and a Slurm script:

```bash
bash scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax --write --yes
```

Submit after confirmation:

```bash
bash scripts/dft_server_dft_assist.sh --project FeS_relax --mode relax --submit --yes
```
