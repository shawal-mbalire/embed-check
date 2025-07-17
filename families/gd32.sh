#!/bin/bash
# families/gd32.sh - GigaDevice (GD32) CLI tools
# No standard CLI tool in Fedora; manual download required.

check_gd32() {
  local url="https://www.gigadevice.com/en/product/microcontrollers/gd32/tools/"
  echo "GD32:                NOT Installed"
  echo "  Download and install GD32 tools manually from: $url"
} 