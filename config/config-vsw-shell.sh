#!/usr/bin/env bash

echo "[vsw-info]: Iniciando script para configurar o ambiente da vsw-shell e seus comandos."

configurar_comandos() {
  # Criar diretório para bibliotecas
  sudo mkdir -p /usr/local/lib/vsw

  # Copiar biblioteca de segurança (NOVA LINHA)
  sudo cp -r src-sh/security.sh /usr/local/lib/vsw/security.sh
  sudo chmod 644 /usr/local/lib/vsw/security.sh

  # Copiar arquivo compilado da shell
  sudo cp -r ../src/out /usr/local/bin/vsw

  # Scripts Bash
  sudo cp -r src-sh/build.sh /usr/local/bin/build
  sudo cp -r src-sh/clean.sh /usr/local/bin/clean
  sudo cp -r src-sh/router.sh /usr/local/bin/roteador
  sudo cp -r src-sh/tvbox.sh /usr/local/bin/tvbox
  sudo cp -r src-sh/vsw-tools.sh /usr/local/bin/tools

  # Scripts Python
  sudo cp -r src-py/comparador.py /usr/local/bin/comparador.py
  sudo cp -r src-py/autometro.py /usr/local/bin/autometro.py
  sudo cp -r src-py/differ.py /usr/local/bin/differ.py
  sudo cp -r src-py/tablelo.py /usr/local/bin/tabela.py

  echo "Script finalizado com sucesso!"
}

instalar_dependencias() {
  echo "[vsw-install]: Criando ambiente virtual python e instalando dependências..."
  uv venv && source .venv/bin/activate
  uv pip install -r src-py/requisitos.txt
}

main() {
  configurar_comandos
  instalar_dependencias
}

main "$@"
