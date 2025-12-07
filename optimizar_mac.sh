#!/bin/zsh
#
# Script simple de diagnóstico y optimización para macOS
# Victor + ChatGPT
#

echo "============================================="
echo "  OPTIMIZACIÓN RÁPIDA DE MACOS"
echo "  Fecha: $(date)"
echo "============================================="
echo

# ==== 1. INFORME BÁSICO DEL SISTEMA ====

echo "🔎 INFORME DEL SISTEMA"
echo "----------------------"
echo "Versión de macOS:"
sw_vers
echo

echo "Uso de disco en /:"
df -h /
echo

echo "Top 5 procesos por CPU:"
ps aux | sort -nrk 3 | head -5
echo

echo "Top 5 procesos por RAM:"
ps aux | sort -nrk 4 | head -5
echo

# ==== 2. LIMPIEZA DE CACHÉS ====

echo "🧹 LIMPIEZA DE CACHÉS"
echo "----------------------"
echo "Limpiando cachés de usuario..."
rm -rf ~/Library/Caches/* 2>/dev/null
echo "Limpiando cachés de sistema..."
rm -rf /Library/Caches/* 2>/dev/null
echo "Cachés limpiadas."
echo

# ==== 3. LIMPIEZA DE LOGS ====

echo "🧾 LIMPIEZA DE LOGS"
echo "--------------------"
rm -rf /var/log/* 2>/dev/null
echo "Logs limpiados."
echo

# ==== 4. SPOTLIGHT ====

echo "🔍 REINICIANDO SPOTLIGHT"
echo "------------------------"
mdutil -a -i off 2>/dev/null
rm -rf /.Spotlight-V100 2>/dev/null
mdutil -a -i on 2>/dev/null
echo "Spotlight reiniciado."
echo

# ==== 5. LAUNCH SERVICES ====

echo "🚀 RECONSTRUYENDO LAUNCH SERVICES"
echo "---------------------------------"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
  "$LSREGISTER" -kill -seed -r /Applications /System/Applications /System/Library/CoreServices 2>/dev/null
  echo "Launch Services reconstruido."
else
  echo "No se encontró lsregister, se salta este paso."
fi
echo

# ==== 6. RED / DNS ====

echo "🌐 LIMPIANDO CACHÉ DNS"
echo "----------------------"
dscacheutil -flushcache 2>/dev/null
killall -HUP mDNSResponder 2>/dev/null
echo "DNS limpiado."
echo

# ==== 7. PERMISOS DE USUARIO ====

echo "🔐 RESETEANDO PERMISOS DE USUARIO"
echo "---------------------------------"
diskutil resetUserPermissions / $(id -u) 2>/dev/null
echo "Permisos de usuario reseteados (si no hubo errores)."
echo

# ==== 8. INFORME FINAL ====

echo "📊 INFORME FINAL"
echo "----------------"
df -h /
echo

echo "Top 5 procesos por CPU (después):"
ps aux | sort -nrk 3 | head -5
echo

echo "Top 5 procesos por RAM (después):"
ps aux | sort -nrk 4 | head -5
echo

echo "✅ OPTIMIZACIÓN COMPLETA."
echo "Recomendado: reiniciar tu Mac."
echo
