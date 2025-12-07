#!/bin/zsh
#
# AI MAC OPTIMIZER – CORE SCRIPT v1.3.1 (ZSH SAFE)
# Autor: Victor Santana + ChatGPT
#

set -e

# ==== COLORES ====
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# ==== RUTA DE TRABAJO ====
WORKDIR="$HOME/.optimizar-mac"
mkdir -p "$WORKDIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HTMLREPORT="$WORKDIR/reporte_${TIMESTAMP}.html"

# ==== USUARIO REAL ====
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || id -un)}"
USER_HOME="/Users/$TARGET_USER"

banner() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║   ${BOLD}AI MAC OPTIMIZER – CORE SCRIPT v1.3.1${RESET}  ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

section() {
  echo ""
  echo "${CYAN}➤ $1${RESET}"
  echo "----------------------------------------"
}

info()  { echo "${GREEN}[OK]${RESET} $1"; }
warn()  { echo "${YELLOW}[!]${RESET} $1"; }

# ==== SPINNER COMPATIBLE ZSH ====
spinner() {
  local msg="$1"
  shift
  local spin='|/-\\'
  local i=1

  echo -n "$msg "

  "$@" &>/dev/null &
  local pid=$!

  while kill -0 $pid 2>/dev/null; do
    printf "\b${spin:i++%4:1}"
    sleep 0.15
  done

  wait $pid
  echo -ne "\b"
  info "$msg"
}

# VALIDACIONES
if [[ "$(uname)" != "Darwin" ]]; then
  echo "[X] Solo funciona en macOS."
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "Debes ejecutar con sudo:"
  echo "sudo ./optimizar_mac.sh"
  exit 1
fi

banner

# ==== INFORME ====
section "INFORME INICIAL DEL SISTEMA"

echo "${BOLD}Fecha:${RESET} $(date)"
echo ""
sw_vers
echo ""

df -h /
echo ""

echo "${BOLD}Top CPU:${RESET}"
ps aux | sort -nrk 3 | head -5
echo ""

echo "${BOLD}Top RAM:${RESET}"
ps aux | sort -nrk 4 | head -5
echo ""

# ===========================================================
# ==========    LIMPIEZA DE CACHÉS CORREGIDA     ============
# ===========================================================

section "LIMPIEZA DE CACHÉS"

spinner "Limpiando cachés de usuario..." \
  bash -c "rm -rf \"$USER_HOME/Library/Caches\"/* 2>/dev/null || true"

spinner "Limpiando cachés de sistema..." \
  bash -c "rm -rf /Library/Caches/* 2>/dev/null || true"

# ==== LOGS ====
section "LIMPIEZA DE LOGS"

spinner "Eliminando logs..." \
  bash -c "find /var/log -type f -name '*.log' -delete 2>/dev/null || true"

# ==== SPOTLIGHT ====
section "REINICIO DE SPOTLIGHT"

spinner "Desactivando Spotlight..." mdutil -a -i off
rm -rf /.Spotlight-V100 2>/dev/null || true
spinner "Reactivando Spotlight..." mdutil -a -i on
info "Spotlight se reindexará en segundo plano."

# ==== LAUNCH SERVICES ====
section "RECONSTRUYENDO LAUNCH SERVICES"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ -x "$LSREGISTER" ]]; then
  spinner "Reconstruyendo Launch Services..." \
    "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices
else
  warn "No encontrado lsregister, se omite."
fi

# ==== DNS ====
section "LIMPIEZA DNS"
spinner "Flusheando DNS..." \
  bash -c "dscacheutil -flushcache; killall -HUP mDNSResponder"

# ==== PERMISOS SEGURIDAD ====
section "AJUSTE SUAVE DE PERMISOS (SAFE)"

spinner "Aplicando permisos básicos..." \
  bash -c "chmod -R u+rwX \"$USER_HOME\" 2>/dev/null || true"

warn "No se usa diskutil resetUserPermissions (evita reinicios)."

# ==== REPORTE FINAL ====
section "INFORME FINAL"

df -h /
echo ""
ps aux | sort -nrk 3 | head -5
echo ""
ps aux | sort -nrk 4 | head -5

info "Optimización finalizada sin reinicios."
warn "Puedes reiniciar manualmente para aplicar algunos cambios."
echo ""
