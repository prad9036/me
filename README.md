# CAPT: Custom APT Package Manager

CAPT is a command-line tool that allows you to install software from Debian (`.deb`) packages into your user's home directory, without requiring `sudo` or root access. It's a self-contained package manager that handles its own dependencies and shared library paths.

## Features

- **Sudo-less Installation**: Install packages without root privileges.
- **Dependency Resolution**: Automatically resolves and installs package dependencies.
- **Shared Library Management**: Automatically manages `LD_LIBRARY_PATH` for installed packages.
- **Self-Contained**: CAPT is a single script with no external dependencies required for its basic operation.

## Requirements

- Python 3.6+
- `apt-cache` and `apt-get` (or `apt`) for downloading packages.
- `ar` for extracting `.deb` files.
- `tar`, `zstd`, and `xz` for handling different compression formats.

## Installation

1.  Clone the repository or download the `capt` script.
2.  Navigate into the project directory:
    ```bash
    cd capt_project
    ```
3.  Run the installer script:
    ```bash
    ./install.sh
    ```
4.  Reload your shell configuration as instructed:
    ```bash
    source ~/.bashrc
    ```

## Usage

### Installing a Package

To install a package, use the `install` command:

```bash
capt install <package_name>
```

**Examples:**

```bash
capt install nano
capt install procps
capt install neofetch
```

### Removing a Package

To remove a package, use the `remove` command:

```bash
capt remove <package_name>
```

### Listing Installed Packages

To see a list of all installed packages, use the `list` command:

```bash
capt list
```

### Getting Package Information

To view detailed information about an installed package, use the `info` command:

```bash
capt info <package_name>
```

### Getting Help

To see the help message, use the `help` command:

```bash
capt help
```

## How It Works

CAPT works by creating a dedicated directory in your home folder (`~/.capt`) where it installs all the packages and their dependencies. Here's a breakdown of the process:

1.  **Installation Directory**: All files are installed into `~/.capt`.
2.  **Binary Linking**: Executables are symlinked to `~/.capt/bin`, which is added to your `PATH`.
3.  **Dependency Resolution**: `apt-cache depends` is used to find all the dependencies of a package.
4.  **Package Downloading**: `apt download` is used to download the `.deb` packages.
5.  **Extraction**: The `.deb` packages are extracted using `ar` and `tar`.
6.  **Shared Libraries**: The `LD_LIBRARY_PATH` is automatically updated to include the directories containing the shared libraries of the installed packages.
7.  **Manifest**: A JSON file (`~/.capt/installed.json`) is used to keep track of the installed packages, their files, and dependencies.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
