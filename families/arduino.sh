#!/bin/bash
# families/arduino.sh - Arduino CLI tools
# Checks for: arduino-cli, avrdude

check_arduino() {
  local status_cli="NOT Installed"
  local status_avrdude="NOT Installed"
  if command -v arduino-cli >/dev/null 2>&1; then status_cli="Installed"; fi
  if command -v avrdude >/dev/null 2>&1; then status_avrdude="Installed"; fi
  echo "Arduino CLI:         $status_cli"
  echo "avrdude:             $status_avrdude"
} 