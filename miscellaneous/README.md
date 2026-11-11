# mr-rfr-tools

Common Python utilities shared across Modular Robotics platforms (GoPiGo3, BrickPi3, GrovePi, PivotPi).

## Modules

### `auto_detect_robot`
Detects which Modular Robotics board(s) are connected to the Raspberry Pi.
Supports: **GoPiGo3**, GoPiGo, **BrickPi3**, BrickPi+, GrovePi, PivotPi.

```python
import auto_detect_robot

robot = auto_detect_robot.autodetect()
print(robot)  # e.g. "GoPiGo3"
```

### `auto_detect_rpi`
Identifies the Raspberry Pi model by reading `/proc/device-tree/model` — no lookup
table required, works with all current and future Pi hardware.

```python
import auto_detect_rpi

print(auto_detect_rpi.getRPIGenerationCode())   # e.g. "RPI4"
print(auto_detect_rpi.getRPIHardwareRevCode())  # e.g. "Raspberry Pi 4 Model B Rev 1.5"
```

Generation codes returned: `RPI0`, `RPI0-2`, `RPI1`, `RPI2`, `RPI3`, `RPI3B+`, `RPI3A+`,
`RPI4`, `RPI5`, `RPI-COMPUTE-MODULE`, `RPI-COMPUTE-MODULE3`, `RPI-COMPUTE-MODULE4`.

### `di_i2c`
I2C abstraction layer supporting multiple bus backends:

| Bus name | Hardware |
|---|---|
| `"RPI_1"` | Raspberry Pi hardware I2C (`/dev/i2c-1`) via `python-periphery` |
| `"RPI_1SW"` | Redirected to `RPI_1` (software I2C / wiringpi removed on Trixie) |
| `"GPG3_AD1"` | GoPiGo3 Grove port AD1 |
| `"GPG3_AD2"` | GoPiGo3 Grove port AD2 |
| `"BP3_1"` … `"BP3_4"` | BrickPi3 sensor ports 1–4 |

```python
from di_i2c import DI_I2C

bus = DI_I2C(bus="RPI_1", address=0x29)
bus.write_reg_8(0x00, 0x01)
value = bus.read_16(0x01)
```

Multiple sensors on different ports share a single underlying controller instance
automatically — no risk of SPI bus conflicts from duplicate `GoPiGo3()` constructors.

### `di_mutex` / `I2C_mutex`
File-based inter-process mutexes that prevent concurrent I2C bus access across
multiple Python processes.

`di_mutex.DI_Mutex` is used internally by `di_i2c`. `I2C_mutex.Mutex` is a
compatible alternative used by some legacy tools.

---

## Installation

### On the robot (Raspberry Pi)

```bash
pip install mr_rfr-tools
```

Or install directly from the repository for development:

```bash
git clone https://github.com/DexterInd/RFR_Tools
cd RFR_Tools/miscellaneous
pip install -e .
```

### Dependencies

| Package | Purpose |
|---|---|
| `python-periphery` | Hardware I2C on `/dev/i2c-1` (Trixie / Debian 12+) |
| `pyserial` | Serial port scanning in `auto_detect_robot` |

I2C must be enabled on the Pi before using `di_i2c` with `"RPI_1"`:

```bash
sudo raspi-config   # Interface Options → I2C → Enable
# or add dtparam=i2c_arm=on to /boot/firmware/config.txt and reboot
```

---

## Requirements

- Python 3.7+
- Raspberry Pi running Raspberry Pi OS (Trixie / Debian 12 recommended)

---

## License

MIT — see [LICENSE](../../LICENSE) or https://choosealicense.com/licenses/mit/
