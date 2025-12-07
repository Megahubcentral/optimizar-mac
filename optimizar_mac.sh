#!/bin/zsh
#
# AI MAC OPTIMIZER – CORE SCRIPT v1.3.2 (ZSH SAFE)
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
  echo "║  ${BOLD}AI MAC OPTIMIZER – CORE SCRIPT v1.3.2${RESET}  ║"
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
error() { echo "${RED}[X]${RESET} $1"; }

# ==== SPINNER 100% COMPATIBLE CON ZSH ====
spinner() {
  local msg="$1"
  shift
  local frames=('|' '/' '-' '\\')
  local i=1

  echo -n "$msg "

  # Ejecuta el comando en segundo plano
  "$@" &>/dev/null &
  local pid=$!

  # Animación simple mientras el comando corre
  while kill -0 "$pid" 2>/dev/null; do
    printf "\b%s" "${frames[$i]}"
    i=$(( (i % 4) + 1 ))
    sleep 0.2
  done

  wait "$pid"
  echo -ne "\b"
  info "$msg"
}

# ==== VALIDACIONES BÁSICAS ====

if [[ "$(uname)" != "Darwin" ]]; then
  error "Este script solo funciona en macOS."
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  error "Debes ejecutar este script con sudo."
  echo "Ejemplo: sudo ./optimizar_mac.sh"
  exit 1
fi

banner

# ==== 1. INFORME INICIAL ====

section "INFORME INICIAL DEL SISTEMA"

echo "${BOLD}Fecha:${RESET} $(date)"
echo ""
echo "${BOLD}Usuario objetivo:${RESET} $TARGET_USER"
echo "${BOLD}Home:${RESET} $USER_HOME"
echo ""

echo "${BOLD}Versión de macOS:${RESET}"
sw_vers
echo ""

echo "${BOLD}Uso de disco en / (antes):${RESET}"
df -h /
echo ""

echo "${BOLD}Top 5 procesos por CPU (antes):${RESET}"
ps aux | sort -nrk 3 | head -5
echo ""

echo "${BOLD}Top 5 procesos por RAM (antes):${RESET}"
ps aux | sort -nrk 4 | head -5
echo ""

# ==== 2. LIMPIEZA DE CACHÉS ====

section "LIMPIEZA DE CACHÉS"

if [[ -d "$USER_HOME/Library/Caches" ]]; then
  spinner "Limpiando cachés de usuario..." \
    bash -c "rm -rf \"$USER_HOME/Library/Caches\"/* 2>/dev/null || true"
else
  warn "No se encontró $USER_HOME/Library/Caches, se omite."
fi

spinner "Limpiando cachés de sistema..." \
  bash -c "rm -rf /Library/Caches/* 2>/dev/null || true"

# ==== 3. LIMPIEZA DE LOGS ====

section "LIMPIEZA DE LOGS"

spinner "Eliminando logs en /var/log..." \
  bash -c "find /var/log -type f -name '*.log' -delete 2>/dev/null || true"

# ==== 4. SPOTLIGHT ====

section "REINICIO DE SPOTLIGHT"

spinner "Desactivando indexación..." \
  mdutil -a -i off

rm -rf /.Spotlight-V100 2>/dev/null || true

spinner "Reactivando indexación..." \
  mdutil -a -i on

info "Spotlight se reindexará en segundo plano."

# ==== 5. LAUNCH SERVICES ====

section "RECONSTRUYENDO LAUNCH SERVICES"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ -x "$LSREGISTER" ]]; then
  spinner "Reconstruyendo Launch Services..." \
    "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices
else
  warn "No se encontró lsregister, se omite este paso."
fi

# ==== 6. DNS ====

section "LIMPIEZA DE CACHÉ DNS"

spinner "Flusheando caché DNS..." \
  bash -c "dscacheutil -flushcache; killall -HUP mDNSResponder 2>/dev/null || true"

# ==== 7. AJUSTE SUAVE DE PERMISOS ====

section "AJUSTE SUAVE DE PERMISOS (SAFE)"

if [[ -d "$USER_HOME" ]]; then
  spinner "Aplicando permisos básicos en el home..." \
    bash -c "chmod -R u+rwX \"$USER_HOME\" 2>/dev/null || true"
  warn "No se ejecuta 'diskutil resetUserPermissions' para evitar reinicios automáticos."
else
  warn "No se encontró el home de $TARGET_USER en $USER_HOME."
fi

# ==== 8. ANÁLISIS DE PROCESOS PESADOS ====

section "ANÁLISIS DE PROCESOS QUE MÁS CONSUMEN"

echo "${BOLD}Top 10 procesos por CPU:${RESET}"
ps aux | sort -nrk 3 | head -10
echo ""

echo "${BOLD}Top 10 procesos por RAM:${RESET}"
ps aux | sort -nrk 4 | head -10
echo ""

# ==== 9. PROCESOS SOSPECHOSOS ====

section "CHEQUEO RÁPIDO DE PROCESOS DESDE /Users"

echo "Procesos ejecutando binarios desde /Users (revisar manualmente):"
ps aux | awk '$11 ~ /^\/Users\// {print}' | head -20 || true
echo ""
warn "Este chequeo no reemplaza un antivirus; solo ayuda a ver cosas raras."

# ==== 10. INFORME FINAL EN TERMINAL ====

section "INFORME FINAL"

echo "${BOLD}Uso de disco en / (después):${RESET}"
df -h /
echo ""

echo "${BOLD}Top 5 procesos por CPU (después):${RESET}"
ps aux | sort -nrk 3 | head -5
echo ""

echo "${BOLD}Top 5 procesos por RAM (después):${RESET}"
ps aux | sort -nrk 4 | head -5
echo ""

info "Optimización completada (v1.3.2, zsh safe)."
warn "Puedes reiniciar tu Mac manualmente cuando te convenga para aplicar todos los cambioss."
echo ""
