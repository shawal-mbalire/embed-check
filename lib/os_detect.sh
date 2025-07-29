# OS detection and package manager abstraction
export OS="unknown"
export PKG_INSTALL="echo 'Install not supported'"
export PKG_SEARCH="echo 'Search not supported'"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      fedora)
        export OS="fedora"
        export PKG_INSTALL="sudo dnf install -y"
        export PKG_SEARCH="dnf search"
        ;;
      ubuntu|debian)
        export OS="debian"
        export PKG_INSTALL="sudo apt-get install -y"
        export PKG_SEARCH="apt-cache search"
        ;;
      arch)
        export OS="arch"
        export PKG_INSTALL="sudo pacman -S --noconfirm"
        export PKG_SEARCH="pacman -Ss"
        ;;
      *)
        export OS="$ID"
        ;;
    esac
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  export OS="macos"
  export PKG_INSTALL="brew install"
  export PKG_SEARCH="brew search"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
  export OS="windows"
  export PKG_INSTALL="echo 'Please install manually via choco, scoop, or winget.'"
  export PKG_SEARCH="echo 'Please search manually via choco, scoop, or winget.'"
fi 