#!/bin/bash
# ============================================================================
# Microcontroller Toolchain Checker & Installer
# ----------------------------------------------------------------------------
# This script checks for, installs, and summarizes the status of common
# microcontroller development tools on Fedora/Linux systems. It is designed
# to be idempotent, user-friendly, and suitable for both interactive and CI/CD use.
#
# USAGE:
#   ./requirements.sh [install|list|help] [--no-install] [-v|--verbose]
#
# SUBCOMMANDS/FLAGS:
#   install        Check and install missing tools (default)
#   list, --list   Show tool status only, do not install
#   -v, --verbose  Verbose output (show sources, extra info)
#   --no-install   Do not install missing tools (status only)
#   -h, --help     Show this help message
#
# EXIT CODES:
#   0   All required tools are installed
#   1   One or more required tools are missing
#
# FEATURES:
#   - Colorful, aligned summary table with icons
#   - Installs user-level tools (e.g., Arduino CLI to ~/.local/bin)
#   - Warns if user-level bin is not in PATH
#   - Verbose mode for extra info and sources
#   - Idempotent and safe to re-run
#   - Suitable for CI/CD pipelines
#   - Easily extensible: add more tools, sources, or logic as needed
#
# SOURCES:
#   Arduino CLI: https://docs.arduino.cc/arduino-cli/installation/
#   (Add more sources for other tools as needed)
# ============================================================================
echo "Checking and installing microcontroller toolchains..."

show_help() {
  cat <<EOF
Usage: $0 [subcommand|options]

Subcommands/Options:
  install        Check and install missing tools (default)
  list, --list   Show tool status only, do not install
  -v, --verbose  Verbose output (show sources, extra info)
  --no-install   Do not install missing tools (status only)
  -h, --help     Show this help message

Shell completion: See your shell's documentation for enabling tab completion for scripts.
EOF
}

# Argument parsing
MODE="install"
VERBOSE=false
AUTO_INSTALL=true
if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    case "$arg" in
      install) MODE="install" ;;
      list|--list) MODE="list"; AUTO_INSTALL=false ;;
      -v|--verbose) VERBOSE=true ;;
      --no-install) AUTO_INSTALL=false ;;
      -h|--help|help) show_help; exit 0 ;;
      *) echo "Unknown argument: $arg"; show_help; exit 1 ;;
    esac
  done
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Enhanced color variables for microcontroller types (no reuse)
STM32_COLOR="${BOLD}\033[38;5;33m"      # Blue
NXP_COLOR="${BOLD}\033[38;5;129m"       # Purple
TI_COLOR="${BOLD}\033[38;5;40m"         # Green
MICROCHIP_COLOR="${BOLD}\033[38;5;51m"  # Cyan
RENESAS_COLOR="${BOLD}\033[38;5;220m"   # Gold/Yellow
SILABS_COLOR="${BOLD}\033[38;5;208m"    # Orange
INFINEON_COLOR="${BOLD}\033[38;5;196m"  # Red
NUVOTON_COLOR="${BOLD}\033[38;5;214m"   # Amber
GIGADEVICE_COLOR="${BOLD}\033[38;5;45m" # Teal
ESPRESSIF_COLOR="${BOLD}\033[38;5;226m" # Bright Yellow
GENERAL_COLOR="${BOLD}\033[38;5;244m"   # Grey
ARDUINO_COLOR="${BOLD}\033[38;5;202m" # Bright orange
ARDUINO_ICON="🟧"

# Icons for each family
STM32_ICON="🟦"
NXP_ICON="🟪"
TI_ICON="🟩"
MICROCHIP_ICON="🟦"
RENESAS_ICON="🟨"
SILABS_ICON="🟧"
INFINEON_ICON="🟥"
NUVOTON_ICON="🟧"
GIGADEVICE_ICON="🟦"
ESPRESSIF_ICON="🟨"

# Status icons
STATUS_INSTALLED_ICON="✔"
STATUS_NOT_INSTALLED_ICON="✖"
STATUS_LIKELY_NOT_INSTALLED_ICON="⚠"

