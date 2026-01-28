#!/usr/bin/env bash

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detecta o diretório base do projeto (onde está o script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FILES_DIR="$PROJECT_ROOT/config/arquivos"

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERRO]${NC} $1"
}

verificar_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "Este script precisa ser executado com sudo ou como root"
    exit 1
  fi
}

verificar_dependencias() {
  log_info "Verificando dependências..."

  if ! command -v git &>/dev/null; then
    log_error "Git não encontrado. Instale: sudo pacman -S git"
    exit 1
  fi

  if ! command -v uv &>/dev/null; then
    log_warn "UV não encontrado. Tentando instalar..."
    curl -LsSf https://astral.sh/uv/install.sh | sh || {
      log_error "Falha ao instalar UV. Instale manualmente: curl -LsSf https://astral.sh/uv/install.sh | sh"
      exit 1
    }
  fi

  if [[ ! -d "$FILES_DIR" ]]; then
    log_error "Diretório de arquivos não encontrado: $FILES_DIR"
    log_error "Certifique-se de executar o script a partir do diretório do projeto"
    exit 1
  fi
}

instalar_pacotes_sistema() {
  local pkgs_file="$FILES_DIR/pacotes.txt"

  if [[ ! -f "$pkgs_file" ]]; then
    log_warn "Arquivo de pacotes não encontrado: $pkgs_file"
    return
  fi

  log_info "Instalando pacotes do sistema via pacman..."

  # Remove linhas vazias e comentários, depois instala
  grep -v '^#' "$pkgs_file" | grep -v '^$' | sed 's/[[:space:]]*#.*//' >/tmp/pacotes_filtrados.txt

  if [[ -s /tmp/pacotes_filtrados.txt ]]; then
    pacman -Syyuu --needed --noconfirm $(cat /tmp/pacotes_filtrados.txt) || {
      log_error "Falha ao instalar pacotes do sistema"
      exit 1
    }
  else
    log_warn "Nenhum pacote válido encontrado em $pkgs_file"
  fi
}

