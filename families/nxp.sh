#!/bin/bash
# families/nxp.sh - NXP CLI tools
# Checks for: arm-none-eabi-gcc

check_nxp() {
  local status_gcc="NOT Installed"
  if command -v arm-none-eabi-gcc >/dev/null 2>&1; then status_gcc="Installed"; fi
  echo "NXP (gcc):           $status_gcc"
} 