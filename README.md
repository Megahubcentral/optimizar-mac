Clean Mac Optimizer 2025

Optimizador avanzado para macOS creado por Victor Santana + ChatGPT.
Permite limpiar cachés, reiniciar servicios internos, reparar permisos, reiniciar Spotlight y mejorar el rendimiento general del sistema.

Instalación rápida

Ejecuta este comando en Terminal:
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/Megahubcentral/optimizar-mac/main/install.sh)
Características principales
	•	Limpieza segura de cachés de usuario y del sistema
	•	Reinicio completo de Spotlight
	•	Reconstrucción de Launch Services
	•	Flush de DNS
	•	Análisis de procesos que consumen CPU y RAM
	•	Reportes antes y después de la optimización
	•	Generación automática de logs
	•	Funcionamiento 100% automático con interfaz amigable
	•	Compatible con macOS moderno (Intel y Apple Silicon)

Instalación usando la app (versión gráfica)
	1.	Descargue el archivo DMG
	2.	Abra Clean Mac Optimizer 2025.dmg
	3.	Arrástrelo a su carpeta Aplicaciones
	4.	Abra la app
	5.	Si macOS bloquea la ejecución:
Preferencias del Sistema → Seguridad y Privacidad → “Permitir igualmente”

Estructura del proyecto
/Clean Mac Optimizer 2025.app/Contents
  /MacOS/Automator Application Stub
  /Resources/document.wflow
  /Resources/CleanMacIcon.icns
  Info.plist

  Scripts principales:
  install.sh
optimizar_mac.sh

Logs generados
Los logs se guardan automáticamente en:
~/.optimizar-mac/

Incluyen:
	•	Registro antes de la optimización
	•	Registro posterior
	•	Errores o advertencias detectadas

Uso avanzado:
sudo /bin/zsh ~/.optimizar-mac/optimizar_mac.sh

Autor

Creado por Victor Santana + ChatGPT
Repositorio oficial: https://github.com/Megahubcentral/optimizar-mac
