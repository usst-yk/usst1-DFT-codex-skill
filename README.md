# DFT Server Codex Skill

A Codex skill for managing a first-principles calculation server. It helps Codex:

- initialize SSH key login without saving passwords
- inspect server status
- generate and check VASP input files with VASPkit
- prepare and submit Slurm jobs
- work with VASP, Wannier90, WannierBerri, WannierTools, and WannSymm

This public version does not include any private server IP, port, username, password, or host-key fingerprint.

## Install With Codex

Open Codex and ask:

```text
Install this GitHub repository as a Codex skill:
<REPO_URL>

Install it as the skill named dft-server.
After installing, read SKILL.md and use the relevant agents/*.md file for the task.
```

Replace `<REPO_URL>` with this repository URL.

## Connect With Codex

After installation, ask Codex:

```text
Use the dft-server skill to configure my first-principles server.
Ask me for the SSH host, port, username, and remote work directory.
Then run scripts/dft_server_setup_key.sh to create SSH key login.
Do not save my password. Use it only once to install the public key.
After setup, verify the connection and run scripts/dft_server_status.sh.
```

Recommended values to give Codex:

```text
DFT_SERVER_HOST=<your server host>
DFT_SERVER_PORT=<your SSH port>
DFT_SERVER_USER=<your SSH username>
DFT_SERVER_TARGET=dft-server
DFT_SERVER_WORK_ROOT=<remote work directory, e.g. ~/codex>
```

Codex should use these values only in your local environment or local SSH config. They should not be committed to GitHub.

## Typical Codex Prompts

Generate a DFT calculation plan:

```text
Use dft-server. Create a relax calculation project named FeS_relax. First preview what files will be generated and what checks will run. Do not submit yet.
```

Generate inputs after confirming:

```text
Use dft-server. For project FeS_relax, generate the VASP relax input files and Slurm script. Do not submit.
```

Submit after checking:

```text
Use dft-server. Check project FeS_relax, then submit the relax job if the files are valid.
```

## Safety Notes

- Do not commit `.ssh` files, passwords, server IPs, ports, or usernames.
- Use `scripts/dft_server_setup_key.sh` for first-time SSH key setup.
- Use preview mode before writing files or submitting jobs.
- VASPkit task `109` can submit jobs on some servers; this skill does not use it as an automatic safe check.

## Files

```text
SKILL.md                  main entry point
agents/quickstart.md      common commands
agents/server.md          connection and server layout
agents/dft-assistant.md   DFT input generation workflow
agents/submission.md      Slurm submission checks
agents/vasp*.md           VASP and VASPkit guidance
agents/wannier*.md        Wannier workflows
scripts/*.sh              helper scripts used by Codex
```
