#!/bin/zsh
#
# AI MAC OPTIMIZER – CORE SCRIPT v1.3 (SAFE)
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

# ==== DETECCIÓN DE USUARIO REAL (IMPORTANTE PARA SUDO) ====
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || id -un)}"
USER_HOME="/Users/$TARGET_USER"

banner() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║   ${BOLD}AI MAC OPTIMIZER – CORE SCRIPT v1.3${RESET}   ║"
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
    rm -rf "$USER_HOME/Library/Caches/"*
else
  warn "No se encontró $USER_HOME/Library/Caches (se omite limpieza de usuario)."
fi

spinner "Limpiando cachés de sistema..." \
  rm -rf /Library/Caches/*

# ==== 3. LIMPIEZA DE LOGS ====

section "LIMPIEZA DE LOGS"

spinner "Eliminando logs en /var/log..." \
  bash -c 'find /var/log -type f \( -name "*.log" -o -name "*.out" \) -delete 2>/dev/null'

# ==== 4. SPOTLIGHT ====

section "REINICIO DE SPOTLIGHT"

spinner "Desactivando indexación..." \
  mdutil -a -i off >/dev/null 2>&1 || true

rm -rf /.Spotlight-V100 2>/dev/null || true

spinner "Reactivando indexación..." \
  mdutil -a -i on >/dev/null 2>&1 || true

info "Spotlight reiniciado. El sistema volverá a indexar en segundo plano."

# ==== 5. LAUNCH SERVICES ====

section "RECONSTRUYENDO LAUNCH SERVICES"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ -x "$LSREGISTER" ]]; then
  spinner "Reconstruyendo Launch Services..." \
    "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices >/dev/null 2>&1
  info "Launch Services reconstruido (arregla problemas al abrir apps, iconos raros, etc.)."
else
  warn "No se encontró lsregister, se omite este paso."
fi

# ==== 6. DNS / RED ====

section "LIMPIEZA DE CACHÉ DNS"

spinner "Flusheando caché DNS..." \
  bash -c 'dscacheutil -flushcache 2>/dev/null; killall -HUP mDNSResponder 2>/dev/null || true'

# ==== 7. AJUSTE SUAVE DE PERMISOS (SAFE) ====

section "AJUSTE SUAVE DE PERMISOS DE USUARIO (SAFE)"

if [[ -d "$USER_HOME" ]]; then
  spinner "Aplicando permisos básicos de lectura/escritura en el home..." \
    bash -c "chmod -R u+rwX '$USER_HOME' 2>/dev/null || true"
  warn "No se ejecutó 'diskutil resetUserPermissions' para evitar reinicios automáticos."
else
  warn "No se encontró el home de $TARGET_USER en $USER_HOME. Se omite ajuste de permisos."
fi

# ==== 8. ANÁLISIS DE APPS PESADAS ====

section "ANÁLISIS DE APPS QUE MÁS CONSUMEN"

echo "${BOLD}Top 10 procesos por CPU:${RESET}"
ps aux | sort -nrk 3 | head -10
echo ""

echo "${BOLD}Top 10 procesos por RAM:${RESET}"
ps aux | sort -nrk 4 | head -10
echo ""

# ==== 9. CHEQUEO RÁPIDO DE PROCESOS SOSPECHOSOS ====

section "CHEQUEO RÁPIDO DE PROCESOS SOSPECHOSOS"

echo "Procesos ejecutando binarios desde /Users (revisar manualmente, no siempre son malos):"
ps aux | awk '$11 ~ /^\/Users\// {print}' | head -15 || true
echo ""
warn "Este chequeo NO reemplaza un antivirus, solo ayuda a identificar cosas raras."

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
  <p><strong>Usuario:</strong> $TARGET_USER</p>
  <p><strong>Home:</strong> $USER_HOME</p>

  <h2>Versión de macOS</h2>
  <pre>$(sw_vers)</pre>

  <h2>Uso de disco (después)</h2>
  <pre>$(df -h /)</pre>

  <h2>Top 10 procesos por CPU (después)</h2>
  <pre>$(ps aux | sort -nrk 3 | head -10)</pre>

  <h2>Top 10 procesos por RAM (después)</h2>
  <pre>$(ps aux | sort -nrk 4 | head -10)</pre>

  <h2>Procesos ejecutando desde /Users (sospechosos a revisar)</h2>
  <pre>$(ps aux | awk '\$11 ~ /^\/Users\// {print}' | head -30)</pre>

  <p class="warn">
    ⚠️ Este reporte es informativo. No reemplaza un antivirus ni una auditoría de seguridad profesional.
  </p>
</body>
</html>
EOF

info "Reporte HTML generado en: $HTMLREPORT"

echo ""
info "OPTIMIZACIÓN COMPLETA v1.3 (SAFE)."
warn "Recomendado: reiniciar tu Mac manualmente cuando te convenga para aplicar todos los cambios."
echo ""
