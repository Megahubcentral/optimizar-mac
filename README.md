📦 Clean Mac Optimizer 2025

🚀 AI-Powered macOS Maintenance Tool

Clean Mac Optimizer 2025 es una herramienta simple y profesional diseñada para ejecutar tareas de mantenimiento en macOS con un solo clic.
Incluye limpieza de cachés, reconstrucción de Spotlight, reinicio de DNS, reparación básica de permisos y más.
Ideal para usuarios que desean optimizar su Mac sin instalar aplicaciones de terceros.

⸻

✅ Características
	•	🧹 Limpieza automática de cachés y logs del sistema
	•	🔍 Reinicio y reconstrucción de Spotlight
	•	🖥️ Reconstrucción de Launch Services (arregla íconos duplicados y errores de apertura)
	•	🌐 Flush DNS para mejorar conexión
	•	🔐 Reparación básica de permisos de usuario
	•	📄 Registro detallado guardado automáticamente en ~/.optimizar-mac/
	•	⚡ Instalador que descarga siempre la última versión del script desde GitHub

⸻

📥 Descarga

Descarga el archivo DMG o ZIP desde la sección Releases de este repositorio.

El paquete contiene:
Clean Mac Optimizer 2025.app
How to Install.txt
CleanMacIcon.icns


🛠️ Instalación
	1.	Monta el DMG:
Clean Mac Optimizer 2025.dmg
	2.	Arrastra la aplicación a:
/Applications
	3.	Si macOS muestra una advertencia de seguridad:
Ve a System Settings → Privacy & Security → Allow Anyway
	4.	Ejecuta la app nuevamente → selecciona Open
	5.	En la primera ejecución, autoriza:
System Settings → Privacy & Security → Automation
→ Clean Mac Optimizer 2025 → Terminal

⸻

▶️ Cómo funciona

Al abrir la aplicación:
	1.	Lanza un instalador .command
	2.	Descarga automáticamente la última versión del script desde GitHub:
	https://raw.githubusercontent.com/Megahubcentral/optimizar-mac/main/optimizar_mac.sh
	3.	Ejecuta todas las tareas de optimización
	4.	Guarda un registro en:
	~/.optimizar-mac/optimizar_log_FECHA.log

	🧩 Estructura del proyecto

	/Clean Mac Optimizer 2025.app
  /Contents
    /MacOS
    /Resources
    Info.plist
    document.wflow   (Automator application workflow)
install.sh           (Instalador descargado por la app)
optimizar_mac.sh     (Script principal, alojado en GitHub)
README.md            (Este archivo)
How to Install.txt

⚠️ Requisitos
	•	macOS 10.9 o superior
	•	Conexión a internet (para descargar el script)
	•	Permisos de ejecución en Terminal

⸻

👨‍💻 Autor

Victor Santana (Lightchasing Company)
Con ayuda de IA (ChatGPT) para scripting avanzado y empaquetado.

⸻

📄 Licencia

Proyecto de uso personal.
No redistribuir sin permiso del autor.
