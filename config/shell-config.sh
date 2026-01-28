#!/usr/bin/env bash

printf "\n [vsw-info]: Iniciando script para configurar o ambiente da vsw-shell e seus comandos."

configurar_comandos() {
  local file_dir="$HOME/vsw-shell/config/arquivos"
  local src_dir="$HOME/vsw-shell/src/"
  # Criar diretório para bibliotecas
  sudo mkdir -p /usr/local/lib/vsw

  # Copiar biblioteca de segurança
  sudo cp -r $file_dir/src-sh/security.sh /usr/local/lib/vsw/security.sh
  sudo chmod 644 /usr/local/lib/vsw/security.sh

  # Copiar arquivo compilado da shell
  sudo cp -r $src_dir/out /usr/local/bin/vsw

  # Scripts Bash
  sudo cp -r $file_dir/src-sh/build.sh /usr/local/bin/build
  sudo cp -r $file_dir/src-sh/clean.sh /usr/local/bin/clean
  sudo cp -r $file_dir/src-sh/router.sh /usr/local/bin/roteador
  sudo cp -r $file_dir/src-sh/tvbox.sh /usr/local/bin/tvbox
  sudo cp -r $file_dir/src-sh/vsw-tools.sh /usr/local/bin/tools

  # Scripts Python
  sudo cp -r $file_dir/src-py/comparador.py /usr/local/bin/comparador.py
  sudo cp -r $file_dir/src-py/autometro.py /usr/local/bin/autometro.py
  sudo cp -r $file_dir/src-py/differ.py /usr/local/bin/differ.py
  sudo cp -r $file_dir/src-py/tablelo.py /usr/local/bin/tabela.py

  printf "\n [vsw-config]: Script finalizado com sucesso!"
}

instalar_dependencias() {
  local file_dir="$HOME/vsw-shell/config/arquivos"
  echo "[vsw-install]: Criando ambiente virtual python e instalando dependências..."
  uv venv && command -v source .venv/bin/activate
  uv pip install -r $file_dir/src-py/requisitos.txt
}

main() {
  configurar_comandos
  instalar_dependencias
}

main "$@"
