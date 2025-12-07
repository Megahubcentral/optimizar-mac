#!/bin/zsh
#
# AI MAC OPTIMIZER – CORE SCRIPT v1.2
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

# ==== RUTA DE TRABAJO / REPORTES ====
WORKDIR="$HOME/.optimizar-mac"
mkdir -p "$WORKDIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HTMLREPORT="$WORKDIR/reporte_${TIMESTAMP}.html"

banner() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║   ${BOLD}AI MAC OPTIMIZER – CORE SCRIPT v1.2${RESET}   ║"
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

spinner() {
  # Uso: spinner "Mensaje" comando arg1 arg2...
  local msg="$1"
  shift
  echo -n "$msg "
  "$@" &
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    printf " [%c]\r" "${spin:i++%4:1}"
    sleep 0.2
    printf "\r$msg "
  done
  wait $pid
  local status=$?
  if [ $status -eq 0 ]; then
    printf "    \r"
    info "$msg completado."
  else
    printf "    \r"
    warn "$msg terminó con código $status (revisar)."
  fi
}

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

echo "${BOLD}Fecha:${RESET} $(date)"
echo

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

spinner "Limpiando cachés de usuario..." \
  rm -rf /Users/"$SUDO_USER"/Library/Caches/*

spinner "Limpiando cachés de sistema..." \
  rm -rf /Library/Caches/*

# ==== 3. LIMPIEZA DE LOGS ====

section "LIMPIEZA DE LOGS"

spinner "Eliminando logs en /var/log..." \
  bash -c 'find /var/log -type f \( -name "*.log" -o -name "*.out" \) -delete 2>/dev/null'

# ==== 4. SPOTLIGHT ====

section "REINICIO DE SPOTLIGHT"

spinner "Desactivando indexación..." \
  mdutil -a -i off >/dev/null 2>&1

rm -rf /.Spotlight-V100 2>/dev/null || true

spinner "Reactivando indexación..." \
  mdutil -a -i on >/dev/null 2>&1

info "Spotlight reiniciado. El sistema volverá a indexar en segundo plano."

# ==== 5. LAUNCH SERVICES ====

section "RECONSTRUYENDO LAUNCH SERVICES"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ -x "$LSREGISTER" ]]; then
  spinner "Reconstruyendo Launch Services..." \
    "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices >/dev/null 2>&1
  info "Launch Services reconstruido (abre apps y iconos más estables)."
else
  warn "No se encontró lsregister, se omite este paso."
fi

# ==== 6. DNS / RED ====

section "LIMPIEZA DE CACHÉ DNS"

spinner "Flusheando caché DNS..." \
  bash -c 'dscacheutil -flushcache 2>/dev/null; killall -HUP mDNSResponder 2>/dev/null || true'

# ==== 7. PERMISOS DE USUARIO ====

section "RESETEO BÁSICO DE PERMISOS DE USUARIO"

spinner "Reseteando permisos de usuario..." \
  diskutil resetUserPermissions / "$(id -u "$SUDO_USER")" >/dev/null 2>&1

# ==== 8. ANÁLISIS DE APPS PESADAS ====

section "ANÁLISIS DE APPS QUE MÁS CONSUMEN"

echo "${BOLD}Top 10 procesos por CPU:${RESET}"
ps aux | sort -nrk 3 | head -10
echo ""

echo "${BOLD}Top 10 procesos por RAM:${RESET}"
ps aux | sort -nrk 4 | head -10
echo ""

# ==== 9. CHEQUEO RÁPIDO (NO DEFINITIVO) DE PROCESOS SOSPECHOSOS ====

section "CHEQUEO RÁPIDO DE PROCESOS SOSPECHOSOS"

echo "Procesos ejecutando binarios desde /Users (revisar manualmente, no siempre son malos):"
ps aux | awk '$11 ~ /^\/Users\// {print}' | head -15 || true
echo ""
warn "Este chequeo NO reemplaza un antivirus, solo ayuda a identificar cosas raras."

# ==== 10. INFORME FINAL ====

section "INFORME FINAL EN TERMINAL"

echo "${BOLD}Uso de disco en / (después):${RESET}"
df -h /
echo ""

echo "${BOLD}Top 5 procesos por CPU (después):${RESET}"
ps aux | sort -nrk 3 | head -5
echo ""

echo "${BOLD}Top 5 procesos por RAM (después):${RESET}"
ps aux | sort -nrk 4 | head -5
echo ""

# ==== 11. REPORTE HTML ====

section "GENERANDO REPORTE HTML"

cat > "$HTMLREPORT" <<EOF
<html>
<head>
  <meta charset="utf-8">
  <title>AI Mac Optimizer Report - $TIMESTAMP</title>
  <style>
    body { font-family: -apple-system, system-ui, sans-serif; background:#111; color:#eee; padding:20px; }
    h1,h2 { color:#4ade80; }
    pre { background:#000; padding:10px; border-radius:6px; overflow-x:auto; }
    .warn { color:#facc15; }
  </style>
</head>
<body>
  <h1>AI Mac Optimizer – Reporte</h1>
  <p><strong>Fecha:</strong> $(date)</p>
  <h2>Versión de macOS</h2>
  <pre>$(sw_vers)</pre>

  <h2>Uso de disco (después)</h2>
  <pre>$(df -h /)</pre>

  <h2>Top 10 procesos por CPU (después)</h2>
  <pre>$(ps aux | sort -nrk 3 | head -10)</pre>

  <h2>Top 10 procesos por RAM (después)</h2>
  <pre>$(ps aux | sort -nrk 4 | head -10)</pre>

  <h2>Procesos ejecutando desde /Users (sospechosos a revisar)</h2>
  <pre>$(ps aux | awk '$11 ~ /^\/Users\// {print}' | head -30)</pre>

  <p class="warn">
    ⚠️ Este reporte es informativo. No reemplaza un antivirus ni una auditoría de seguridad profesional.
  </p>
</body>
</html>
EOF

info "Reporte HTML generado en: $HTMLREPORT"

echo ""
info "OPTIMIZACIÓN COMPLETA v1.2."
warn "Recomendado: reiniciar tu Mac para aplicar todos los cambios."
echo ""
