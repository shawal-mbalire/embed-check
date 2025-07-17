#!/bin/bash
# families/microchip.sh - Microchip CLI tools
# Checks for: arm-none-eabi-gcc, gputils

check_microchip() {
  local status_gcc="NOT Installed"
  local status_gputils="NOT Installed"
  if command -v arm-none-eabi-gcc >/dev/null 2>&1; then status_gcc="Installed"; fi
  if command -v gputils >/dev/null 2>&1; then status_gputils="Installed"; fi
  echo "Microchip (gcc):     $status_gcc"
  echo "Microchip (gputils): $status_gputils"
} 