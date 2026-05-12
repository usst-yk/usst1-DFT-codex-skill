#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_TARGET="${DFT_SERVER_TARGET:-dft-server}"
WORK_ROOT="${DFT_SERVER_WORK_ROOT:-codex}"

usage(){
  cat <<'USAGE'
Usage:
  dft_server_dft_assist.sh REMOTE_DIR --mode MODE [options]
  dft_server_dft_assist.sh --project NAME --mode MODE [options]

Modes:
  relax, scf, nscf, soc, wannier

Options:
  --structure FILE     POSCAR by default; CIF converts via VASPkit task 105
  --project NAME       use $DFT_SERVER_WORK_ROOT/NAME
  --kpr VALUE          KPOINTS resolution, default 0.04
  --kps G|M            default G
  --job NAME
  --cores N            default 60
  --time HH:MM:SS      default 2000:00:00
  --write              write inputs and Slurm script
  --submit             write inputs and submit
  --yes                required with --write or --submit
  --force              back up and replace existing INCAR/KPOINTS/POTCAR
USAGE
}

remote_dir=""; project=""; mode=""; structure="POSCAR"; kpr="0.04"; kps="G"; job=""; cores=60; time_limit="2000:00:00"; write=0; submit=0; yes=0; force=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) mode="${2:?}"; shift 2 ;;
    --structure) structure="${2:?}"; shift 2 ;;
    --project) project="${2:?}"; shift 2 ;;
    --kpr) kpr="${2:?}"; shift 2 ;;
    --kps) kps="${2:?}"; shift 2 ;;
    --job) job="${2:?}"; shift 2 ;;
    --cores) cores="${2:?}"; shift 2 ;;
    --time) time_limit="${2:?}"; shift 2 ;;
    --write) write=1; shift ;;
    --submit) write=1; submit=1; shift ;;
    --yes) yes=1; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) if [[ -z "$remote_dir" ]]; then remote_dir="$1"; else echo "Unexpected argument: $1" >&2; exit 2; fi; shift ;;
  esac
done

if [[ -n "$project" ]]; then
  [[ -z "$remote_dir" ]] || { echo "Use REMOTE_DIR or --project, not both." >&2; exit 2; }
  clean="${project// /_}"; clean="${clean//\//_}"
  remote_dir="$WORK_ROOT/$clean"
fi
[[ -n "$remote_dir" && -n "$mode" ]] || { usage >&2; exit 2; }
case "$mode" in relax|scf|nscf|soc|wannier) ;; *) echo "Unsupported mode: $mode" >&2; exit 2 ;; esac
[[ "$write" == 0 || "$yes" == 1 ]] || { echo "Refusing to write or submit without --yes." >&2; exit 2; }

ssh -o StrictHostKeyChecking=accept-new "$SSH_TARGET" 'bash -s' -- "$remote_dir" "$mode" "$structure" "$kpr" "$kps" "$write" "$force" <<'REMOTE'
set -euo pipefail
remote_dir="$1"; mode="$2"; structure="$3"; kpr="$4"; kps="$5"; write="$6"; force="$7"
die(){ echo "ERROR: $*" >&2; exit 1; }
warn(){ echo "WARN: $*" >&2; }

printf 'DFT_ASSIST_PLAN=1\nREMOTE_DIR=%s\nMODE=%s\nSTRUCTURE=%s\nKPOINTS=VASPkit task 102, kpr=%s, kps=%s\nPOTCAR=VASPkit task 103 if needed\nCHECK=internal file checks\n' "$remote_dir" "$mode" "$structure" "$kpr" "$kps"

if [[ "$write" != 1 ]]; then
  echo "DRY_RUN=1"
  echo "No files were written. Add --write --yes or --submit --yes after confirmation."
  exit 0
fi

mkdir -p "$remote_dir"
cd "$remote_dir"

if [[ "$mode" == nscf && ! -s CHGCAR ]]; then die "NSCF requires CHGCAR from prior SCF."; fi
if [[ "$mode" == wannier && ! -s wannier90.win ]]; then die "Wannier mode requires wannier90.win."; fi