# Variables to store installation status
stm32_gcc_status="NOT Installed"
stm32_gdb_status="NOT Installed"
stflash_status="NOT Installed"
openocd_status="NOT Installed"
nxp_tools_found="NOT Installed"
ti_tools_found="NOT Installed"
microchip_tools_found="NOT Installed"
renesas_tools_found="NOT Installed"
silabs_tools_found="NOT Installed"
infineon_tools_found="NOT Installed"
nuvoton_tools_found="NOT Installed"
gigadevice_tools_found="NOT Installed"
esp32gcc_status="Likely NOT Installed"
esptool_status="Likely NOT Installed"
cmake_status="NOT Installed"
make_status="NOT Installed"
arduino_cli_status="NOT Installed"
avrdude_status="NOT Installed"
espidf_status="NOT Installed"
ESPIDF_SOURCE_URL="https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html"

STM32CUBECLT_ZIP="st-stm32cubeclt_1.18.0_24403_20250225_1636_amd64.sh.zip"
STM32CUBECLT_INSTALLER="stm32cubeclt_installer.sh"
STM32CUBECLT_BIN="/usr/local/bin/stm32cubeclt"
STM32CUBECLT_SOURCE_URL="https://www.st.com/en/development-tools/stm32cubeclt.html#get-software"

# OS detection and package manager abstraction
OS="unknown"
PKG_INSTALL="echo 'Install not supported'"
PKG_SEARCH="echo 'Search not supported'"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      fedora)
        OS="fedora"
        PKG_INSTALL="sudo dnf install -y"
        PKG_SEARCH="dnf search"
        ;;
      ubuntu|debian)
        OS="debian"
        PKG_INSTALL="sudo apt-get install -y"
        PKG_SEARCH="apt-cache search"
        ;;
      arch)
        OS="arch"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_SEARCH="pacman -Ss"
        ;;
      *)
        OS="$ID"
        ;;
    esac
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  PKG_INSTALL="brew install"
  PKG_SEARCH="brew search"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
  OS="windows"
  PKG_INSTALL="echo 'Please install manually via choco, scoop, or winget.'"
  PKG_SEARCH="echo 'Please search manually via choco, scoop, or winget.'"
fi

# Function to check and display status
check_tool() {
  local tool="$1"
  local status_var="$2"
  local install_command="$3"
  local search_terms="$4"
  local color="$5"
  local is_company_check="$6" # Flag to indicate if called from check_company_tools
  local found=$(command -v "$tool" >/dev/null 2>&1)

  if $VERBOSE; then
    if [ -z "$is_company_check" ]; then
      echo "${color}--- Checking for $tool ---${NC}"
    fi
    if $found; then
      echo "${GREEN}  $tool is installed.${NC}"
      eval "$status_var=\"Installed\""
      return 0
    else
      echo "${RED}  $tool is NOT installed.${NC}"
      echo "${YELLOW}  Searching for packages with '$search_terms':${NC}"
      $PKG_SEARCH "$search_terms"
      if [ -n "$install_command" ]; then
        echo "${YELLOW}  You can try installing it with: $PKG_INSTALL $install_command${NC}"
      fi
      return 1
    fi
  else
    if $found; then
      eval "$status_var=\"Installed\""
      return 0
    else
      eval "$status_var=\"NOT Installed\""
      return 1
    fi
  fi
  echo
}

