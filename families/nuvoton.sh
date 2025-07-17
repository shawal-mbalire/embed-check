#!/bin/bash
# families/nuvoton.sh - Nuvoton CLI tools
# Checks for: nu-isp-cli

check_nuvoton() {
  local status_nuisp="NOT Installed"
  if command -v nu-isp-cli >/dev/null 2>&1; then status_nuisp="Installed"; fi
  echo "Nuvoton (nu-isp-cli): $status_nuisp"
} 