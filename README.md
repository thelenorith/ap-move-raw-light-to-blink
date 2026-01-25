# ap-move-lights

A simple tool for moving and organizing astrophotography files from a raw directory to a destination directory, organizing them based on FITS header metadata.

## Overview

This tool moves and organizes LIGHT files from a raw directory to a destination directory, organizing them based on FITS header metadata into a multi-stage workflow.

## Usage

```powershell
python -m ap_move_lights.move_lights <source_dir> <dest_dir> [--debug] [--dryrun] [--blink-dir DIR] [--accept-dir DIR] [--no-accept] [--help]
```

Options:
- `source_dir`: Source directory containing raw files
- `dest_dir`: Destination directory for organized files
- `--debug`: Enable debug output
- `--dryrun`: Perform dry run without actually moving files
- `--blink-dir DIR`: Directory name for LIGHT files (default: "10_Blink")
- `--accept-dir DIR`: Directory name for accept subdirectories (default: "accept")
- `--no-accept`: Do not create accept subdirectories
- `--help`: Show help message and exit

## Installation

### From Source (Development)

```powershell
make install-dev
```

This installs the package in editable mode along with all dependencies (including `ap-common` from git) and development tools.

### From Git Repository (One-liner)

```powershell
pip install git+https://github.com/jewzaam/ap-move-lights.git
```

This installs the package directly from the GitHub repository without requiring a local checkout.

### Uninstallation

```powershell
make uninstall
```

## How It Works

1. Scans `source_dir` for FITS files (and other supported formats)
2. Reads FITS headers to extract metadata (camera, optic, target, date, filter, etc.)
3. Moves LIGHT files to `dest_dir`, organizing them into workflow stages at `dest_dir\{optic}@f{focal_ratio}+{camera}\10_Blink\{target}\DATE_{date}\...`
4. Creates `accept` subdirectories for manual review within each LIGHT target directory
5. Cleans up empty directories in `source_dir`

## Workflow Stages

This tool organizes LIGHT files into a multi-stage data processing workflow. The directory structure for LIGHT files is organized as:

```
{dest_dir}/
  └── {optic}@f{focal_ratio}+{camera}/
      ├── 10_Blink/  # This tool moves LIGHT files here (default: "10_Blink")
      ├── 20_Data/
      ├── 30_Master/
      ├── 40_Process/
      ├── 50_Bake/
      └── 60_Done/
```

**Note**: The workflow stages are created and managed manually as you move target directories between stages. This tool only moves LIGHT files into the initial stage directory (default: `10_Blink`).

### Stage Descriptions

Stages are numbered with 2-digit prefixes to allow inserting new stages without renumbering:

1. **`10_Blink`** (default) - First stage where LIGHT files are initially moved by this tool. This is where you review and blink (visual quality check) your images.

2. **`20_Data`** - After blinking, target directory is moved here to collect more data, add to data logs, or handle calibration needs (flats, darks).

3. **`30_Master`** - Done collecting data, time to create master lights.

4. **`40_Process`** - Working on processing the final image. Kept available for PixInsight adjustments.

5. **`50_Bake`** - Think processing is done, but likely needs review before moving to "done". Not yet published.

6. **`60_Done`** - Really done, published on astrobin. Ready for long-term backup.

### Target Directory Structure

Within each stage directory, targets are organized as subdirectories. Each target directory contains:

- **`accept/`** - All lights that survived blink, organized as:
  - `DATE_CCYY-MM-DD/` - One subdirectory per day
    - `FILTER_<filter_name>_EXP_<exposure_seconds>/` - One subdirectory per filter/exposure combination
    - Master darks and flats for that night (duplicated here for convenience)
  - `PANEL_N/` - For mosaics, one subdirectory per panel (uses PANEL keyword in WBPP)

- **`master/`** - Processed master lights, organized as:
  - `CCYY-MM-DD/` - Date the master was created
    - `1x/`, `2x/`, etc. - Drizzle level subdirectories

### Workflow Notes

- **Master calibration files**: Master darks and flats are copied into each DATE directory within `accept/`. This duplication ensures you never lose reference data even if the dark library is deleted, and makes WBPP setup simple (just load the entire `accept` directory).

- **Calibrated files**: Not kept - they're created in a temporary directory and deleted after use. Only raw lights with master darks/flats are retained.

- **Moving between stages**: After blinking and accepting lights in a target directory, delete unwanted files and move the entire target directory (including `accept` and `master` subdirectories) to the next stage.

The workflow is organized by target, with numbered stage directories tracking the current state of each target's processing pipeline.

## File Structure

```
ap_move_lights/
  ├── __init__.py
  ├── move_lights.py  # Main script
  └── config.py       # Project-specific configuration
```
