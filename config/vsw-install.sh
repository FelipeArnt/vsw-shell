#!/bin/bash

# Script para setup de ferramentas de Metrologia Legal/Anatel - VSW

verificar_dependencias() {

  local files_dir="$HOME/vsw-shell/config/arquivos/"
  local urls_file="$files_dir/urls.txt"
  local pkgs_file="$files_dir/pacotes.txt"

  # 1. Verifica se o comando git existe no sistema
  if ! command -v git &>/dev/null; then
    echo "[vsw-error]: O comando 'git' não foi encontrado. Por favor, instale o Git e tente novamente."
    exit 1
  fi

  # 2. Verifica se o arquivo de URLs existe
  if [ ! -f "$urls_file" ]; then
    echo "ERRO: O arquivo '$urls_file' não foi encontrado no diretório atual."
    echo "Por favor, crie este arquivo com as URLs dos repositórios, uma por linha."
    exit 1
  fi
}

instalar_ferramentas() {

  local files_dir="$HOME/vsw-shell/config/arquivos"
  local urls_file="$files_dir/urls.txt"
  local pkgs_file="$files_dir/pacotes.txt"

  echo 'Iniciando download das ferramentas...'
  # 3. Lê o arquivo linha por linha
  while IFS= read -r url || [ -n "$url" ]; do
    # 4. Ignora linhas em branco ou comentários (que começam com #)
    if [[ -z "$url" || "$url" == \#* ]]; then
      continue
    fi

    echo "-----------------------------------------------------"
    echo "Clonando: $url"

    # 5. Executa o git clone e verifica se houve erro
    if cd $HOME && git clone "$url"; then
      echo "Sucesso: Repositório clonado com êxito."
    else
      echo "AVISO: Falha ao clonar o repositório $url. Verifique a URL ou sua conexão."
    fi
    echo "-----------------------------------------------------"
    echo
  done <"$urls_file"

  sudo pacman -Syyuu - <$pkgs_file

  echo "Setup vsw-linux finalizado!"
}
# Chama a função para iniciar o processo de setup
verificar_dependencias
instalar_ferramentas
