# ap-copy-lights

A simple tool for copying and organizing astrophotography files from a raw directory to a destination directory, organizing them based on FITS header metadata.

## Overview

This tool reads FITS headers from astrophotography files and organizes them into a structured directory tree based on metadata (optic, camera, target, date, filter, etc.). It processes all file types (BIAS, DARK, FLAT, LIGHT) and places LIGHT files in a `10_Blink` subdirectory.

## Usage

### Command Line (After Installation)

```powershell
ap-copy-lights <source_dir> <dest_dir> [--debug] [--dryrun] [--help]
```

Options:
- `source_dir`: Source directory containing raw files
- `dest_dir`: Destination directory for organized files
- `--debug`: Enable debug output
- `--dryrun`: Perform dry run without actually copying files
- `--help`: Show help message and exit

## Installation

### Option 1: Using pip (Recommended)

```powershell
pip install .
```

For development (editable install):
```powershell
pip install -e .
```

### Option 2: Using Make (if you have make installed)

```powershell
make install
```

For development:
```powershell
make install-dev
```

### After Installation

Once installed, the `ap-copy-lights` command will be available system-wide:

```powershell
ap-copy-lights <source_dir> <dest_dir> [--debug] [--dryrun] [--help]
```

### Development Setup

For development with additional tools:

```powershell
pip install -e ".[dev]"
```

This installs the package in editable mode along with development dependencies.

### Uninstallation

```powershell
pip uninstall ap-copy-lights
```

Or using Make:
```powershell
make uninstall
```

## How It Works

1. Scans the source directory for FITS files (and other supported formats)
2. Reads FITS headers to extract metadata (camera, optic, target, date, filter, etc.)
3. Organizes files into directory structure:
   - `{optic}+{camera}` for BIAS, DARK, FLAT
   - `{optic}@f{focal_ratio}+{camera}\10_Blink\{target}\DATE_{date}\...` for LIGHT files
4. Creates `accept` subdirectories for manual review
5. Cleans up empty directories in the source location

## File Structure

```
ap_copy_lights/
  ├── __init__.py
  ├── copy_lights.py  # Main script
  └── config.py       # Project-specific configuration
```
