# Watchguard-Threatsync-Agent
Instalador de Threatsync NDR


# 🛡️ Instalador del Agente WatchGuard

Script interactivo en **Bash** para la instalación del **Agente WatchGuard** en sistemas **Ubuntu x86_64**, asegurando que todas las dependencias estén instaladas antes de ejecutar el instalador.

---

## ⚙️ Requisitos

- Sistema operativo: **Ubuntu 22.04 o 24.04** (arquitectura **x86_64**).  
- Idioma del sistema: **English** (solo se soporta este idioma).  
- Privilegios de **administrador (sudo)**.  
- Conectividad a Internet para descargar dependencias y el instalador del agente.

---

## 🚀 Instalación y uso

1. **Clonar el repositorio:**
   ```bash
   wget -O Watchguard_Agent.sh https://raw.githubusercontent.com/asotonet/Watchguard-Threatsync-Agent/main/Watchguard_Agent.sh
   chmod +x Watchguard_Agent.sh
   sudo ./Watchguard_Agent.sh
