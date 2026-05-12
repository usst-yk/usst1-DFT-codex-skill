#!/usr/bin/env bash
set -euo pipefail

HOST_ALIAS="${DFT_SERVER_TARGET:-dft-server}"
HOST="${DFT_SERVER_HOST:-}"
PORT="${DFT_SERVER_PORT:-}"
USER_NAME="${DFT_SERVER_USER:-}"
KEY_FILE="${DFT_SERVER_KEY_FILE:-$HOME/.ssh/dft_server_ed25519}"
CONFIG_FILE="${DFT_SERVER_SSH_CONFIG:-$HOME/.ssh/config}"

usage() {
  cat <<'USAGE'
Usage:
  dft_server_setup_key.sh [--verify-only] [--force-new-key]

Required environment for first setup:
  DFT_SERVER_HOST      server host or IP
  DFT_SERVER_PORT      SSH port
  DFT_SERVER_USER      SSH username

Optional:
  DFT_SERVER_TARGET    SSH alias, default dft-server
  DFT_SERVER_KEY_FILE  key path, default ~/.ssh/dft_server_ed25519
  DFT_SERVER_PASSWORD  one-time password for bootstrap; never saved
USAGE
}

force_new_key=0
verify_only=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-new-key) force_new_key=1; shift ;;
    --verify-only) verify_only=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$HOST" && -n "$PORT" && -n "$USER_NAME" ]] || {
  echo "Missing DFT_SERVER_HOST, DFT_SERVER_PORT, or DFT_SERVER_USER." >&2
  echo "Ask Codex to configure these for your server, then rerun." >&2
  exit 2
}

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
if ! grep -Eq "^[[:space:]]*Host[[:space:]]+$HOST_ALIAS([[:space:]]|$)" "$CONFIG_FILE"; then
  {
    printf '\nHost %s\n' "$HOST_ALIAS"
    printf '  HostName %s\n' "$HOST"
    printf '  Port %s\n' "$PORT"
    printf '  User %s\n' "$USER_NAME"
    printf '  IdentityFile %s\n' "$KEY_FILE"
    printf '  IdentitiesOnly yes\n'
  } >> "$CONFIG_FILE"
fi

verify_login() {
  ssh -o BatchMode=yes -o IdentitiesOnly=yes -i "$KEY_FILE" -p "$PORT" "$USER_NAME@$HOST" 'printf "KEY_LOGIN_OK "; hostname; whoami' 2>/dev/null
}

if [[ "$verify_only" == 1 ]]; then
  verify_login
  exit 0
fi

if [[ -e "$KEY_FILE" && "$force_new_key" == 1 ]]; then
  stamp="$(date +%Y%m%d-%H%M%S)"
  mv "$KEY_FILE" "$KEY_FILE.bak.$stamp"
  [[ -e "$KEY_FILE.pub" ]] && mv "$KEY_FILE.pub" "$KEY_FILE.pub.bak.$stamp"
fi

if [[ ! -e "$KEY_FILE" ]]; then
  ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "dft-server $(date +%Y-%m-%d)" >/dev/null
fi
chmod 600 "$KEY_FILE"
[[ -e "$KEY_FILE.pub" ]] || ssh-keygen -y -f "$KEY_FILE" > "$KEY_FILE.pub"
chmod 644 "$KEY_FILE.pub"

if verify_login; then
  echo "KEY_LOGIN_ALREADY_WORKS=1"
  exit 0
fi

command -v expect >/dev/null 2>&1 || {
  echo "expect is required for password bootstrap." >&2
  exit 1
}

password="${DFT_SERVER_PASSWORD:-}"
if [[ -z "$password" ]]; then
  if [[ -t 0 ]]; then
    read -r -s -p "DFT server password: " password
    printf '\n'
  else
    echo "Set DFT_SERVER_PASSWORD for this command or run interactively." >&2
    exit 1
  fi
fi

pub_key_b64="$(base64 < "$KEY_FILE.pub" | tr -d '\n')"
remote_cmd='pub_key="$(printf "%s" "$PUB_KEY_B64" | base64 -d)"; mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && grep -qxF "$pub_key" ~/.ssh/authorized_keys || printf "%s\n" "$pub_key" >> ~/.ssh/authorized_keys'

export DFT_SERVER_BOOTSTRAP_PASSWORD="$password"
export DFT_SERVER_BOOTSTRAP_PUB_KEY_B64="$pub_key_b64"
export DFT_SERVER_BOOTSTRAP_REMOTE_CMD="$remote_cmd"
export DFT_SERVER_BOOTSTRAP_HOST="$HOST"
export DFT_SERVER_BOOTSTRAP_PORT="$PORT"
export DFT_SERVER_BOOTSTRAP_USER="$USER_NAME"

expect <<'EOF'
set timeout 45
set password $env(DFT_SERVER_BOOTSTRAP_PASSWORD)
set pub_key_b64 $env(DFT_SERVER_BOOTSTRAP_PUB_KEY_B64)
set remote_cmd $env(DFT_SERVER_BOOTSTRAP_REMOTE_CMD)
set host $env(DFT_SERVER_BOOTSTRAP_HOST)
set port $env(DFT_SERVER_BOOTSTRAP_PORT)
set user $env(DFT_SERVER_BOOTSTRAP_USER)
spawn ssh -o StrictHostKeyChecking=accept-new -p $port $user@$host PUB_KEY_B64=$pub_key_b64 bash -lc $remote_cmd
expect {
  -re "(?i)password:" { send "$password\r"; exp_continue }
  eof
}
catch wait result
exit [lindex $result 3]
EOF
unset DFT_SERVER_BOOTSTRAP_PASSWORD

verify_login
