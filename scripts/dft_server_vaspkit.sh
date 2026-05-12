#!/usr/bin/env bash
set -euo pipefail

SSH_TARGET="${DFT_SERVER_TARGET:-dft-server}"

usage() {
  cat <<'USAGE'
Usage:
  dft_server_vaspkit.sh REMOTE_DIR --tasks "TASK_INPUT" [--run]
  dft_server_vaspkit.sh REMOTE_DIR --cmd-args "-task 102 -kpr 0.04" [--run]

Without --run, this only previews the action.
USAGE
}

remote_dir=""
tasks=""
cmd_args=""
run=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tasks) tasks="${2:?}"; shift 2 ;;
    --cmd-args) cmd_args="${2:?}"; shift 2 ;;
    --run) run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) if [[ -z "$remote_dir" ]]; then remote_dir="$1"; else echo "Unexpected argument: $1" >&2; exit 2; fi; shift ;;
  esac
done

[[ -n "$remote_dir" ]] || { usage >&2; exit 2; }
[[ -n "$tasks" || -n "$cmd_args" ]] || { usage >&2; exit 2; }
[[ -z "$tasks" || -z "$cmd_args" ]] || { echo "Use --tasks or --cmd-args, not both." >&2; exit 2; }

if [[ "$run" != 1 ]]; then
  echo "REMOTE_DIR=$remote_dir"
  echo "DRY_RUN=1"
  [[ -n "$cmd_args" ]] && echo "VASPkit command preview: vaspkit $cmd_args" || printf 'VASPkit input preview:\n%s\n' "$tasks"
  exit 0
fi

tasks_b64="$(printf '%s\n' "$tasks" | base64 | tr -d '\n')"
cmd_args_b64="$(printf '%s\n' "$cmd_args" | base64 | tr -d '\n')"

ssh -o StrictHostKeyChecking=accept-new "$SSH_TARGET" 'bash -s' -- "$remote_dir" "$tasks_b64" "$cmd_args_b64" <<'REMOTE'
set -euo pipefail
remote_dir="$1"
tasks_b64="$2"
cmd_args_b64="$3"
[[ -d "$remote_dir" ]] || { echo "Remote directory not found: $remote_dir" >&2; exit 1; }
cd "$remote_dir"
module load vaspkit/1.5.1 >/dev/null 2>&1 || true
if ! command -v vaspkit >/dev/null 2>&1; then
  export PATH="/opt/vaspkit/vaspkit.1.5.1/bin:$PATH"
fi
command -v vaspkit >/dev/null 2>&1 || { echo "vaspkit not found." >&2; exit 1; }
cmd_args="$(printf '%s' "$cmd_args_b64" | base64 -d)"
if [[ -n "$cmd_args" ]]; then
  read -r -a argv <<< "$cmd_args"
  vaspkit "${argv[@]}"
else
  printf '%s' "$tasks_b64" | base64 -d | vaspkit
fi
REMOTE
