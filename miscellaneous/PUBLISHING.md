# Publishing to PyPI / TestPyPI

## Prerequisites

```bash
pip install build twine
```

You will need API tokens from:
- **TestPyPI**: https://test.pypi.org/manage/account/token/
- **PyPI**: https://pypi.org/manage/account/token/

Store them in `~/.pypirc` (never commit this file):

```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
repository = https://upload.pypi.org/legacy/
username = __token__
password = pypi-<your-pypi-token>

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-<your-testpypi-token>
```

## Step 1 — bump the version

Edit `version` in `pyproject.toml` before every release:

```toml
version = "2.0.1"
```

## Step 2 — build the distribution

From the `miscellaneous/` directory:

```bash
cd RFR_Tools/miscellaneous
python -m build
```

This produces two files in `dist/`:
- `mr_rfr_tools-2.0.1.tar.gz` — source distribution
- `mr_rfr_tools-2.0.1-py3-none-any.whl` — wheel

## Step 3 — publish to TestPyPI first

```bash
twine upload --repository testpypi dist/*
```

Verify the install from TestPyPI:

```bash
pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ mr_rfr-tools==2.0.1
python -c "import di_i2c; print('ok')"
```

## Step 4 — publish to PyPI

Once satisfied:

```bash
twine upload dist/*
```

The package is then installable on any Pi with:

```bash
pip install mr_rfr-tools
```

## Cleanup

```bash
rm -rf dist/ build/ *.egg-info
```
