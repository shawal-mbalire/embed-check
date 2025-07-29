# Helper functions for embed-check

check_and_update_status() {
  local cmd="$1"; local status_var="$2"; local special="$3"
  if [[ "$special" == "cubeclt" ]]; then
    if [ -x "$STM32CUBECLT_BIN" ]; then eval "$status_var=\"Installed\""; else eval "$status_var=\"NOT Installed\""; fi
  elif [[ "$special" == "arduino" ]]; then
    if [ -x "/home/shawal/bin/arduino-cli" ]; then eval "$status_var=\"Installed\""; else eval "$status_var=\"NOT Installed\""; fi
  elif [[ "$special" == "espidf" ]]; then
    if command -v idf.py >/dev/null 2>&1; then eval "$status_var=\"Installed\""; else eval "$status_var=\"NOT Installed\""; fi
  else
    if command -v "$cmd" >/dev/null 2>&1; then eval "$status_var=\"Installed\""; else eval "$status_var=\"NOT Installed\""; fi
  fi
}

install_tool() {
  local name="$1"; local install_pkg="$2"; local special="$3"; local test_mode_path="$4"
  if [[ -n "$test_mode_path" ]]; then
    touch "$test_mode_path/$name"
    return 0
  fi
  if [[ "$special" == "cubeclt" ]]; then
    if [ ! -x "$STM32CUBECLT_BIN" ] && [ -f "$STM32CUBECLT_ZIP" ]; then
      echo "STM32CubeCLT installer zip found. Installing..."
      unzip -o "$STM32CUBECLT_ZIP" -d .
      found_installer=$(find . -maxdepth 1 -name '*.sh' | head -n 1)
      if [ -n "$found_installer" ]; then
        chmod +x "$found_installer"
        if [[ -t 0 ]]; then
          sudo "$found_installer" -- -q
        else
          echo -e "\033[0;31mError: sudo required for STM32CubeCLT installation. Please run this command interactively or provide sudo password.\033[0m"
          return 1
        fi
      fi
    fi
  elif [[ "$special" == "arduino" ]]; then
    echo "Installing Arduino CLI..."
    mkdir -p "/home/shawal/bin"
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="/home/shawal/bin" sh
    if ! echo ":$PATH:" | grep -q ":/home/shawal/bin:"; then
      echo -e "\033[0;33mWarning: /home/shawal/bin is not in your PATH. Add it to use arduino-cli from anywhere.\033[0m"
      echo -e "\033[0;33mYou can add it by running: echo 'export PATH=\"\$PATH:/home/shawal/bin\"' >> ~/.bashrc && source ~/.bashrc\033[0m"
    fi
  elif [[ -z "$install_pkg" ]]; then
    echo -e "\033[0;33mWarning: No package available for $name on $OS. Skipping installation.\033[0m"
    return
  else
    echo "Installing $name..."
    if [[ -t 0 ]]; then
      $PKG_INSTALL $(get_pkg_name "$install_pkg") || { error_message="Failed to install $name."; state="ERROR"; return 1; }
    else
      echo -e "\033[0;31mError: sudo required to install $name. Please run this command interactively or provide sudo password.\033[0m"
      return 1
    fi
  fi
}

colorize_status() {
  local status="$1"
  case "$status" in
    "Installed")
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

print_tool_row() {
  local icon="$1"
  local color="$2"
  local name="$3"
  local status="$4"
  local location="$5"
  if [ -n "$icon" ]; then
    printf "${color}%-2s %-20s${NC} │ %-15s │ %-30s\n" "$icon" "$name" "$(colorize_status "$status")" "$location"
  else
    printf "${color}%-20s${NC} │ %-15s │ %-30s\n" "$name" "$(colorize_status "$status")" "$location"
  fi
}

print_tool_summary() {
  local family="$1"; local name="$2"; local cmd="$3"; local status_var="$4"; local special="$5"
  local status="${!status_var}"
  local location="-"
  if [[ "$special" == "cubeclt" ]]; then
    location="$STM32CUBECLT_BIN"
  elif [[ "$special" == "arduino" ]]; then
    location="/home/shawal/bin/arduino-cli"
  elif [[ "$special" == "espidf" ]]; then
    location="$(command -v idf.py 2>/dev/null || echo -)"
  else
    location="$(command -v "$cmd" 2>/dev/null || echo -)"
  fi
  print_tool_row "" "$GENERAL_COLOR" "$name" "$status" "$location"
}

get_pkg_name() {
  local tool="$1"
  case "$OS" in
    fedora)
      case "$tool" in
        arm-none-eabi-gcc) echo "arm-none-eabi-gcc-cs.x86_64 arm-none-eabi-newlib";;
        arm-none-eabi-gdb) echo "arm-none-eabi-gcc-cs.x86_64 arm-none-eabi-newlib";;
        st-flash) echo "stlink";;
        openocd) echo "openocd";;
        nu-isp-cli) echo "nu-isp-cli";;
        xtensa-esp32-elf-gcc) echo "xtensa-esp32-elf-gcc";;
        esptool) echo "esptool";;
        cmake) echo "cmake";;
        make) echo "make";;
        avrdude) echo "avrdude";;
        gdb) echo "gdb";;
        msp430-gcc) echo "";; # Not available on Fedora
        *) echo "$tool";;
      esac
      ;;
    debian)
      case "$tool" in
        arm-none-eabi-gcc) echo "gcc-arm-none-eabi";;
        arm-none-eabi-gdb) echo "gdb-multiarch";;
        st-flash) echo "stlink-tools";;
        openocd) echo "openocd";;
        nu-isp-cli) echo "nu-isp-cli";;
        xtensa-esp32-elf-gcc) echo "gcc-xtensa-esp32";;
        esptool) echo "esptool";;
        cmake) echo "cmake";;
        make) echo "make";;
        avrdude) echo "avrdude";;
        gdb) echo "gdb";;
        msp430-gcc) echo "msp430-gcc";;
        *) echo "$tool";;
      esac
      ;;
    arch)
      case "$tool" in
        arm-none-eabi-gcc) echo "arm-none-eabi-gcc";;
        arm-none-eabi-gdb) echo "arm-none-eabi-gdb";;
        st-flash) echo "stlink";;
        openocd) echo "openocd";;
        nu-isp-cli) echo "nu-isp-cli";;
        xtensa-esp32-elf-gcc) echo "xtensa-esp32-elf-gcc";;
        esptool) echo "esptool";;
        cmake) echo "cmake";;
        make) echo "make";;
        avrdude) echo "avrdude";;
        gdb) echo "gdb";;
        msp430-gcc) echo "msp430-gcc";;
        *) echo "$tool";;
      esac
      ;;
    macos)
      case "$tool" in
        arm-none-eabi-gcc) echo "arm-none-eabi-gcc";;
        arm-none-eabi-gdb) echo "arm-none-eabi-gdb";;
        st-flash) echo "stlink";;
        openocd) echo "openocd";;
        nu-isp-cli) echo "nu-isp-cli";;
        xtensa-esp32-elf-gcc) echo "xtensa-esp32-elf-gcc";;
        esptool) echo "esptool";;
        cmake) echo "cmake";;
        make) echo "make";;
        avrdude) echo "avrdude";;
        gdb) echo "gdb";;
        msp430-gcc) echo "msp430-gcc";;
        *) echo "$tool";;
      esac
      ;;
    *)
      echo "$tool";;
  esac
}
export -f get_pkg_name

export -f check_and_update_status
export -f install_tool
export -f colorize_status
export -f print_tool_row
export -f print_tool_summary 