'''
## License

The MIT License (MIT)

GrovePi for the Raspberry Pi: an open source platform for connecting Grove Sensors to the Raspberry Pi.
Copyright (C) 2017  Dexter Industries

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
'''

# auto_detect_rpi.py
# Detects the Raspberry Pi model by reading /proc/device-tree/model.
# This is the standard kernel interface — it works on all Pi models without
# requiring a manually-maintained revision-code lookup table.

import re

# Explicit overrides for models whose generation cannot be inferred from a
# plain integer (Pi 400 is Pi-4-based; Zero has no number; 3B+/3A+ are
# distinct variants; compute modules follow their own naming).
# Ordered most-specific first to avoid substring false-matches.
_GENERATION_RULES = [
    (r"raspberry pi 400",              "RPI4"),            # Pi 400 is Pi 4-based
    (r"raspberry pi 3 model b\+",      "RPI3B+"),
    (r"raspberry pi 3 model a\+",      "RPI3A+"),
    (r"raspberry pi zero 2",           "RPI0-2"),          # must come before "zero"
    (r"raspberry pi zero",             "RPI0"),
    (r"raspberry pi compute module 4", "RPI-COMPUTE-MODULE4"),
    (r"raspberry pi compute module 3", "RPI-COMPUTE-MODULE3"),
    (r"raspberry pi compute module",   "RPI-COMPUTE-MODULE"),
]

# Generic pattern: "Raspberry Pi <N>" → "RPI<N>".
# Handles Pi 2, 3, 4, 5, 6, … without needing explicit rules for each.
_NUMERIC_GENERATION_RE = re.compile(r"raspberry pi (\d+)", re.IGNORECASE)


def _read_device_tree_model():
    """Read the model string from /proc/device-tree/model (NUL-terminated)."""
    try:
        with open("/proc/device-tree/model", "r") as f:
            return f.read().rstrip('\x00').strip()
    except EnvironmentError:
        return None


def _get_generation_from_model(model_str):
    """Map a /proc/device-tree/model string to a generation code."""
    lower = model_str.lower()
    # Check explicit overrides first.
    for pattern, code in _GENERATION_RULES:
        if re.search(pattern, lower):
            return code
    # Generic numeric extraction: "Raspberry Pi 6 …" → "RPI6".
    m = _NUMERIC_GENERATION_RE.search(lower)
    if m:
        return "RPI" + m.group(1)
    # Catch-all for Pi 1 (model string has no generation number).
    if re.search(r"raspberry pi", lower):
        return "RPI1"
    return "NOT_FOUND_" + model_str


def getRPIHardwareRevCode():
    """
    Returns the Raspberry Pi model description string read from
    /proc/device-tree/model, e.g. "Raspberry Pi 4 Model B Rev 1.5".
    Returns "NOT_FOUND" if the string is empty.
    Returns None on read error (device tree not available).
    """
    model = _read_device_tree_model()
    if model is None:
        return None
    return model if model else "NOT_FOUND"


def getRPIGenerationCode():
    """
    Returns the Raspberry Pi generation code string.
    Possible return values:
        "RPI0"                  Raspberry Pi Zero (original)
        "RPI0-2"                Raspberry Pi Zero 2 W
        "RPI1"                  Raspberry Pi 1 (A, B, A+, B+)
        "RPI2"                  Raspberry Pi 2
        "RPI3"                  Raspberry Pi 3 Model B
        "RPI3B+"                Raspberry Pi 3 Model B+
        "RPI3A+"                Raspberry Pi 3 Model A+
        "RPI4"                  Raspberry Pi 4 / 400
        "RPI5"                  Raspberry Pi 5
        "RPI6", "RPI7", …       Future numbered models (auto-derived)
        "RPI-COMPUTE-MODULE"    Compute Module (original)
        "RPI-COMPUTE-MODULE3"   Compute Module 3 / 3+
        "RPI-COMPUTE-MODULE4"   Compute Module 4
        "NOT_FOUND_<string>"    Model present in device tree but not recognised
        None                    Error reading /proc/device-tree/model
    """
    model = _read_device_tree_model()
    if model is None:
        return None
    return _get_generation_from_model(model)


def readLinesFromFile(filename):
    """
    Returns the contents of a file as a list of lines, or None on error.
    """
    try:
        with open(filename, "r") as f:
            return f.readlines()
    except EnvironmentError:
        return None


if __name__ == '__main__':
    print(getRPIHardwareRevCode())
    print(getRPIGenerationCode())
