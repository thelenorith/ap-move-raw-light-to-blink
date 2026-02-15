# ap-move-raw-light-to-blink

[![Test](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/test.yml/badge.svg)](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/test.yml) [![Coverage](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/coverage.yml/badge.svg)](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/coverage.yml) [![Lint](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/lint.yml/badge.svg)](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/lint.yml) [![Format](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/format.yml/badge.svg)](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/format.yml) [![Type Check](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/typecheck.yml/badge.svg)](https://github.com/jewzaam/ap-move-raw-light-to-blink/actions/workflows/typecheck.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

A simple tool for moving and organizing astrophotography files from a raw directory to a destination directory, organizing them based on FITS header metadata.

## Overview

This tool moves and organizes LIGHT files from a raw directory to a destination directory, organizing them based on FITS header metadata into a multi-stage workflow.

## Documentation

This tool is part of the astrophotography pipeline. For comprehensive documentation including workflow guides and integration with other tools, see:

- **[Pipeline Overview](https://github.com/jewzaam/ap-base/blob/main/docs/index.md)** - Full pipeline documentation
- **[Workflow Guide](https://github.com/jewzaam/ap-base/blob/main/docs/workflow.md)** - Detailed workflow with diagrams
- **[ap-move-raw-light-to-blink Reference](https://github.com/jewzaam/ap-base/blob/main/docs/tools/ap-move-raw-light-to-blink.md)** - API reference for this tool

## Usage

```powershell
python -m ap_move_raw_light_to_blink <source_dir> <dest_dir> [--debug] [--dryrun] [--quiet] [--blink-dir DIR] [--accept-dir DIR] [--no-accept] [--help]
```

Options:
- `source_dir`: Source directory containing raw files
- `dest_dir`: Destination directory for organized files
- `--debug`: Enable debug output
- `--dryrun`: Perform dry run without actually moving files
- `--quiet` / `-q`: Suppress non-essential output
- `--blink-dir DIR`: Directory name for LIGHT files (default: "10_Blink")
- `--accept-dir DIR`: Directory name for accept subdirectories (default: "accept")
- `--no-accept`: Do not create accept subdirectories
- `--help`: Show help message and exit

## Installation

### Development

```bash
make install-dev
```

### From Git

```bash
pip install git+https://github.com/jewzaam/ap-move-raw-light-to-blink.git
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
    - `FILTER_<filter_name>_EXP_<exposure_seconds>/` - One subdirectory per filter/exposure combination (non-mosaic)
    - `FILTER_<filter_name>_EXP_<exposure_seconds>_PANEL_N/` - For mosaics, PANEL identifier is appended to the filter directory name (uses PANEL keyword from FITS header)
      - Within each filter/exposure directory:
        - `LIGHT_*.fit` - Individual light frames
        - `DARK_*.fit` - Master dark frames for that exposure
        - `FLAT_*.fit` - Master flat frames for that filter/exposure
- **Unreviewed files** - Files not yet reviewed during the blink stage remain in the target directory root

#### Example Structure

For a non-mosaic target:

```
10_Blink/
  └── M42/
      ├── accept/
      │   ├── DATE_2024-01-15/
      │   │   ├── FILTER_Ha_EXP_300/
      │   │   │   ├── LIGHT_Ha_300s_001.fit
      │   │   │   ├── LIGHT_Ha_300s_002.fit
      │   │   │   ├── DARK_Master_300s.fit
      │   │   │   └── FLAT_Master_Ha.fit
      │   │   └── FILTER_Oiii_EXP_300/
      │   │       ├── LIGHT_Oiii_300s_001.fit
      │   │       ├── DARK_Master_300s.fit
      │   │       └── FLAT_Master_Oiii.fit
      │   └── DATE_2024-01-16/
      │       └── FILTER_Ha_EXP_300/
      │           ├── LIGHT_Ha_300s_003.fit
      │           ├── LIGHT_Ha_300s_004.fit
      │           ├── DARK_Master_300s.fit
      │           └── FLAT_Master_Ha.fit
      └── LIGHT_Ha_300s_unreviewed.fit
```

For a mosaic target (using PANEL keyword):

```
10_Blink/
  └── IC1396/
      └── accept/
          └── DATE_2024-01-20/
              ├── FILTER_Ha_EXP_300_PANEL_1/
              │   ├── LIGHT_Ha_300s_panel1_001.fit
              │   ├── LIGHT_Ha_300s_panel1_002.fit
              │   ├── DARK_Master_300s.fit
              │   └── FLAT_Master_Ha.fit
              ├── FILTER_Ha_EXP_300_PANEL_2/
              │   ├── LIGHT_Ha_300s_panel2_001.fit
              │   ├── DARK_Master_300s.fit
              │   └── FLAT_Master_Ha.fit
              └── FILTER_Oiii_EXP_300_PANEL_1/
                  ├── LIGHT_Oiii_300s_panel1_001.fit
                  ├── DARK_Master_300s.fit
                  └── FLAT_Master_Oiii.fit
```
