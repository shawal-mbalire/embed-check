error_state() {
  echo "Fatal error: $error_message"
  exit 99
}
export -f error_state