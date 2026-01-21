#!/bin/bash
# vsw-security.sh - Biblioteca de validação e sanitização

# Cores padronizadas
R='\033[0;31m' # Red
G='\033[0;32m' # Green
Y='\033[1;33m' # Yellow
C='\033[0;36m' # Cyan
NC='\033[0m'   # No Color

#====== FUNÇÕES DE SANITIZAÇÃO ======#

# Lê e valida input do usuário
# Uso: ler_input "Prompt: " regex_tipo variavel_destino
ler_input() {
  local prompt="$1"
  local regex="$2"
  local -n __destino="$3" # ✅ PREFIXO __ EVITA CONFLITO

  while true; do
    read -rp "${prompt}" input

    # Remove espaços extras
    input="$(echo "$input" | sed 's/^[ \t]*//;s/[ \t]*$//')"

    if [[ -z "$input" ]]; then
      echo -e "${R}[ERRO]${NC} Valor não pode ser vazio!"
      continue
    fi

    if [[ "$input" =~ $regex ]]; then
      __destino="$input" # ✅ ATRIBUI VIA NAMEREF
      return 0
    else
      echo -e "${R}[ERRO]${NC} Formato inválido! Tente novamente."
    fi
  done
}

#====== FUNÇÃO PRINCIPAL DE INPUT SEGURO ======#
ler_input_validado() {
  local prompt="$1"
  local tipo="$2"
  local -n __dest_validado="$3" # ✅ NOME DIFERENTE

  case "$tipo" in
  ip)
    ler_input "$prompt" "$REGEX_IP" __dest_validado
    validar_ip "$__dest_validado" || return 1
    ;;
  porta)
    ler_input "$prompt" "$REGEX_PORTA" __dest_validado
    validar_porta "$__dest_validado" || return 1
    ;;
  protocolo | orcamento | interface | cidr)
    local regex_var="REGEX_${tipo^^}" # REGEX_PROTOCOLO, etc
    ler_input "$prompt" "${!regex_var}" __dest_validado
    ;;
  *)
    echo -e "${R}[ERRO]${NC} Tipo de validação desconhecido: $tipo"
    return 1
    ;;
  esac
  return 0
}

# Regex patterns predefinidos
REGEX_IP='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
REGEX_PORTA='^[0-9]{1,5}$'
REGEX_PROTOCOLO='^[a-zA-Z0-9._\-]{3,50}$'
REGEX_ORCAMENTO='^[a-zA-Z0-9._\-]{1,30}$'
REGEX_INTERFACE='^[a-zA-Z0-9._\-]{1,15}$'
REGEX_CIDR='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$'

# Validações específicas
validar_ip() {
  local ip="$1"
  if [[ "$ip" =~ $REGEX_IP ]]; then
    IFS='.' read -r -a octetos <<<"$ip"
    for octeto in "${octetos[@]}"; do
      ((octeto <= 255)) || return 1
    done
    return 0
  fi
  return 1
}

validar_porta() {
  local porta="$1"
  [[ "$porta" =~ $REGEX_PORTA ]] && ((porta >= 1 && porta <= 65535))
}
