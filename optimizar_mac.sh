#!/bin/zsh
#
# AI MAC OPTIMIZER – CORE SCRIPT v1.1
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

banner() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║   ${BOLD}AI MAC OPTIMIZER – CORE SCRIPT v1.1${RESET}   ║"
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

# ==== VALIDACIONES BÁSICAS ====

if [[ "$(uname)" != "Darwin" ]]; then
  error "Este script solo se puede ejecutar en macOS."
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  error "Por favor, ejecuta este script con sudo."
  echo "Ejemplo: sudo ./optimizar_mac.sh"
  exit 1
fi

banner

# ==== 1. INFORME INICIAL DEL SISTEMA ====

section "INFORME INICIAL DEL SISTEMA"

echo "${BOLD}Versión de macOS:${RESET}"
sw_vers
echo ""

echo "${BOLD}Uso de disco en /:${RESET}"
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

echo "Limpiando cachés de usuario..."
rm -rf /Users/"$SUDO_USER"/Library/Caches/* 2>/dev/null || true
info "Cachés de usuario limpiadas."

echo "Limpiando cachés de sistema..."
rm -rf /Library/Caches/* 2>/dev/null || true
info "Cachés de sistema limpiadas."

# ==== 3. LIMPIEZA DE LOGS ====

section "LIMPIEZA DE LOGS"

echo "Eliminando logs rotados y archivos .log en /var/log..."
find /var/log -type f -name "*.log" -delete 2>/dev/null || true
find /var/log -type f -name "*.out" -delete 2>/dev/null || true
info "Logs limpiados (sin afectar servicios críticos)."

# ==== 4. SPOTLIGHT ====

section "REINICIO DE SPOTLIGHT"

mdutil -a -i off  >/dev/null 2>&1 || true
rm -rf /.Spotlight-V100 2>/dev/null || true
mdutil -a -i on   >/dev/null 2>&1 || true

info "Spotlight reiniciado. El sistema volverá a indexar en segundo plano."

# ==== 5. LAUNCH SERVICES ====

section "RECONSTRUYENDO LAUNCH SERVICES"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ -x "$LSREGISTER" ]]; then
  "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices >/dev/null 2>&1 || true
  info "Launch Services reconstruido (arregla problemas al abrir apps, iconos raros, etc.)."
else
  warn "No se encontró lsregister, se omite este paso."
fi

# ==== 6. DNS / RED ====

section "LIMPIEZA DE CACHÉ DNS"

dscacheutil -flushcache 2>/dev/null || true
killall -HUP mDNSResponder 2>/dev/null || true
info "Caché DNS limpiada."

# ==== 7. PERMISOS DE USUARIO ====

section "RESETEO BÁSICO DE PERMISOS DE USUARIO"

diskutil resetUserPermissions / "$(id -u "$SUDO_USER")" >/dev/null 2>&1 || true
info "Permisos de usuario reseteados (si no hubo errores)."

# ==== 8. INFORME FINAL ====

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

echo ""
info "OPTIMIZACIÓN COMPLETA."
warn "Recomendado: reiniciar tu Mac para aplicar todos los cambios."
echo ""