# Refactored check_company_tools to accept array and assign status safely
check_company_tools() {
  local company="$1"
  local color="$2"
  local -n tools_arr=$3 # Use nameref for array
  local status_var="$4"
  local found_count=0
  for tool_info in "${tools_arr[@]}"; do
    local tool=$(echo "$tool_info" | awk -F':' '{print $1}')
    local install_command=$(echo "$tool_info" | awk -F':' '{print $2}')
    local search_terms="$tool"
    if command -v "$tool" >/dev/null 2>&1; then
      ((found_count++))
      if $VERBOSE; then
        echo "${color}--- Checking for $tool ---${NC}"
        echo "${GREEN}  $tool is installed.${NC}"
      fi
    elif $VERBOSE; then
      echo "${color}--- Checking for $tool ---${NC}"
      echo "${RED}  $tool is NOT installed.${NC}"
      echo "${YELLOW}  Searching for packages with '$search_terms':${NC}"
      $PKG_SEARCH "$search_terms"
      if [ -n "$install_command" ]; then
        echo "${YELLOW}  You can try installing it with: $PKG_INSTALL $install_command${NC}"
      fi
    fi
  done
  if [ $found_count -gt 0 ] && [ ${#tools_arr[@]} -gt 0 ]; then
    declare -g $status_var="Installed"
  else
    declare -g $status_var="NOT Installed"
  fi
  echo
}

# Function to get tool location if installed
get_tool_location() {
  local tool="$1"
  if [[ "$tool" == "/home/shawal/bin/arduino-cli" ]]; then
    if [ -x "/home/shawal/bin/arduino-cli" ]; then
      echo "/home/shawal/bin/arduino-cli"
    else
      echo "-"
    fi
  elif command -v "$tool" >/dev/null 2>&1; then
    command -v "$tool"
  else
    echo "-"
  fi
}

# Function to get company tool location (first found)
get_company_tool_location() {
  local tools=("$@")
  for tool in "${tools[@]}"; do
    local tname=$(echo "$tool" | awk -F':' '{print $1}')
    if command -v "$tname" >/dev/null 2>&1; then
      command -v "$tname"
      return
    fi
  done
  echo "-"
}

# Function to colorize status for summary table (with icons, fixed width)
colorize_status() {
  local status="$1"
  case "$status" in
    "Installed")
      # Pad to match '✖ NOT Installed' (15 chars)
      echo -e "${GREEN}${STATUS_INSTALLED_ICON} Installed   ${NC}"
      ;;
    "NOT Installed")
      echo -e "${RED}${STATUS_NOT_INSTALLED_ICON} NOT Installed${NC}"
      ;;
    "Likely NOT Installed")
      echo -e "${YELLOW}${STATUS_LIKELY_NOT_INSTALLED_ICON} Likely NOT Installed${NC}"
      ;;
    *)
      echo -e "${RED}${STATUS_NOT_INSTALLED_ICON} NOT Installed${NC}"
      ;;
  esac
}

# Function to print a summary row with icon, color, and location (fixed width)
print_summary_row() {
  local icon="$1"
  local color="$2"
  local name="$3"
  local status="$4"
  local location="$5"
  local source="$6"
  if $VERBOSE; then
    printf "${color}%-2s %-20s${NC} │ %-15s │ %-30s │ %-60s\n" "$icon" "$name" "$(colorize_status "$status")" "$location" "$source"
  else
    printf "${color}%-2s %-20s${NC} │ %-15s │ %-30s\n" "$icon" "$name" "$(colorize_status "$status")" "$location"
  fi
}

# Source and call each family script
source families/stm32.sh
source families/nxp.sh
source families/ti.sh
source families/microchip.sh
source families/renesas.sh
source families/silabs.sh
source families/infineon.sh
source families/nuvoton.sh
source families/gd32.sh
source families/espressif.sh
source families/arduino.sh

echo "\n--- Microcontroller Toolchain Summary ---"
check_stm32
echo
check_nxp
echo
check_ti
echo
check_microchip
echo
check_renesas
echo
check_silabs
echo
check_infineon
echo
check_nuvoton
echo
check_gd32
echo
check_espressif
echo
check_arduino
echo

