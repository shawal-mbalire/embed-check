init_state() {
  # ...existing variable definitions and logic...
  STM32CUBECLT_BIN="/usr/local/bin/stm32cubeclt"
  # ...other variable definitions...
  init_tools_meta
  state="PARSE_ARGS"
}
export -f init_state 