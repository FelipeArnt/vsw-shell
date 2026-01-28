#!/usr/bin/env bash
# |----|LABELO/VSW|----|@author:FelipeArnt|----|
#
# Ferramentas = nmap, talvez MITM, BURPSUITE

set -euo pipefail

# IMPORTAR BIBLIOTECA DE SEGURANÇA
source /usr/local/lib/vsw/security.sh || die "Biblioteca de segurança não encontrada!"

OUTPUT_DIR="coleta_roteador"
LOGFILE="${OUTPUT_DIR}/exec.log"

die() {
  echo -e "${R}[ERRO]${NC} $*" | tee -a "$LOGFILE"
  exit 1
}

log() { echo -e "${G}[INFO]${NC} $*" | tee -a "$LOGFILE"; }

uso() {
  cat <<EOF
Uso: $0 [-h] [-c]

  -h   Exibe esta ajuda
  -c   Limpa coleta_roteador anterior

EOF
  exit 0
}

while getopts "hc" opt; do
  case $opt in
  h) uso ;;
  c) rm -rf "$OUTPUT_DIR" ;;
  *) uso ;;
  esac
done

init_ensaio() {
  command -v nmap >/dev/null 2>&1 || die "Nmap não encontrado. Instale para prosseguir."
  mkdir -p "$OUTPUT_DIR" || die "Não foi possível criar o diretório..."

  # SANITIZAR INPUTS
  ler_input_validado "Digite o IP do dispositivo: " ip IP
  ler_input_validado "Digite o protocolo da amostra: " protocolo PROTOCOLO
  ler_input_validado "Digite o orçamento da amostra: " orcamento ORCAMENTO

  PREFIXO="$ORCAMENTO"
  log "Parâmetros validados: IP=$IP, Protocolo=$PROTOCOLO, Orçamento=$ORCAMENTO"
}

exec_ensaio() {
  log "Iniciando ensaios funcionais no dispositivo..."
  # APENAS usar variáveis já validadas
  sudo nmap -sV "$IP" >"${OUTPUT_DIR}/${PREFIXO}_sV.txt"
  sudo nmap -sV -webxml -oX vuln.xml -v --script vuln "$IP"
  sudo nmap -sV -webxml -oX vulners.xml -v --script vulners "$IP"
}

save_ensaio() {
  cat <<EOF >"${OUTPUT_DIR}/${PREFIXO}_resumo.json"
{
  "Protocolo": "$PROTOCOLO",
  "Orcamento": "$ORCAMENTO",
  "IP": "$IP"
}
EOF
  log "Ensaio funcional finalizado em ${OUTPUT_DIR}"
  log "Arquivos salvos com prefixo: ${PREFIXO}"
  exit 0
}

main() {
  init_ensaio
  exec_ensaio
  save_ensaio
}

main "$@"