# After all checks, before the summary table, run installs if needed
if $AUTO_INSTALL; then
  if $AUTO_INSTALL && [[ "$MODE" != "list" && "$MODE" != "help" ]]; then
    echo "Requesting sudo privileges for package installation..."
    sudo -v
  fi
  # STM32 tools
  if [ "$stm32_gcc_status" = "NOT Installed" ]; then
    echo "Installing arm-none-eabi-gcc..."
    $PKG_INSTALL $(get_pkg_name arm-none-eabi-gcc)
  fi
  if [ "$stm32_gdb_status" = "NOT Installed" ]; then
    echo "Installing arm-none-eabi-binutils..."
    $PKG_INSTALL $(get_pkg_name arm-none-eabi-gdb)
  fi
  if [ "$stflash_status" = "NOT Installed" ]; then
    echo "Installing stlink..."
    $PKG_INSTALL $(get_pkg_name st-flash)
  fi
  if [ "$openocd_status" = "NOT Installed" ]; then
    echo "Installing openocd..."
    $PKG_INSTALL $(get_pkg_name openocd)
  fi
  # NXP, TI, Microchip, etc. use arm-none-eabi-gcc, already covered above
  # Nuvoton
  if [ "$nuvoton_tools_found" = "NOT Installed" ]; then
    echo "Installing nu-isp-cli..."
    $PKG_INSTALL $(get_pkg_name nu-isp-cli)
  fi
  # GigaDevice (no package, skip)
  # Espressif
  if [ "$esp32gcc_status" = "Likely NOT Installed" ]; then
    echo "Installing xtensa-esp32-elf-gcc..."
    $PKG_INSTALL $(get_pkg_name xtensa-esp32-elf-gcc)
  fi
  if [ "$esptool_status" = "Likely NOT Installed" ] || [ "$esptool_status" = "NOT Installed" ]; then
    echo "Installing esptool via dnf..."
    $PKG_INSTALL $(get_pkg_name esptool)
  fi
  # General build tools
  if [ "$cmake_status" = "NOT Installed" ]; then
    echo "Installing cmake..."
    $PKG_INSTALL $(get_pkg_name cmake)
  fi
  if [ "$make_status" = "NOT Installed" ]; then
    echo "Installing make..."
    $PKG_INSTALL $(get_pkg_name make)
  fi
  # Arduino CLI
  if [ "$arduino_cli_status" = "NOT Installed" ]; then
    if $VERBOSE; then
      echo "Installing Arduino CLI to /home/shawal/bin..."
      mkdir -p "/home/shawal/bin"
      curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="/home/shawal/bin" sh
    else
      echo "Installing Arduino CLI..."
      mkdir -p "/home/shawal/bin"
      curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="/home/shawal/bin" sh > /dev/null 2>&1
    fi
    # Check if /home/shawal/bin is in PATH
    if ! echo ":$PATH:" | grep -q ":/home/shawal/bin:"; then
      echo -e "\033[0;33mWarning: /home/shawal/bin is not in your PATH. Add it to use arduino-cli from anywhere.\033[0m"
      echo -e "\033[0;33mYou can add it by running: echo 'export PATH=\"\$PATH:/home/shawal/bin\"' >> ~/.bashrc && source ~/.bashrc\033[0m"
    fi
  fi
  if [ "$avrdude_status" = "NOT Installed" ]; then
    echo "Installing avrdude..."
    $PKG_INSTALL $(get_pkg_name avrdude)
  fi
  # ESP-IDF: no package, just print instructions in verbose mode
fi

# Update status after install: only mark as Installed if location is found (for arduino-cli, check /home/shawal/bin/arduino-cli)
update_status_if_found() {
  local tool="$1"
  local status_var="$2"
  if [[ "$tool" == "/home/shawal/bin/arduino-cli" ]]; then
    if [ -x "/home/shawal/bin/arduino-cli" ]; then
      eval "$status_var=\"Installed\""
    else
      eval "$status_var=\"NOT Installed\""
    fi
  elif command -v "$tool" >/dev/null 2>&1; then
    eval "$status_var=\"Installed\""
  else
    eval "$status_var=\"NOT Installed\""
  fi
}

# After all installs, update status for each tool based on location
if $AUTO_INSTALL; then
  update_status_if_found arm-none-eabi-gcc stm32_gcc_status
  update_status_if_found arm-none-eabi-gdb stm32_gdb_status
  update_status_if_found st-flash stflash_status
  update_status_if_found openocd openocd_status
  update_status_if_found nu-isp-cli nuvoton_tools_found
  update_status_if_found GD32_ISP_Console_Linux gigadevice_tools_found
  update_status_if_found xtensa-esp32-elf-gcc esp32gcc_status
  update_status_if_found esptool.py esptool_status
  update_status_if_found cmake cmake_status
  update_status_if_found make make_status
  update_status_if_found "/home/shawal/bin/arduino-cli" arduino_cli_status
  update_status_if_found avrdude avrdude_status
  # Company tools: NXP, TI, Microchip, etc.
  # NXP
  if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    nxp_tools_found="Installed"
  else
    nxp_tools_found="NOT Installed"
  fi
  # TI
  if command -v arm-none-eabi-gcc >/dev/null 2>&1 || command -v msp430-gcc >/dev/null 2>&1; then
    ti_tools_found="Installed"
  else
    ti_tools_found="NOT Installed"
  fi
  # Microchip
  if command -v arm-none-eabi-gcc >/dev/null 2>&1 || command -v gputils >/dev/null 2>&1; then
    microchip_tools_found="Installed"
  else
    microchip_tools_found="NOT Installed"
  fi
  if command -v idf.py >/dev/null 2>&1; then
    espidf_status="Installed"
  else
    espidf_status="NOT Installed"
  fi
