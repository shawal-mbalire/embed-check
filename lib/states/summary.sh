summary_state() {
  echo "\n--- Microcontroller Toolchain Summary ---"
  for meta in "${TOOLS_META[@]}"; do
    IFS='|' read -r family name cmd status_var install_pkg special <<< "$meta"
    print_tool_summary "$family" "$name" "$cmd" "$status_var" "$special"
  done
  state="EXIT"
}
export -f summary_state 