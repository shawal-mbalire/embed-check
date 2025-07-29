# embed-check

A powerful and user-friendly command-line interface (CLI) for embedded systems development. This tool streamlines project initialization, module management, and toolchain verification for both Rust and C++ embedded projects. It combines the robustness of Bash for system-level tasks with the interactivity and beauty of a Python frontend.

## Features

### Current Capabilities (Done Steps)

-   **Hybrid CLI Architecture:** Leverages a Python frontend (built with `typer` and `rich`) for a modern, interactive, and visually appealing user experience, while retaining the battle-tested Bash scripts for core toolchain detection and management.
-   **Project Initialization (`embed new`):**
    -   Allows users to quickly create new embedded projects.
    -   Supports both Rust and C++ as primary development languages.
    -   Scaffolds basic project structures with language-specific templates (e.g., `main.rs` for Rust, `main.cpp` for C++).
    -   Automatically generates a `.board.json` configuration file within the project, storing selected board and language information.
-   **Module Management (`embed add-module`):**
    -   Generates boilerplate code for new sensors or actuators, simplifying the process of adding new hardware components to a project.
    -   Adapts the generated code based on the chosen project language (Rust or C++).
    -   Supports various common connection types (e.g., I2C, SPI, GPIO) for module integration.
-   **Toolchain Installation (`embed install`):**
    -   Provides an explicit command to install all necessary toolchains and dependencies for embedded development.
    -   Intelligently calls the underlying Bash script to perform system-level installations.
    -   Includes improved handling for `sudo` requirements in non-interactive environments.
-   **Project Detection & Compilation (`embed compile`):**
    -   The CLI can now detect if it's being run within an existing `embed-check` project by looking for the `.board.json` file.
    -   A `compile` command is introduced to build the current project.
    -   The underlying Bash script has been enhanced to correctly locate project files using a `--project-path` argument, ensuring seamless compilation regardless of the current working directory.

### Core Toolchain Features (from original Bash script)

-   Checks and installs toolchains for STM32, Espressif, Arduino, TI, Microchip, and more.
-   Colorful, aligned summary table with icons.
-   Idempotent and safe to re-run.
-   Verbose mode for extra info and sources.
-   Easily extensible: add more tools or families as needed.
-   **Cross-platform:** Auto-detects your OS and uses the right package manager or provides manual instructions.

## Quick Install

Install the latest version directly from GitHub with this one-liner:

```sh
curl -sSL https://raw.githubusercontent.com/shawal-mbalire/embed-check/master/embed | sudo tee /usr/local/bin/embed > /dev/null && sudo chmod +x /usr/local/bin/embed
```

- On **Linux** and **macOS**, this will install `embed` to `/usr/local/bin` and make it executable.
- On **Windows**, run the same command in Git Bash or WSL, or download the script and run it with `bash embed`. The script will auto-detect your OS and provide the right instructions or actions for your system.

Then run:

```sh
embed install
```

## Usage

```sh
embed <command> [options]
```

-   `embed new <project_name> [--lang <language>] [--board <board_name>]`: Initializes a new embedded project.
-   `embed add-module <module_name> --type <module_type> --conn <connection_type>`: Adds a new module to the current project.
-   `embed compile [--port <serial_port>]`: Compiles the current project and uploads it to the board.
-   `embed install`: Installs all required toolchains and dependencies.
-   `embed check-tools`: Checks the status of all supported toolchains.
-   `embed board list`: Lists all available boards.
-   `embed board search <term>`: Searches for a specific board.
-   `embed help`: Shows the help message.

## Supported Toolchains

-   **STM32**: arm-none-eabi-gcc, arm-none-eabi-gdb, st-flash, openocd, STM32CubeCLT
    -   **openocd**: Open On-Chip Debugger (OpenOCD) is an open-source tool that provides debugging, in-system programming, and boundary-scan testing for embedded target devices. It supports a wide range of microcontrollers and debug adapters.