fi

# If the binary is not found, but the zip is present, attempt install
if [ ! -x "$STM32CUBECLT_BIN" ] && [ -f "$STM32CUBECLT_ZIP" ] && $AUTO_INSTALL; then
  echo "STM32CubeCLT installer zip found. Installing..."
  unzip -o "$STM32CUBECLT_ZIP" -d .
  # Find the .sh installer in the current directory
  found_installer=$(find . -maxdepth 1 -name '*.sh' | head -n 1)
  if [ -n "$found_installer" ]; then
    chmod +x "$found_installer"
    sudo "$found_installer" -- -q
  fi
fi

# Check for the binary
stm32cubeclt_status="NOT Installed"
if [ -x "$STM32CUBECLT_BIN" ]; then
  stm32cubeclt_status="Installed"
fi

# In verbose mode, print guidance if not installed
if $VERBOSE && [ "$stm32cubeclt_status" = "NOT Installed" ]; then
  echo -e "${YELLOW}STM32CubeCLT is not installed. Download it from:${NC}"
  echo -e "${YELLOW}$STM32CUBECLT_SOURCE_URL${NC}"
  echo -e "${YELLOW}Note: Registration and email are required for download.${NC}"
fi

# --- Improved Installation Summary ---
print_family_header() {
  local family="$1"
  echo -e "${BOLD}${family}${NC}"
}

print_tool_row() {
  local icon="$1"
  local color="$2"
  local tool="$3"
  local status="$4"
  local location="$5"
  printf "  ${color}%-12s${NC} │ %-15s │ %-30s\n" "$tool" "$(colorize_status "$status")" "$location"
}

