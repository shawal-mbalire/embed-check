exit_state() {
  missing=0
  for status in "$arduino_cli_status" "$gigadevice_tools_found" "$infineon_tools_found" "$microchip_tools_found" "$nuvoton_tools_found" "$nxp_tools_found" "$renesas_tools_found" "$silabs_tools_found" "$stm32_gcc_status" "$stm32_gdb_status" "$stflash_status" "$openocd_status" "$ti_tools_found" "$esp32gcc_status" "$esptool_status" "$cmake_status" "$make_status" "$avrdude_status" "$espidf_status" "$stm32cubeclt_status"; do
    if [[ "$status" != "Installed" ]]; then
      missing=1
      break
    fi
  done
  exit $missing
}
export -f exit_state 