-   **Espressif**: xtensa-esp32-elf-gcc, esptool, ESP-IDF
-   **Arduino**: arduino-cli, avrdude
-   **TI**: msp430-gcc, arm-none-eabi-gcc
-   **Microchip**: gputils, arm-none-eabi-gcc
-   **NXP, Renesas, SiLabs, Infineon, Nuvoton, GD32**: Various
-   **General**: cmake, make

## Project Structure

```
embed
src/
  main.py           # Python frontend for interactive commands
lib/
  colors.sh         # Color and icon variable definitions (exported)
  tool_meta.sh      # Tool metadata array and init_tools_meta function (exported)
  helpers.sh        # Generic helper functions (exported)
  states/
    init.sh         # init_state function (exported)
    parse_args.sh   # parse_args_state function (exported)
    check_tools.sh  # check_tools_state function (exported)
    install_tools.sh# install_tools_state function (exported)
    summary.sh      # summary_state function (exported)
    exit.sh         # exit_state function (exported)
    error.sh        # error_state function (exported)
families/
  arduino.sh        # Family-specific tool logic (one per MCU family)
  ...               # Other family scripts (stm32.sh, nxp.sh, etc.)
templates/
  rust/             # Rust project templates
  cpp/              # C++ project templates
test/
  embed-check.bats  # Bats test suite for the Bash script
.github/
  workflows/
    test-install.yml # GitHub Actions CI workflow
README.md           # Project documentation
requirements.txt    # Python dependencies
```

## Future Improvements

-   **Interactive Project Initialization:** Enhance `embed new` to provide interactive prompts for board selection, language choice, and other project settings, offering a more guided user experience.
-   **Interactive Module Addition:** Implement interactive prompts for `embed add-module` to guide users through selecting module types, connection interfaces, and naming conventions.
-   **Expanded Board Support:** Integrate board definitions from external open-source embedded projects (e.g., PlatformIO, Rust Embedded) to significantly expand the range of supported hardware and simplify board configuration.
-   **Dedicated Upload Command:** Separate the compilation and upload steps into distinct commands (`embed build` and `embed upload`) for greater flexibility. The `upload` command will handle board communication and flashing.
-   **Debugging Command:** Introduce an `embed debug` command to facilitate debugging sessions on target boards.
-   **More Language Support:** Explore adding support for other embedded programming languages (e.g., Assembly, Go).
-   **GUI (Optional):** Consider developing a web-based or desktop graphical user interface for an even more accessible and user-friendly experience.
-   **Improved Error Handling:** Enhance error reporting across both Bash and Python components for consistency and clarity.
-   **Robust Configuration Management:** Implement more centralized and flexible board definition management, potentially allowing user-defined board paths.
-   **Python Unit and Integration Tests:** Develop comprehensive unit and integration tests for the Python frontend to ensure reliability and prevent regressions.
-   **Standardized Output:** Introduce machine-readable output options (e.g., JSON) for Bash scripts to improve programmatic interaction and parsing by the Python frontend.
-   **Minimize Sudo Usage:** Explore alternatives to system-wide `sudo` installations for toolchains, favoring user-local installations or tool version managers.
-   **Dependency Verification:** Add checks for minimum required versions of external tools to ensure compatibility.

## License

MIT (or specify your license here)

## Best Practices for Bash Projects

-   Use [ShellCheck](https://www.shellcheck.net/) for static analysis and linting.
-   Write automated tests using [Bats](https://github.com/bats-core/bats-core).
-   Use CI (e.g., GitHub Actions) to run tests and lint on every push/PR.
-   Document usage, options, and exit codes clearly in the README.
-   Prefer POSIX-compliant syntax for portability.
-   Use `set -euo pipefail` in scripts for safer error handling.
-   Keep scripts modular and source family/tool logic from separate files.
-   Provide both human-readable and machine-readable output (e.g., add a --json flag).
-   Use consistent formatting and helpful color output for clarity.