# Print grouped summary
print_family_header "STM32"
print_tool_row "$STM32_ICON" "$STM32_COLOR" "(gcc)" "$stm32_gcc_status" "$(get_tool_location arm-none-eabi-gcc)"
print_tool_row "$STM32_ICON" "$STM32_COLOR" "(gdb)" "$stm32_gdb_status" "$(get_tool_location arm-none-eabi-gdb)"
print_tool_row "$STM32_ICON" "$STM32_COLOR" "(st-flash)" "$stflash_status" "$(get_tool_location st-flash)"
print_tool_row "$STM32_ICON" "$STM32_COLOR" "(OpenOCD)" "$openocd_status" "$(get_tool_location openocd)"
print_tool_row "$STM32_ICON" "$STM32_COLOR" "CubeCLT" "$stm32cubeclt_status" "$(get_tool_location $STM32CUBECLT_BIN)"
echo
print_family_header "NXP"
print_tool_row "$NXP_ICON" "$NXP_COLOR" "(gcc)" "$nxp_tools_found" "$(get_company_tool_location arm-none-eabi-gcc)"
echo
print_family_header "TI"
print_tool_row "$TI_ICON" "$TI_COLOR" "(msp430-gcc)" "$(if command -v msp430-gcc >/dev/null 2>&1; then echo Installed; else echo 'NOT Installed'; fi)" "$(get_tool_location msp430-gcc)"
print_tool_row "$TI_ICON" "$TI_COLOR" "(gcc)" "$ti_tools_found" "$(get_company_tool_location arm-none-eabi-gcc)"
echo
print_family_header "Microchip"
print_tool_row "$MICROCHIP_ICON" "$MICROCHIP_COLOR" "(gcc)" "$microchip_tools_found" "$(get_company_tool_location arm-none-eabi-gcc)"
print_tool_row "$MICROCHIP_ICON" "$MICROCHIP_COLOR" "(gputils)" "$(if command -v gputils >/dev/null 2>&1; then echo Installed; else echo 'NOT Installed'; fi)" "$(get_tool_location gputils)"
echo
print_family_header "Renesas"
print_tool_row "$RENESAS_ICON" "$RENESAS_COLOR" "(tools)" "$renesas_tools_found" "-"
echo
print_family_header "SiLabs"
print_tool_row "$SILABS_ICON" "$SILABS_COLOR" "(tools)" "$silabs_tools_found" "-"
echo
print_family_header "Infineon"
print_tool_row "$INFINEON_ICON" "$INFINEON_COLOR" "(tools)" "$infineon_tools_found" "-"
echo
print_family_header "Nuvoton"
print_tool_row "$NUVOTON_ICON" "$NUVOTON_COLOR" "(nu-isp-cli)" "$nuvoton_tools_found" "$(get_tool_location nu-isp-cli)"
echo
print_family_header "GD32"
print_tool_row "$GIGADEVICE_ICON" "$GIGADEVICE_COLOR" "(tools)" "$gigadevice_tools_found" "$(get_tool_location GD32_ISP_Console_Linux)"
echo
print_family_header "Espressif"
print_tool_row "$ESPRESSIF_ICON" "$ESPRESSIF_COLOR" "(gcc)" "$esp32gcc_status" "$(get_tool_location xtensa-esp32-elf-gcc)"
print_tool_row "$ESPRESSIF_ICON" "$ESPRESSIF_COLOR" "(esptool.py)" "$esptool_status" "$(get_tool_location esptool.py)"
print_tool_row "$ESPRESSIF_ICON" "$ESPRESSIF_COLOR" "ESP-IDF" "$espidf_status" "$(get_tool_location idf.py)"
echo
print_family_header "Arduino"
print_tool_row "$ARDUINO_ICON" "$ARDUINO_COLOR" "CLI" "$arduino_cli_status" "$(get_tool_location "/home/shawal/bin/arduino-cli")"
print_tool_row "🛠" "$GENERAL_COLOR" "avrdude" "$avrdude_status" "$(get_tool_location avrdude)"
echo
print_family_header "General Build Tools"
print_tool_row "🛠" "$GENERAL_COLOR" "CMake" "$cmake_status" "$(get_tool_location cmake)"
print_tool_row "🛠" "$GENERAL_COLOR" "Make" "$make_status" "$(get_tool_location make)"
echo

# At the end, after the summary table, add exit code logic
# If any required tool is NOT Installed, exit 1, else exit 0
missing=0
for status in "$arduino_cli_status" "$gigadevice_tools_found" "$infineon_tools_found" "$microchip_tools_found" "$nuvoton_tools_found" "$nxp_tools_found" "$renesas_tools_found" "$silabs_tools_found" "$stm32_gcc_status" "$stm32_gdb_status" "$stflash_status" "$openocd_status" "$ti_tools_found" "$esp32gcc_status" "$esptool_status" "$cmake_status" "$make_status" "$avrdude_status" "$espidf_status" "$stm32cubeclt_status"; do
  if [[ "$status" != "Installed" ]]; then
    missing=1
    break
  fi
done
exit $missing

