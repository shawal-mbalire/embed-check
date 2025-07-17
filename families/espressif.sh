#!/bin/bash
# families/espressif.sh - Espressif CLI tools
# Checks for: xtensa-esp32-elf-gcc, esptool, idf.py

check_espressif() {
  local status_gcc="NOT Installed"
  local status_esptool="NOT Installed"
  local status_idf="NOT Installed"
  if command -v xtensa-esp32-elf-gcc >/dev/null 2>&1; then status_gcc="Installed"; fi
  if command -v esptool >/dev/null 2>&1 || command -v esptool.py >/dev/null 2>&1; then status_esptool="Installed"; fi
  if command -v idf.py >/dev/null 2>&1; then status_idf="Installed"; fi
  echo "ESP (gcc):           $status_gcc"
  echo "ESP (esptool):       $status_esptool"
  echo "ESP-IDF:             $status_idf"
} 