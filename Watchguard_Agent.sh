#!/bin/bash
# ==============================================
# Script de instalación y mantenimiento del Agente WatchGuard
# Autor: Ale Soto
# Fecha: 2025-10-07
# ==============================================

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Verificar si se ejecuta con privilegios de root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Por favor, ejecute este script con privilegios de administrador (sudo).${RESET}"
  exit 1
fi

# Función: instalar dependencias necesarias
install_dependencies() {
  echo -e "${CYAN}\n[+] Verificando dependencias necesarias...\n${RESET}"
  MISSING=()

  for pkg in curl gnupg lsb-release ca-certificates wget; do
    if ! command -v "$pkg" &> /dev/null; then
      MISSING+=("$pkg")
    fi
  done

  if [ ${#MISSING[@]} -eq 0 ]; then
    echo -e "${GREEN}✔ Todas las dependencias están instaladas.${RESET}"
    sleep 1
  else
    echo -e "${YELLOW}Instalando dependencias faltantes: ${MISSING[*]}${RESET}"
    apt update -y
    apt install -y "${MISSING[@]}"
    echo -e "${GREEN}Dependencias instaladas correctamente.${RESET}"
    sleep 1
  fi
}

# Función: instalar agente
install_agent() {
  # Forzar verificación de dependencias antes de continuar
  install_dependencies

  echo -e "${CYAN}\n[+] Instalación del Agente WatchGuard${RESET}"
  read -p "Pegue la URL del instalador (.run): " INSTALL_URL

  if [[ -z "$INSTALL_URL" ]]; then
    echo -e "${RED}Error: no se proporcionó una URL válida.${RESET}"
    return
  fi

  echo -e "${GREEN}Descargando instalador...${RESET}"
  wget -O Watchguard_Agent.run "$INSTALL_URL"
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al descargar el instalador.${RESET}"
    return
  fi

  chmod +x Watchguard_Agent.run
  echo -e "${GREEN}Ejecutando instalador...${RESET}"
  ./Watchguard_Agent.run

  echo -e "${YELLOW}\n[+] Verificando instalación del servicio AgentSvc...${RESET}"
  ps ax | grep AgentSvc | grep -v grep
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ El proceso AgentSvc está en ejecución.${RESET}"
  else
    echo -e "${RED}✖ No se detectó el proceso AgentSvc en ejecución.${RESET}"
  fi

  echo -e "${YELLOW}\n[+] Verificando directorio de instalación...${RESET}"
  if [ -d /usr/local/management-agent ]; then
    echo -e "${GREEN}✔ El directorio /usr/local/management-agent existe.${RESET}"
  else
    echo -e "${RED}✖ El directorio /usr/local/management-agent no se encontró.${RESET}"
  fi

  echo -e "${YELLOW}\nAgrega el agente al > Threatsync+ NDR para continuar...${RESET}"

}

# Función: ejecutar diagnóstico manual
run_diagnostics() {
  if [ -f /opt/collector/scripts/collectorDiagnostics.sh ]; then
    echo -e "${GREEN}Ejecutando diagnósticos del colector...${RESET}"
    /opt/collector/scripts/collectorDiagnostics.sh
    echo -e "\n ---------- \n --------- \n"
    cat /opt/collector/logs/*.log
  else
    echo -e "${RED}No se encontró el script collectorDiagnostics.sh.${RESET}"
  fi
}

# Menú principal
while true; do
  echo -e "\n${GREEN}=== Menú Principal WatchGuard Agent ===${RESET}"
  echo "1) Instalar agente"
  echo "2) Ejecutar diagnósticos"
  echo "3) Salir"
  echo
  read -p "Seleccione una opción [1-3]: " opt

  case $opt in
    1) install_agent ;;
    2) run_diagnostics ;;
    3)
      echo -e "${YELLOW}Saliendo del instalador...${RESET}"
      exit 0
      ;;
    *)
      echo -e "${RED}Opción inválida. Intente nuevamente.${RESET}"
      ;;
  esac
done
