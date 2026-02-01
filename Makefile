PYTHON := python

.PHONY: install install-dev uninstall clean format lint typecheck test test-verbose coverage default

default: format lint typecheck test coverage

install:
	$(PYTHON) -m pip install .

install-dev:
	$(PYTHON) -m pip install -e ".[dev]"

uninstall:
	$(PYTHON) -m pip uninstall -y ap-move-raw-light-to-blink

clean:
	rm -rf build/ dist/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

format: install-dev
	$(PYTHON) -m black ap_move_raw_light_to_blink tests

lint: install-dev
	$(PYTHON) -m flake8 --max-line-length=88 --extend-ignore=E203,W503,E501,F401 ap_move_raw_light_to_blink tests

test: install-dev
	$(PYTHON) -m pytest

test-verbose: install-dev
	$(PYTHON) -m pytest -v

typecheck: install-dev
	$(PYTHON) -m mypy ap_move_raw_light_to_blink || true

coverage: install-dev
	$(PYTHON) -m pytest --cov=ap_move_raw_light_to_blink --cov-report=term
