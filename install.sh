#!/bin/bash
#
# Instalador del optimizador de macOS (optimizar-mac)
#

set -e

RAW_BASE="https://raw.githubusercontent.com/Megahubcentral/optimizar-mac/refs/heads/main"
SCRIPT_NAME="optimizar_mac.sh"

WORKDIR="$HOME/.optimizar-mac"
mkdir -p "$WORKDIR"

echo "📥 Descargando script de optimización..."
curl -fsSL "$RAW_BASE/$SCRIPT_NAME" -o "$WORKDIR/$SCRIPT_NAME"

chmod +x "$WORKDIR/$SCRIPT_NAME"

LOGFILE="$WORKDIR/optimizar_$(date +%Y%m%d_%H%M%S).log"
echo "📄 El log se guardará en: $LOGFILE"
echo

echo "⚙️ Ejecutando optimización (se pedirá tu contraseña de administrador)..."
sudo "$WORKDIR/$SCRIPT_NAME" | tee "$LOGFILE"

echo
echo "✅ Proceso terminado."
echo "📂 Último log: $LOGFILE"
echo "💡 Recomendado: reiniciar tu Mac.
