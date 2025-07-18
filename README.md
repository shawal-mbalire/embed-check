# embed-check

A modular Bash tool to check, install, and summarize the status of common microcontroller development toolchains on Linux, macOS, and Windows (with Bash). Designed for both interactive use and CI/CD pipelines.

## Features
- Checks and installs toolchains for STM32, Espressif, Arduino, TI, Microchip, and more
- Colorful, aligned summary table with icons
- Idempotent and safe to re-run
- Verbose mode for extra info and sources
- Easily extensible: add more tools or families as needed
- **Cross-platform:** Auto-detects your OS and uses the right package manager or provides manual instructions

## Quick Install
Install the latest version directly from GitHub with this one-liner:

```sh
curl -sSL https://raw.githubusercontent.com/shawal-mbalire/embed-check/master/embed-check.sh | sudo tee /usr/local/bin/embed-check > /dev/null && sudo chmod +x /usr/local/bin/embed-check
```

- On **Linux** and **macOS**, this will install `embed-check` to `/usr/local/bin` and make it executable.
- On **Windows**, run the same command in Git Bash or WSL, or download the script and run it with `bash embed-check.sh`. The script will auto-detect your OS and provide the right instructions or actions for your system.

Then run:
```sh
embed-check
```

## Usage
```sh
embed-check [install|list|help] [--no-install] [-v|--verbose]
```

- `install` (default): Check and install missing tools
- `list`, `--list`: Show tool status only, do not install
- `-v`, `--verbose`: Verbose output (show sources, extra info)
- `--no-install`: Do not install missing tools (status only)
- `-h`, `--help`: Show help message

## Supported Toolchains
- **STM32**: arm-none-eabi-gcc, arm-none-eabi-gdb, st-flash, openocd, STM32CubeCLT
- **Espressif**: xtensa-esp32-elf-gcc, esptool, ESP-IDF
- **Arduino**: arduino-cli, avrdude
- **TI**: msp430-gcc, arm-none-eabi-gcc
- **Microchip**: gputils, arm-none-eabi-gcc
- **NXP, Renesas, SiLabs, Infineon, Nuvoton, GD32**: Various
- **General**: cmake, make

## Extending
To add a new microcontroller family, create a script in `families/` and source it in `embed-check.sh`.

## License
MIT (or specify your license here) 