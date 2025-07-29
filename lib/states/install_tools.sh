install_tools_state() {
  if $AUTO_INSTALL; then
    for meta in "${TOOLS_META[@]}"; do
      IFS='|' read -r family name cmd status_var install_pkg special <<< "$meta"
      if [ "${!status_var}" = "NOT Installed" ]; then
        install_tool "$name" "$install_pkg" "$special" "$EMBED_TEST_MODE"
        check_and_update_status "$cmd" "$status_var" "$special"
      fi
    done
  fi
  state="SUMMARY"
}
export -f install_tools_state 