#!/bin/bash
# families/stm32.sh - STM32 (STMicroelectronics) CLI tools
# Checks for: arm-none-eabi-gcc, arm-none-eabi-gdb, st-flash, openocd, STM32CubeCLT

check_stm32() {
  local status_gcc="NOT Installed"
  local status_gdb="NOT Installed"
  local status_stflash="NOT Installed"
  local status_openocd="NOT Installed"
  local status_cubeclt="NOT Installed"
  local cubeclt_bin="/usr/local/bin/stm32cubeclt"
  local cubeclt_zip="st-stm32cubeclt_1.18.0_24403_20250225_1636_amd64.sh.zip"
  local cubeclt_url="https://www.st.com/en/development-tools/stm32cubeclt.html#get-software"

  if command -v arm-none-eabi-gcc >/dev/null 2>&1; then status_gcc="Installed"; fi
  if command -v arm-none-eabi-gdb >/dev/null 2>&1; then status_gdb="Installed"; fi
  if command -v st-flash >/dev/null 2>&1; then status_stflash="Installed"; fi
  if command -v openocd >/dev/null 2>&1; then status_openocd="Installed"; fi
  if [ -x "$cubeclt_bin" ]; then status_cubeclt="Installed"; fi

  echo "STM32 (gcc):         $status_gcc"
  echo "STM32 (gdb):         $status_gdb"
  echo "STM32 (st-flash):    $status_stflash"
  echo "STM32 (OpenOCD):     $status_openocd"
  echo "STM32CubeCLT:        $status_cubeclt"
  if [ "$status_cubeclt" = "NOT Installed" ]; then
    echo "  Download and install STM32CubeCLT from: $cubeclt_url (email required)"
    if [ -f "$cubeclt_zip" ]; then
      echo "  Installer zip found: $cubeclt_zip (run manually or automate extraction/install)"
    fi
  fi
} 