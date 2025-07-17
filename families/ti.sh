#!/bin/bash
# families/ti.sh - Texas Instruments CLI tools
# Checks for: msp430-gcc, arm-none-eabi-gcc

check_ti() {
  local status_msp430="NOT Installed"
  local status_gcc="NOT Installed"
  if command -v msp430-gcc >/dev/null 2>&1; then status_msp430="Installed"; fi
  if command -v arm-none-eabi-gcc >/dev/null 2>&1; then status_gcc="Installed"; fi
  echo "TI (msp430-gcc):     $status_msp430"
  echo "TI (gcc):           $status_gcc"
} 