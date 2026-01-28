#!/usr/bin/env bash

# Script para setup de ferramentas de Metrologia Legal / Anatel - VSW

set -e

DATA_DIR="/usr/local/share/vsw-shell"
URLS_FILE="$DATA_DIR/urls.txt"
PKGS_FILE="$DATA_DIR/pacotes.txt"

verificar_dependencias() {

  # Verifica se o git existe
  if ! command -v git &>/dev/null; then
    echo "[vsw-error]: O comando 'git' não foi encontrado. Instale o Git e tente novamente."
    exit 1
  fi

  # Verifica se os arquivos existem
  if [[ ! -f "$URLS_FILE" ]]; then
    echo "[vsw-error]: Arquivo '$URLS_FILE' não encontrado."
    exit 1
  fi

  if [[ ! -f "$PKGS_FILE" ]]; then
    echo "[vsw-error]: Arquivo '$PKGS_FILE' não encontrado."
    exit 1
  fi
}

instalar_ferramentas() {

  echo "[vsw-info]: Iniciando download das ferramentas..."

  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    echo "-----------------------------------------------------"
    echo "Clonando: $url"

    if git clone "$url"; then
      echo "Sucesso: Repositório clonado com êxito."
    else
      echo "AVISO: Falha ao clonar $url"
    fi

    echo "-----------------------------------------------------"
    echo
  done < "$URLS_FILE"

  echo "[vsw-info]: Instalando pacotes do sistema..."
  sudo pacman -Syyuu - < "$PKGS_FILE"

  echo "[vsw-success]: Setup vsw-linux finalizado!"
}

verificar_dependencias
instalar_ferramentas

