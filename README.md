🧠 AI Mac Optimizer

Optimización inteligente para macOS (macOS 12 – macOS 15)

AI Mac Optimizer es una herramienta creada para diagnosticar, limpiar y optimizar tu Mac automáticamente.
Incluye limpieza profunda de cachés, reinicio de servicios, reparación de permisos, análisis de procesos y generación de reporte final.

⸻

🚀 Instalación rápida (1 solo comando)

Copia y pega en Terminal: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Megahubcentral/optimizar-mac/main/install.sh)"
Este comando:
	•	Descarga el instalador
	•	Instala el optimizador
	•	Ejecuta el proceso
	•	Genera un log detallado
	•	No requiere descargar archivos manualmente
	🧹 Funciones del Optimizer
	Función
Descripción
🔍 Diagnóstico del sistema
Versión macOS + uso de disco + procesos que más consumen CPU y RAM
🧹 Limpieza de cachés
Cachés de usuario y sistema
🧾 Limpieza de logs
Eliminación de archivos de logs acumulados
🔍 Reconstrucción Spotlight
Detiene, limpia e inicia nuevo índice Spotlight
🚀 Reparación de Launch Services
Soluciona problemas al abrir apps
🌐 Limpieza de DNS
Flushea el DNS para mejorar internet / conexiones
🔐 Reparación de permisos
Repara permisos del usuario
📊 Reporte final
Muestra estado antes y después de la optimización
📄 Archivos incluidos
Archivo
Función
optimizar_mac.sh
Script principal de optimización
install.sh
Instalador automático para cualquier Mac
⚠️ Requisitos
	•	macOS 12, 13, 14 o 15
	•	Conexión a internet
	•	Terminal + permisos de admin (sudo)
🧪 Cómo probarlo localmente
chmod +x optimizar_mac.sh
sudo ./optimizar_mac.sh
📝 Logs

El script genera un archivo log detallado en:
~/optimizar_mac_YYYYMMDD_HHMMSS.log
Puedes compartir este log para diagnóstico avanzado.

⸻

📦 Próximas mejoras (versión 2.0)
	•	Reporte HTML con gráficos de consumo
	•	Análisis de salud del disco (SMART)
	•	Escaneo de malware ligero
	•	Optimización de apps de inicio
	•	Panel web para ver estadísticas
	•	Modo “Safe Optimize” y modo “Deep Optimize”
	•	Interfaz gráfica (GUI) con SwiftUI

⸻

👨🏻‍💻 Autor

Proyecto desarrollado por Victor Santana
Optimizado y documentado con asistencia de AI (ChatGPT)