module load vaspkit/1.5.1 >/dev/null 2>&1 || true
if ! command -v vaspkit >/dev/null 2>&1; then export PATH="/opt/vaspkit/vaspkit.1.5.1/bin:$PATH"; fi
command -v vaspkit >/dev/null 2>&1 || die "vaspkit not found"

backup(){ [[ -e "$1" ]] || return 0; stamp="$(date +%Y%m%d-%H%M%S)"; cp -a "$1" "$1.bak.$stamp"; }
for f in INCAR KPOINTS POTCAR; do [[ ! -e "$f" || "$force" == 1 ]] || die "$f exists; use --force"; backup "$f"; done

if [[ "$structure" != POSCAR ]]; then
  [[ -s "$structure" ]] || die "Missing structure file: $structure"
  backup POSCAR
  case "$structure" in *.cif|*.CIF) vaspkit -task 105 -file "$structure" > vaspkit_poscar.log 2>&1 ;; *) cp "$structure" POSCAR ;; esac
fi
[[ -s POSCAR ]] || die "POSCAR required"

case "$mode" in
  relax) cat > INCAR <<'EOF'
SYSTEM = DFT_RELAX
ENCUT = 520
PREC = Accurate
EDIFF = 1E-6
EDIFFG = -0.02
ISMEAR = 0
SIGMA = 0.05
IBRION = 2
NSW = 100
ISIF = 3
LREAL = Auto
LWAVE = .FALSE.
LCHARG = .TRUE.
EOF
    ;;
  scf) cat > INCAR <<'EOF'
SYSTEM = DFT_SCF
ENCUT = 520
PREC = Accurate
EDIFF = 1E-6
ISMEAR = 0
SIGMA = 0.05
IBRION = -1
NSW = 0
LREAL = Auto
LWAVE = .TRUE.
LCHARG = .TRUE.
EOF
    ;;
  nscf) cat > INCAR <<'EOF'
SYSTEM = DFT_NSCF
ENCUT = 520
PREC = Accurate
EDIFF = 1E-6
ISMEAR = 0
SIGMA = 0.05
IBRION = -1
NSW = 0
ICHARG = 11
LREAL = Auto
LWAVE = .TRUE.
LCHARG = .FALSE.
EOF
    ;;
  soc) cat > INCAR <<'EOF'
SYSTEM = DFT_SOC
ENCUT = 520
PREC = Accurate
EDIFF = 1E-6
ISMEAR = 0
SIGMA = 0.05
IBRION = -1
NSW = 0
LSORBIT = .TRUE.
LNONCOLLINEAR = .TRUE.
SAXIS = 0 0 1
LREAL = Auto
LWAVE = .TRUE.
LCHARG = .TRUE.
EOF
    ;;
  wannier) cat > INCAR <<'EOF'
SYSTEM = DFT_WANNIER
ENCUT = 520
PREC = Accurate
EDIFF = 1E-6
ISMEAR = 0
SIGMA = 0.05
IBRION = -1
NSW = 0
LWANNIER90 = .TRUE.
LWRITE_MMN_AMN = .TRUE.
LREAL = .FALSE.
LWAVE = .TRUE.
LCHARG = .TRUE.
EOF
    ;;
esac

vaspkit -task 102 -kpr "$kpr" -kps "$kps" > vaspkit_kpoints.log 2>&1
[[ -s POTCAR ]] || vaspkit -task 103 > vaspkit_potcar.log 2>&1
[[ -s INCAR && -s POSCAR && -s KPOINTS && -s POTCAR ]] || die "Input generation incomplete"
grep -Eq 'TITEL|PAW|VRHFIN|End of Dataset' POTCAR || warn "POTCAR does not look like a normal VASP POTCAR"
echo "FILES_READY=1"
REMOTE

submit_type=vasp-std
[[ "$mode" == soc ]] && submit_type=vasp-ncl
if [[ "$write" == 1 ]]; then
  args=("$remote_dir" --type "$submit_type" --cores "$cores" --time "$time_limit" --force)
  [[ -n "$job" ]] && args+=(--job "$job")
  if [[ "$submit" == 1 ]]; then
    "$SCRIPT_DIR/dft_server_submit.sh" "${args[@]}" --submit
  else
    "$SCRIPT_DIR/dft_server_submit.sh" "${args[@]}" --write-script
  fi
fi
