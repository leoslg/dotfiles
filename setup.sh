#!/bin/bash
set -e

# =============================================================================
# setup.sh — Dev Environment / Gnesis AI
# Debian 12/13 | by leoslg
# =============================================================================

DOTFILES_REPO="git@github.com:leoslg/dotfiles.git"
NVIM_VERSION="v0.11.4"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[setup]${NC} $1"; }
warn() { echo -e "${YELLOW}[aviso]${NC} $1"; }

# =============================================================================
# 1. Sistema base
# =============================================================================
log "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

log "Instalando dependências base..."
sudo apt install -y \
  git curl wget unzip tar \
  build-essential \
  zsh \
  direnv \
  htop \
  vim nano \
  screen \
  ufw \
  unzip \
  certbot \
  ca-certificates \
  gnupg \
  lsb-release \
# =============================================================================
# 3. Docker
# =============================================================================
if ! command -v docker &>/dev/null; then
  log "Instalando Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  log "Docker instalado. Você precisará fazer logout/login para usar sem sudo."
else
  warn "Docker já instalado, pulando..."
fi

# =============================================================================
# 4. Node.js via nvm + pacotes globais
# =============================================================================
if ! command -v node &>/dev/null; then
  log "Instalando nvm + Node.js LTS..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
else
  warn "Node.js já instalado, pulando..."
fi

log "Instalando pacotes npm globais..."
mkdir -p "$HOME/.npm-packages"
npm install -g pnpm yarn

# =============================================================================
# 5. uv (Python)
# =============================================================================
if ! command -v uv &>/dev/null; then
  log "Instalando uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  warn "uv já instalado, pulando..."
fi

# =============================================================================
# 6. Neovim
# =============================================================================
if ! command -v nvim &>/dev/null; then
  log "Instalando Neovim ${NVIM_VERSION}..."
  wget -q "$NVIM_URL" -O /tmp/nvim.tar.gz
  sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
  rm /tmp/nvim.tar.gz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
else
  warn "Neovim já instalado, pulando..."
fi

# =============================================================================
# 7. GitHub CLI
# =============================================================================
if ! command -v gh &>/dev/null; then
  log "Instalando GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
  sudo apt update && sudo apt install gh -y
else
  warn "GitHub CLI já instalado, pulando..."
fi

# =============================================================================
# 8. Oh My Zsh
# =============================================================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Instalando Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  warn "Oh My Zsh já instalado, pulando..."
fi

# =============================================================================
# 9. Dotfiles
# =============================================================================
if [ ! -d "$HOME/dotfiles" ]; then
  log "Clonando dotfiles..."
  git clone "$DOTFILES_REPO" "$HOME/dotfiles"
else
  warn "Dotfiles já existem, atualizando..."
  git -C "$HOME/dotfiles" pull
fi

log "Aplicando dotfiles..."

cp "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
cp "$HOME/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
cp "$HOME/dotfiles/.profile" "$HOME/.profile"
cp "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
cp "$HOME/dotfiles/.npmrc" "$HOME/.npmrc"

[ -f "$HOME/dotfiles/.mcp.json" ] && cp "$HOME/dotfiles/.mcp.json" "$HOME/.mcp.json"
[ -f "$HOME/dotfiles/.claude.json" ] && cp "$HOME/dotfiles/.claude.json" "$HOME/.claude.json"

mkdir -p "$HOME/.oh-my-zsh/custom"
cp "$HOME/dotfiles/.oh-my-zsh/custom/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"

mkdir -p "$HOME/.zsh/completions"
cp "$HOME/dotfiles/.zsh/completions/uv.zsh" "$HOME/.zsh/completions/uv.zsh"

# =============================================================================
# 10. Trocar shell padrão para zsh
# =============================================================================
if [ "$SHELL" != "$(which zsh)" ]; then
  log "Trocando shell padrão para zsh..."
  chsh -s $(which zsh)
fi

# =============================================================================
# Concluído
# =============================================================================
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN} Ambiente configurado com sucesso!        ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Faça logout e login novamente"
echo "  2. Execute: gh auth login"
echo "  3. Instale o Claude Code: npm install -g @anthropic-ai/claude-code"
echo ""