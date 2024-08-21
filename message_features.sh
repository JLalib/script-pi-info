#!/bin/bash

# Función para obtener información del sistema
get_system_info() {
    echo "***** Información del Sistema RPi 3B/4B *****"
    echo "%F0%9F%92%BB Hostname: $(hostname)"
    echo "%F0%9F%8D%93 Sistema Operativo: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "%E2%9A%A1 Memoria Total: $(free -h | awk '/^Mem:/ {print $2}')" "- Disponible: $(free -h | awk '/^Mem:/ {print $7}')"
    echo "%F0%9F%93%8A Uso de CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')"
    echo "%F0%9F%94%A5 Temperatura: $(/usr/bin/vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')"
    echo "%F0%9F%92%BE Uso de Disco:"
    df -h  /dev/mmcblk0p2
}

# Función para obtener la dirección IP pública
get_public_ip() {
    echo "***** Dirección IP Pública *****"
    curl ipinfo.io/ip
}

# Función para obtener usuarios logueados a través de SSH
get_ssh_users() {
    local ssh_users=$(who | grep "pts")
    if [ -n "$ssh_users" ]; then
        echo "***** Usuarios logueados por SSH *****"
        echo "$ssh_users"
    else
        echo "No hay usuarios logueados por SSH."
    fi
}

# Función para obtener usuarios logueados localmente
get_local_users() {
    local local_users=$(who | grep -v "pts")
    if [ -n "$local_users" ]; then
        echo "***** Usuarios logueados Localmente *****"
        echo "$local_users"
    else
        echo "No hay usuarios logueados localmente."
    fi
}

# Función para enviar el mensaje a Telegram
send_message() {
    local message="$1"
    local telegram_token="TOKEN:TELEGRAM"
    local chat_id="IDTELEGRAM"
    curl -s -X POST "https://api.telegram.org/bot${telegram_token}/sendMessage" \
        -d "chat_id=${chat_id}" \
        -d "text=${message}" \
        -d "parse_mode=Markdown" > /dev/null
}

# Obtener información del sistema
system_info=$(get_system_info)

# Obtener dirección IP pública
public_ip=$(get_public_ip)

# Obtener usuarios logados por SSH
ssh_users_info=$(get_ssh_users)

# Obtener usuarios logueados localmente
local_users_info=$(get_local_users)

# Construir el mensaje con saltos de línea
message=$(echo -e "$system_info\n$public_ip\n$ssh_users_info\n$local_users_info")

# Reemplazar saltos de línea por %0A para Telegram
message=$(echo "$message" | sed 's/$/%0A/g')

# Enviar mensaje a Telegram
send_message "$message"    
