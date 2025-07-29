init_tools_meta() {
  TOOLS_META=(
    "STM32|gcc|arm-none-eabi-gcc|stm32_gcc_status|arm-none-eabi-gcc|"
    "STM32|gdb|arm-none-eabi-gdb|stm32_gdb_status|arm-none-eabi-gdb|"
    "STM32|st-flash|st-flash|stflash_status|stlink|"
    "STM32|openocd|openocd|openocd_status|openocd|"
    "STM32|CubeCLT|$STM32CUBECLT_BIN|stm32cubeclt_status||cubeclt"
    "NXP|gcc|arm-none-eabi-gcc|nxp_tools_found|arm-none-eabi-gcc|"
    "TI|msp430-gcc|msp430-gcc|ti_tools_found|msp430-gcc|"
    "Microchip|gputils|gputils|microchip_tools_found|gputils|"
    "Nuvoton|nu-isp-cli|nu-isp-cli|nuvoton_tools_found|nu-isp-cli|"
    "GD32|GD32_ISP_Console_Linux|GD32_ISP_Console_Linux|gigadevice_tools_found||"
    "Espressif|gcc|xtensa-esp32-elf-gcc|esp32gcc_status|xtensa-esp32-elf-gcc|"
    "Espressif|esptool.py|esptool.py|esptool_status|esptool|"
    "Espressif|ESP-IDF|idf.py|espidf_status||espidf"
    "Arduino|CLI|/home/shawal/bin/arduino-cli|arduino_cli_status||arduino"
    "Arduino|avrdude|avrdude|avrdude_status|avrdude|"
    "General|cmake|cmake|cmake_status|cmake|"
    "General|make|make|make_status|make|"
  )
  export TOOLS_META
} 