clonar_repositorios() {
  local urls_file="$FILES_DIR/urls.txt"

  if [[ ! -f "$urls_file" ]]; then
    log_warn "Arquivo urls.txt não encontrado. Pulando clonagem."
    return
  fi

  log_info "Clonando repositórios adicionais..."

  local clone_dir="$PROJECT_ROOT/../ferramentas-externas"
  mkdir -p "$clone_dir"

  while IFS= read -r url || [[ -n "$url" ]]; do
    # Ignora comentários e linhas vazias
    [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue

    log_info "Clonando: $url"

    local repo_name=$(basename "$url" .git)
    if [[ -d "$clone_dir/$repo_name" ]]; then
      log_warn "Diretório $repo_name já existe, pulando..."
      continue
    fi

    if git clone "$url" "$clone_dir/$repo_name" 2>/dev/null; then
      log_info "✓ $repo_name clonado com sucesso"
    else
      log_warn "✗ Falha ao clonar $url (continuando...)"
    fi
  done <"$urls_file"
}

configurar_comandos() {
  log_info "Configurando comandos do sistema..."

  local file_dir="$FILES_DIR"

  # Cria diretórios necessários
  mkdir -p /usr/local/lib/vsw
  mkdir -p /usr/local/bin

  # Copia biblioteca de segurança
  if [[ -f "$file_dir/sh/security.sh" ]]; then
    cp "$file_dir/sh/security.sh" /usr/local/lib/vsw/
    chmod 644 /usr/local/lib/vsw/security.sh
    log_info "✓ security.sh instalado"
  fi

  # Copia binário compilado (se existir)
  local src_dir="$PROJECT_ROOT/src"
  if [[ -f "$src_dir/out" ]]; then
    cp "$src_dir/out" /usr/local/bin/vsw
    chmod +x /usr/local/bin/vsw
    log_info "✓ Binário vsw instalado"
  elif [[ -f "$src_dir/vsw" ]]; then
    cp "$src_dir/vsw" /usr/local/bin/vsw
    chmod +x /usr/local/bin/vsw
    log_info "✓ Binário vsw instalado"
  else
    log_warn "Binário vsw não encontrado em $src_dir"
  fi

  # Instala scripts Bash
  local scripts_bash=(
    "build.sh:build"
    "clean.sh:clean"
    "router.sh:roteador"
    "tvbox.sh:tvbox"
    "vsw-tools.sh:vsw-tools"
    "vsw-flash.sh:vsw-flash"
  )

  for item in "${scripts_bash[@]}"; do
    IFS=':' read -r src dst <<<"$item"
    if [[ -f "$file_dir/sh/$src" ]]; then
      cp "$file_dir/sh/$src" "/usr/local/bin/$dst"
      chmod +x "/usr/local/bin/$dst"
      log_info "✓ $dst instalado"
    else
      log_warn "Script $src não encontrado"
    fi
  done

  # Instala scripts Python
  local scripts_python=(
    "comparador.py"
    "autometro.py"
    "differ.py"
    "tablelo.py:tabela.py"
  )

  for item in "${scripts_python[@]}"; do
    IFS=':' read -r src dst <<<"$item"
    dst=${dst:-$src} # Se não houver destino, usa o mesmo nome
    if [[ -f "$file_dir/py/$src" ]]; then
      cp "$file_dir/py/$src" "/usr/local/bin/$dst"
      chmod +x "/usr/local/bin/$dst"

      # Adiciona shebang se não existir
      if ! head -1 "/usr/local/bin/$dst" | grep -q "^#!/usr/bin/env python"; then
        sed -i '1i#!/usr/bin/env python3' "/usr/local/bin/$dst"
      fi

      log_info "✓ $dst instalado"
    else
      log_warn "Script $src não encontrado"
    fi
  done
}

instalar_dependencias_python() {
  local py_dir="$FILES_DIR/py"
  local req_file="$py_dir/requisitos.txt"

  if [[ ! -f "$req_file" ]]; then
    log_warn "Arquivo requisitos.txt não encontrado"
    return
  fi

  log_info "Configurando ambiente Python..."

  cd "$PROJECT_ROOT"

  # Cria venv se não existir
  if [[ ! -d ".venv" ]]; then
    uv venv
  fi

  # Ativa o venv (source funciona apenas em bash)
  # shellcheck source=/dev/null
  source .venv/bin/activate

  log_info "Instalando dependências Python..."
  uv pip install -r "$req_file"

  log_info "✓ Ambiente Python configurado em $PROJECT_ROOT/.venv"
}

limpar_instalacao() {
  log_info "Removendo instalação anterior..."

  # Remove binários e scripts
  local bins=("vsw" "build" "clean" "roteador" "tvbox" "vsw-tools" "vsw-flash" "comparador.py" "autometro.py" "differ.py" "tabela.py")

  for bin in "${bins[@]}"; do
    [[ -f "/usr/local/bin/$bin" ]] && rm -f "/usr/local/bin/$bin" && log_info "Removido: $bin"
  done

  [[ -d "/usr/local/lib/vsw" ]] && rm -rf /usr/local/lib/vsw && log_info "Removido: /usr/local/lib/vsw"
}

usage() {
  echo "Uso: $0 [OPÇÃO]"
  echo ""
  echo "Opções:"
  echo "  install     Instalação completa (padrão)"
  echo "  deps        Apenas instala dependências do sistema"
  echo "  clone       Apenas clona repositórios externos"
  echo "  config      Apenas configura os comandos/binários"
  echo "  python      Apenas configura ambiente Python"
  echo "  clean       Remove todos os artefatos instalados"
  echo "  help        Mostra esta ajuda"
  echo ""
  echo "Exemplos:"
  echo "  sudo $0              # Instalação completa"
  echo "  sudo $0 clean        # Limpa instalação"
  echo "  sudo $0 config       # Reinstala apenas os scripts"
}

main() {
  local comando="${1:-install}"

  case "$comando" in
  help | -h | --help)
    usage
    exit 0
    ;;
  clean)
    verificar_root
    limpar_instalacao
    log_info "Limpeza concluída!"
    ;;
  install | all)
    verificar_root
    verificar_dependencias
    instalar_pacotes_sistema
    clonar_repositorios
    configurar_comandos
    instalar_dependencias_python
    log_info "Instalação completa realizada com sucesso!"
    ;;
  deps)
    verificar_root
    verificar_dependencias
    instalar_pacotes_sistema
    ;;
  clone)
    verificar_dependencias
    clonar_repositorios
    ;;
  config)
    verificar_root
    verificar_dependencias
    configurar_comandos
    ;;
  python)
    verificar_dependencias
    instalar_dependencias_python
    ;;
  *)
    log_error "Comando desconhecido: $comando"
    usage
    exit 1
    ;;
  esac
}

main "$@"
