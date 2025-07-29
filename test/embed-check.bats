#!/usr/bin/env bats

@test "embed-check.sh --help outputs usage" {
  run bash /home/shawal/GitHub/embed-check/embed help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "embed-check.sh list --no-install outputs summary" {
  run bash /home/shawal/GitHub/embed-check/embed board list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Board Name"* ]]
}

@test "embed install successfully installs a tool" {
  # Create a temporary directory to act as a fake /usr/bin
  temp_bin_dir="$(mktemp -d)"
  export PATH="$temp_bin_dir:$PATH"

  # Create a fake gdb executable
  touch "$temp_bin_dir/gdb"
  chmod +x "$temp_bin_dir/gdb"

  # Create a mock install_tool function
  install_tool() {
    echo "$@" > "$temp_bin_dir/install_tool_args"
  }
  export -f install_tool

  # Run the install command
  run bash -c "rm '$temp_bin_dir/gdb'; /home/shawal/GitHub/embed-check/embed install"
  echo "Status: $status"
  echo "Output: $output"

  # Check if the install_tool function was called with the correct arguments
  [ "$(cat "$temp_bin_dir/install_tool_args")" = "gdb gdb" ]

  # Clean up
  rm -rf "$temp_bin_dir"
}
