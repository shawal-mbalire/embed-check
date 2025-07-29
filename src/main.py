import typer
from rich.console import Console
from typing_extensions import Annotated
import subprocess
import os
import shutil
import json
import sys
import re
from rich.table import Table
from rich.panel import Panel

app = typer.Typer(help="A beautiful CLI for embedded development.")
board_app = typer.Typer(help="Commands for managing development boards.")
app.add_typer(board_app, name="board")
console = Console()

def _find_project_root():
    current_dir = os.getcwd()
    while True:
        if os.path.exists(os.path.join(current_dir, ".board.json")):
            return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:  # Reached the root directory
            return None
        current_dir = parent_dir

def _get_project_language():
    board_file = ".board.json"
    if not os.path.exists(board_file):
        console.print(Panel("[bold red]Error: Not in a project directory. '.board.json' not found.[/bold red]", title="[bold red]Project Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)
    with open(board_file, "r") as f:
        config = json.load(f)
    return config.get("language")

def _generate_rust_module(module_name, module_type, connection_type):
    content = f"// {module_name} {module_type} module (Rust) - {connection_type} connection\n"
    content += f"pub struct {module_name.capitalize()}<'a> {{\n"
    content += f"    // Add {connection_type} specific fields here\n"
    content += f"}}\n\n"
    content += f"impl<'a> {module_name.capitalize()}<'a> {{\n"
    content += f"    pub fn new() -> Self {{\n"
    content += f"        // Initialize {module_name} module\n"
    content += f"        Self {{}}\n"
    content += f"    }}\n\n"
    content += f"    pub fn read(&mut self) -> u32 {{\n"
    content += f"        // Read data from {module_name}\n"
    content += f"        0\n"
    content += f"    }}\n\n"
    content += f"    pub fn write(&mut self, value: u32) {{\n"
    content += f"        // Write data to {module_name}\n"
    content += f"    }}\n"
    content += f"}}\n"
    return content

def _generate_cpp_module(module_name, module_type, connection_type):
    content = f"// {module_name} {module_type} module (C++) - {connection_type} connection\n"
    content += f"#ifndef {module_name.upper()}_H\n"
    content += f"#define {module_name.upper()}_H\n\n"
    content += f"#include <cstdint>\n\n"
    content += f"class {module_name.capitalize()} {{\n"
    content += f"public:\n"
    content += f"    {module_name.capitalize()}();\n"
    content += f"    uint32_t read();\n"
    content += f"    void write(uint32_t value);\n"
    content += f"private:\n"
    content += f"    // Add {connection_type} specific fields here\n"
    content += f"}}\n\n"
    content += f"#endif // {module_name.upper()}_H\n\n"

    impl_content = f"// {module_name} {module_type} module (C++) implementation\n"
    impl_content += f"#include \"{module_name}.h\"\n\n"
    impl_content += f"{module_name.capitalize()}::{module_name.capitalize()}() {{\n"
    impl_content += f"    // Initialize {module_name} module\n"
    impl_content += f"}}\n\n"
    impl_content += f"uint32_t {module_name.capitalize()}::read() {{\n"
    impl_content += f"    // Read data from {module_name}\n"
    impl_content += f"    return 0;\n"
    impl_content += f"}}\n\n"
    return content, impl_content

@app.command()
def new(
    project_name: Annotated[str, typer.Argument(help="Name of the new project.")],
    language: Annotated[str, typer.Option("--lang", "-l", help="Programming language (rust or cpp).")] = "cpp",
    board: Annotated[str, typer.Option("--board", "-b", help="Target board (e.g., esp32dev, stm32f103c8).")] = "tivac-launchpad",
):
    """
    Initializes a new embedded project.
    """
    console.print(Panel(f"[bold green]Creating new project: {project_name}[/bold green]\n  Language: {language}\n  Board: {board}", title="[bold blue]Project Initialization[/bold blue]", border_style="blue"))

    project_path = os.path.join(os.getcwd(), project_name)
    if os.path.exists(project_path):
        console.print(Panel(f"[bold red]Error: Project directory '{project_name}' already exists.[/bold red]", title="[bold red]Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

    template_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "templates", language)
    if not os.path.exists(template_path):
        console.print(Panel(f"[bold red]Error: Template for language '{language}' not found.[/bold red]", title="[bold red]Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

    try:
        shutil.copytree(template_path, project_path)
        console.print(Panel(f"[bold green]Copied {language} template to {project_path}[/bold green]", title="[bold green]Template Copy[/bold green]", border_style="green"))

        board_config = {
            "name": board,
            "language": language
        }
        with open(os.path.join(project_path, ".board.json"), "w") as f:
            json.dump(board_config, f, indent=2)
        console.print(Panel(f"[bold green]Created .board.json in {project_path}[/bold green]", title="[bold green]Board Configuration[/bold green]", border_style="green"))

        console.print(Panel(f"[bold green]Project '{project_name}' initialized successfully![/bold green]", title="[bold green]Success[/bold green]", border_style="green"))
    except Exception as e:
        console.print(Panel(f"[bold red]Error initializing project: {e}[/bold red]", title="[bold red]Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

@app.command()
def add_module(
    module_name: Annotated[str, typer.Argument(help="Name of the new module.")],
    module_type: Annotated[str, typer.Option("--type", "-t", help="Type of module (e.g., sensor, actuator).")],
    connection_type: Annotated[str, typer.Option("--conn", "-c", help="Connection type (e.g., I2C, SPI, GPIO).")],
):
    """
    Adds a new module (sensor or actuator) to the current project.
    """
    console.print(Panel(f"[bold green]Adding new module: {module_name}[/bold green]\n  Type: {module_type}\n  Connection: {connection_type}", title="[bold blue]Module Addition[/bold blue]", border_style="blue"))

    language = _get_project_language()
    if not language:
        raise typer.Exit(code=1)

    module_dir = os.path.join(os.getcwd(), "modules")
    os.makedirs(module_dir, exist_ok=True)

    if language == "rust":
        file_name = os.path.join(module_dir, f"{module_name}.rs")
        content = _generate_rust_module(module_name, module_type, connection_type)
        with open(file_name, "w") as f:
            f.write(content)
        console.print(Panel(f"[bold green]Created Rust module file: {file_name}[/bold green]", title="[bold green]File Creation[/bold green]", border_style="green"))
    elif language == "cpp":
        header_file = os.path.join(module_dir, f"{module_name}.h")
        source_file = os.path.join(module_dir, f"{module_name}.cpp")
        header_content, source_content = _generate_cpp_module(module_name, module_type, connection_type)
        with open(header_file, "w") as f:
            f.write(header_content)
        with open(source_file, "w") as f:
            f.write(source_content)
        console.print(Panel(f"[bold green]Created C++ module header: {header_file}[/bold green]\n[bold green]Created C++ module source: {source_file}[/bold green]", title="[bold green]File Creation[/bold green]", border_style="green"))
    else:
        console.print(Panel(f"[bold red]Error: Unsupported language '{language}' for module generation.[/bold red]", title="[bold red]Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

    console.print(Panel(f"[bold green]Module '{module_name}' added successfully![/bold green]", title="[bold green]Success[/bold green]", border_style="green"))

@app.command()
def compile(
    ctx: typer.Context,
    port: Annotated[str, typer.Option("--port", "-p", help="Serial port for upload.")] = None,
):
    """
    Compiles the current project and uploads it to the board.
    """
    project_root = ctx.obj.get("project_root")
    board_config = ctx.obj.get("board_config")

    if not project_root or not board_config:
        console.print(Panel("[bold red]Error: Not in an embedded project directory. Please run 'embed new' first.[/bold red]", title="[bold red]Error[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

    console.print(Panel(f"[bold blue]Compiling and uploading project for board: {board_config['name']}[/bold blue]", title="[bold blue]Compilation & Upload[/bold blue]", border_style="blue"))
    
    embed_script_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "embed")
    command = [embed_script_path, "upload"]
    if port:
        command.append(f"--port={port}")
    command.append(f"--board={board_config['name']}")
    command.append(f"--project-path={project_root}") # Pass project path to embed script

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True, cwd=os.path.dirname(embed_script_path))
        console.print(Panel(result.stdout, title="[bold green]Compilation and Upload Complete[/bold green]", border_style="green"))
        if result.stderr:
            console.print(Panel(result.stderr, title="[bold yellow]Compilation and Upload Warnings/Errors[/bold yellow]", border_style="yellow"))
    except subprocess.CalledProcessError as e:
        console.print(Panel(f"Compilation and upload failed with error code {e.returncode}:\n{e.stdout}\n{e.stderr}", title="[bold red]Compilation and Upload Failed[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

def _get_openocd_board_name(file_path):
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('#'):
                comment_text = line[1:].strip()
                # Look for specific patterns like "This is an XYZ board"
                match = re.search(r"This is an (.+?)\s+(board|kit)", comment_text, re.IGNORECASE)
                if match:
                    return match.group(1).strip()
                # Fallback to general comment if no specific pattern found
                if "board" in comment_text.lower() or "kit" in comment_text.lower():
                    return comment_text
    return os.path.basename(file_path).replace(".cfg", "")

@board_app.command("list")
def board_list():
    """
    Lists all available boards.
    """
    console.print("[bold blue]Listing available boards...[/bold blue]")
    
    table = Table(title="[bold magenta]Available Boards[/bold magenta]")
    table.add_column("Board Name", style="cyan", no_wrap=True)
    table.add_column("Config File", style="green")

    # Add boards from project's boards/ directory
    boards_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "boards")
    for board_file in os.listdir(boards_dir):
        if board_file.endswith(".json"):
            file_path = os.path.join(boards_dir, board_file)
            try:
                with open(file_path, "r") as f:
                    config = json.load(f)
                board_name = config.get("name", "N/A")
                config_file = board_file.replace(".json", "")
                table.add_row(board_name, config_file)
            except Exception as e:
                console.print(f"[bold red]Error reading {board_file}: {e}[/bold red]")

    # Add boards from OpenOCD config directory
    openocd_board_dir = os.environ.get("EMBED_OPENOCD_BOARD_DIR", "/usr/share/openocd/scripts/board")
    if os.path.exists(openocd_board_dir):
        for board_file in os.listdir(openocd_board_dir):
            if board_file.endswith(".cfg"):
                file_path = os.path.join(openocd_board_dir, board_file)
                try:
                    board_name = _get_openocd_board_name(file_path)
                    config_file = board_file
                    table.add_row(board_name, config_file)
                except Exception as e:
                    console.print(f"[bold red]Error reading {board_file}: {e}[/bold red]")
    else:
        console.print(f"[bold yellow]Warning: OpenOCD board directory not found at {openocd_board_dir}. Skipping OpenOCD board listing.[/bold yellow]")
    
    console.print(table)

@board_app.command("search")
def board_search(
    term: Annotated[str, typer.Argument(help="Search term for boards.")]
):
    """
    Searches for a specific board.
    """
    console.print(f"[bold blue]Searching for boards matching '{term}'...[/bold blue]")
    
    table = Table(title=f"[bold magenta]Search Results for '{term}'[/bold magenta]")
    table.add_column("Board Name", style="cyan", no_wrap=True)
    table.add_column("Config File", style="green")

    found_boards = False

    # Search in project's boards/ directory
    boards_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "boards")
    for board_file in os.listdir(boards_dir):
        if board_file.endswith(".json"):
            file_path = os.path.join(boards_dir, board_file)
            try:
                with open(file_path, "r") as f:
                    config = json.load(f)
                board_name = config.get("name", "N/A")
                config_file = board_file.replace(".json", "")
                
                if term.lower() in board_name.lower() or term.lower() in config_file.lower():
                    table.add_row(board_name, config_file)
                    found_boards = True
            except Exception as e:
                console.print(f"[bold red]Error reading {board_file}: {e}[/bold red]")

    # Search in OpenOCD config directory
    openocd_board_dir = os.environ.get("EMBED_OPENOCD_BOARD_DIR", "/usr/share/openocd/scripts/board")
    if os.path.exists(openocd_board_dir):
        for board_file in os.listdir(openocd_board_dir):
            if board_file.endswith(".cfg"):
                file_path = os.path.join(openocd_board_dir, board_file)
                try:
                    board_name = _get_openocd_board_name(file_path)
                    config_file = board_file
                    
                    if term.lower() in board_name.lower() or term.lower() in config_file.lower():
                        table.add_row(board_name, config_file)
                        found_boards = True
                except Exception as e:
                    console.print(f"[bold red]Error reading {board_file}: {e}[/bold red]")
    else:
        console.print(f"[bold yellow]Warning: OpenOCD board directory not found at {openocd_board_dir}. Skipping OpenOCD board search.[/bold yellow]")
    
    if not found_boards:
        console.print(Panel(f"[bold yellow]No boards found matching '{term}'.[/bold yellow]", title="[bold yellow]No Results[/bold yellow]", border_style="yellow"))
    else:
        console.print(table)

@app.command()
def install():
    """
    Installs required toolchains.
    """
    console.print("[bold blue]Installing required toolchains...[/bold blue]")
    embed_script_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "embed")
    try:
        result = subprocess.run([embed_script_path, "install"], capture_output=True, text=True, check=True, cwd=os.path.dirname(embed_script_path))
        console.print(Panel(result.stdout, title="[bold green]Toolchain Installation Summary[/bold green]", border_style="green"))
        if result.stderr:
            console.print(Panel(result.stderr, title="[bold yellow]Toolchain Installation Warnings/Errors[/bold yellow]", border_style="yellow"))
    except subprocess.CalledProcessError as e:
        console.print(Panel(f"Toolchain installation failed with error code {e.returncode}:\n{e.stdout}\n{e.stderr}", title="[bold red]Toolchain Installation Failed[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

@app.command("check-tools")
def check_tools_command():
    """
    Checks the status of all supported toolchains and displays them in a table.
    """
    console.print("[bold blue]Checking toolchain status...[/bold blue]")
    embed_script_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "embed")
    try:
        result = subprocess.run([embed_script_path, "check-tools"], capture_output=True, text=True, cwd=os.path.dirname(embed_script_path))
        
        table = Table(title="[bold magenta]Toolchain Status Summary[/bold magenta]")
        table.add_column("Tool", style="cyan", no_wrap=True)
        table.add_column("Status", style="magenta")
        table.add_column("Path/Details", style="green")

        # Parse the output
        lines = result.stdout.strip().split('\n')
        # Skip the header and divider lines
        data_lines = [line for line in lines if "│" in line and "---" not in line]

        for line in data_lines:
            parts = line.split('│')
            if len(parts) >= 3:
                tool = parts[0].strip()
                status = parts[1].strip()
                path = '│'.join(parts[2:]).strip() # Join remaining parts for path/details
                
                # Add color to status
                if "✔ Installed" in status:
                    status = "[bold green]✔ Installed[/bold green]"
                elif "✖ NOT Installed" in status:
                    status = "[bold red]✖ NOT Installed[/bold red]"
                
                table.add_row(tool, status, path)
        
        console.print(table)

    except subprocess.CalledProcessError as e:
        console.print(Panel(f"Toolchain check failed with error code {e.returncode}:\n{e.stdout}\n{e.stderr}", title="[bold red]Toolchain Check Failed[/bold red]", border_style="red"))
        raise typer.Exit(code=1)

@app.callback()
def main(
    ctx: typer.Context,
    verbose: Annotated[bool, typer.Option("--verbose", "-v", help="Enable verbose output.")] = False,
):
    """
    Embed-Check CLI for embedded development.
    """
    ctx.ensure_object(dict)
    ctx.obj["verbose"] = verbose

    project_root = _find_project_root()
    if project_root:
        ctx.obj["project_root"] = project_root
        with open(os.path.join(project_root, ".board.json"), "r") as f:
            ctx.obj["board_config"] = json.load(f)

    if verbose:
        console.print(Panel("[bold yellow]Verbose mode enabled.[/bold yellow]", title="[bold yellow]Verbose Output[/bold yellow]", border_style="yellow"))

if __name__ == "__main__":
    if len(sys.argv) == 1:
        # Display a welcome message when no arguments are provided
        welcome_message = Panel(
            "[bold blue]Welcome to embed-check![/bold blue]\n\n" 
            "Your beautiful CLI for embedded development.\n\n" 
            "[cyan]Use 'embed help' to see available commands.[/cyan]",
            title="[bold green]🚀 embed-check CLI 🚀[/bold green]",
            subtitle="[italic grey]Streamlining your embedded workflow[/italic grey]",
            border_style="magenta",
            expand=False
        )
        console.print(welcome_message)
    else:
        app()