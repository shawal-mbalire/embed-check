check_tools_state() {
  local IS_CHECK_TOOLS_MODE=false
  for meta in "${TOOLS_META[@]}"; do
    IFS='|' read -r family name cmd status_var install_pkg special <<< "$meta"
    check_and_update_status "$cmd" "$status_var" "$special"
  done
  missing_tools=false
  for status in "$arduino_cli_status" "$gigadevice_tools_found" "$infineon_tools_found" "$microchip_tools_found" "$nuvoton_tools_found" "$nxp_tools_found" "$renesas_tools_found" "$silabs_tools_found" "$stm32_gcc_status" "$stm32_gdb_status" "$stflash_status" "$openocd_status" "$ti_tools_found" "$esp32gcc_status" "$esptool_status" "$cmake_status" "$make_status" "$avrdude_status" "$espidf_status" "$stm32cubeclt_status"; do
    if [[ "$status" != "Installed" ]]; then
      missing_tools=true
      break
    fi
  done
  if [[ "$IS_CHECK_TOOLS_MODE" == true ]]; then
    state="SUMMARY"
  elif [[ "$MODE" == "install" && $AUTO_INSTALL == true && $missing_tools == true ]]; then
    state="INSTALL_TOOLS"
  else
    state="SUMMARY"
  fi
}
export -f check_tools_state 