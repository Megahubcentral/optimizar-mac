#!/bin/bash
#
# AI MAC OPTIMIZER – INSTALLER v1.1
# Descarga y ejecuta el optimizador en cualquier Mac
#

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/Megahubcentral/optimizar-mac/refs/heads/main"
SCRIPT_NAME="optimizar_mac.sh"

# ==== FUNCIONES DE OUTPUT ====

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

info()  { printf "${GREEN}[OK]${RESET} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${RESET} %s\n" "$1"; }
error() { printf "${RED}[X]${RESET} %s\n" "$1"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ${BOLD}AI MAC OPTIMIZER – INSTALLER v1.1${RESET}    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ==== VALIDACIONES ====

if [[ "$(uname)" != "Darwin" ]]; then
  error "Este instalador solo funciona en macOS."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  error "curl no está disponible. Instálalo primero (Xcode Command Line Tools)."
  exit 1
fi

# ==== DIRECTORIO DE TRABAJO ====

WORKDIR="$HOME/.optimizar-mac"
mkdir -p "$WORKDIR"

info "Directorio de trabajo: $WORKDIR"

# ==== DESCARGAR SCRIPT PRINCIPAL ====

SCRIPT_URL="$RAW_BASE/$SCRIPT_NAME"

echo "📥 Descargando script de optimización desde:"
echo "   $SCRIPT_URL"
echo ""

curl -fsSL "$SCRIPT_URL" -o "$WORKDIR/$SCRIPT_NAME"

if [[ ! -s "$WORKDIR/$SCRIPT_NAME" ]]; then
  error "El archivo descargado está vacío o falló la descarga."
  exit 1
fi

chmod +x "$WORKDIR/$SCRIPT_NAME"
info "Script descargado y marcado como ejecutable."

# ==== CONFIRMACIÓN DEL USUARIO ====

echo ""
warn "Este script realizará tareas de mantenimiento:"
echo "  - Limpieza de cachés y logs"
echo "  - Reinicio de Spotlight"
echo "  - Reconstrucción de Launch Services"
echo "  - Limpieza de DNS"
echo "  - Reseteo básico de permisos de usuario"
echo ""

read -r -p "¿Deseas continuar con la optimización ahora? [s/N]: " RESP

case "$RESP" in
  [sS]|[sS][iI])
    echo ""
    info "Iniciando optimización..."
    ;;
  *)
    warn "Operación cancelada por el usuario."
    exit 0
    ;;
esac

# ==== EJECUCIÓN CON LOG ====

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$WORKDIR/optimizar_log_${TIMESTAMP}.log"

echo ""
info "Se generará un log detallado en:"
echo "   $LOGFILE"
echo ""

# Usamos zsh explícitamente para asegurarnos de que respete el shebang
sudo /bin/zsh "$WORKDIR/$SCRIPT_NAME" | tee "$LOGFILE"

echo ""
info "Proceso terminado."
warn "Log guardado en: $LOGFILE"
warn "Recomendado: reiniciar tu Mac."
echo ""
