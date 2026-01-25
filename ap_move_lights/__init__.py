"""
ap-move-lights: Move and organize astrophotography files based on FITS header metadata.
"""

import re
from pathlib import Path


def _get_version() -> str:
    """Get version from pyproject.toml or fallback to default."""
    pyproject_path = Path(__file__).parent.parent / "pyproject.toml"
    if pyproject_path.exists():
        try:
            content = pyproject_path.read_text(encoding="utf-8")
            match = re.search(
                r'^version\s*=\s*["\']([^"\']+)["\']', content, re.MULTILINE
            )
            if match:
                return match.group(1)
        except Exception:
            pass
    return "0.1.0"


__version__ = _get_version()
