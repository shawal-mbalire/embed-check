#!/bin/bash
# families/infineon.sh - Infineon CLI tools
# No standard CLI tool in Fedora; manual download required.

check_infineon() {
  local url="https://www.infineon.com/cms/en/tools/"
  echo "Infineon:            NOT Installed"
  echo "  Download and install Infineon tools manually from: $url"
} 