# Array of all tools to check: (family tool_name check_cmd install_cmd get_version_cmd color icon)
tools=(
  "STM32 gcc arm-none-eabi-gcc 'sudo dnf install -y arm-none-eabi-gcc-cs.x86_64' 'arm-none-eabi-gcc --version | head -n1' $STM32_COLOR $STM32_ICON"
  "STM32 gdb arm-none-eabi-gdb 'sudo dnf install -y arm-none-eabi-binutils' 'arm-none-eabi-gdb --version | head -n1' $STM32_COLOR $STM32_ICON"
  "STM32 st-flash st-flash 'sudo dnf install -y stlink' 'st-flash --version | head -n1' $STM32_COLOR $STM32_ICON"
  "STM32 OpenOCD openocd 'sudo dnf install -y openocd.x86_64' 'openocd --version | head -n1' $STM32_COLOR $STM32_ICON"
  "TI msp430-gcc msp430-gcc 'sudo dnf install -y msp430-gcc' 'msp430-gcc --version | head -n1' $TI_COLOR $TI_ICON"
  "Microchip gputils gputils 'sudo dnf install -y gputils' 'gputils --version | head -n1' $MICROCHIP_COLOR $MICROCHIP_ICON"
  "Nuvoton nu-isp-cli nu-isp-cli 'sudo dnf install -y nu-isp-cli' 'nu-isp-cli --version | head -n1' $NUVOTON_COLOR $NUVOTON_ICON"
  "Espressif xtensa-esp32-elf-gcc xtensa-esp32-elf-gcc 'sudo dnf install -y xtensa-esp32-elf-gcc' 'xtensa-esp32-elf-gcc --version | head -n1' $ESPRESSIF_COLOR $ESPRESSIF_ICON"
  "Espressif esptool.py esptool.py 'sudo dnf install -y esptool.noarch' 'esptool.py --version 2>&1 | head -n1' $ESPRESSIF_COLOR $ESPRESSIF_ICON"
  "General CMake cmake 'sudo dnf install -y cmake' 'cmake --version | head -n1' $GENERAL_COLOR 🛠"
  "General Make make 'sudo dnf install -y make' 'make --version | head -n1' $GENERAL_COLOR 🛠"
  "Arduino avrdude avrdude 'sudo dnf install -y avrdude' 'avrdude -v | head -n1' $ARDUINO_COLOR $ARDUINO_ICON"
)

installed_by_script=()

print_summary_header() {
  printf "${BOLD}%-12s │ %-15s │ %-15s │ %-30s │ %-20s │ %-10s${NC}\n" "Family" "Tool" "Status" "Location" "Version" "Installed?"
  printf "${GENERAL_COLOR}%-12s─┼─%-15s─┼─%-15s─┼─%-30s─┼─%-20s─┼─%-10s${NC}\n" "────────────" "───────────────" "───────────────" "──────────────────────────────" "────────────────────" "──────────"
}

print_summary_row() {
  local family="$1"; local tool="$2"; local status="$3"; local location="$4"; local version="$5"; local color="$6"; local icon="$7"; local installed="$8"
  local status_col
  if [[ "$status" == "Installed" ]]; then status_col="${GREEN}✔ Installed   ${NC}"; else status_col="${RED}✖ NOT Installed${NC}"; fi
  printf "${color}%-12s${NC} │ %-15s │ %s │ %-30s │ %-20s │ %-10s\n" "$family" "$tool" "$status_col" "$location" "$version" "$installed"
}

summary_rows=()

for entry in "${tools[@]}"; do
  eval set -- $entry
  family="$1"; tool="$2"; cmd="$3"; install_cmd="$4"; version_cmd="$5"; color="$6"; icon="$7"
  status="NOT Installed"
  location="-"
  version="-"
  installed="No"
  if command -v "$cmd" >/dev/null 2>&1; then
    status="Installed"
    location="$(command -v "$cmd")"
    version="$(eval $version_cmd 2>/dev/null | head -n1)"
  elif $AUTO_INSTALL; then
    if $VERBOSE; then
      echo "Installing $tool for $family: $install_cmd"
      eval $install_cmd && installed="Yes"
    else
      eval $install_cmd >/dev/null 2>&1 && installed="Yes"
    fi
    if command -v "$cmd" >/dev/null 2>&1; then
      status="Installed"
      location="$(command -v "$cmd")"
      version="$(eval $version_cmd 2>/dev/null | head -n1)"
      installed_by_script+=("$tool ($family)")
      installed="Yes"
    fi
  fi
  summary_rows+=("$family|$tool|$status|$location|$version|$color|$icon|$installed")
done

# Print summary
print_summary_header
for row in "${summary_rows[@]}"; do
  IFS='|' read -r family tool status location version color icon installed <<< "$row"
  print_summary_row "$family" "$tool" "$status" "$location" "$version" "$color" "$icon" "$installed"
done

# Print installed packages
if [[ ${#installed_by_script[@]} -gt 0 ]]; then
  echo -e "\n${YELLOW}Packages installed by this script:${NC}"
  for pkg in "${installed_by_script[@]}"; do
    echo -e "  ${GREEN}$pkg${NC}"
  done
fi

echo -e "\033[1;32mHello! embed-check is installed and ready to use.\033[0m"
