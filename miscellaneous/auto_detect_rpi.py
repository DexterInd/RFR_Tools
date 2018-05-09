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

# RPI_VARIANTS was inspired from http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/
# This module is meant for retrieving the Raspberry Pi's generation model, PCB model (dimension-wise) and PCB revision
# Works with Python 3 & 2 !!!

# Each key represents the hardware revision number
# This isn't the same as the RaspberryPi revision
# Having the hardware revision number is useful when working with hardware or software.

RPI_VARIANTS = {
"0002" : ["Model B Rev 1", "RPI1"],

"0003" : ["Model B Rev 1 ECN0001 (no fuses, D14 removed)", "RPI1"],

"0004" : ["Model B Rev 2", "RPI1"],
"0005" : ["Model B Rev 2", "RPI1"],
"0006" : ["Model B Rev 2", "RPI1"],

"0007" : ["Model A", "RPI1"],
"0008" : ["Model A", "RPI1"],
"0009" : ["Model A", "RPI1"],

"000d" : ["Model B Rev 2", "RPI1"],
"000e" : ["Model B Rev 2", "RPI1"],
"000f" : ["Model B Rev 2", "RPI1"],

"0010" : ["Model B+", "RPI1"],
"0013" : ["Model B+", "RPI1"],
"900032" : ["Model B+", "RPI1"],

"0011" : ["Compute Module", "RPI-COMPUTE-MODULE"],
"0014" : ["Compute Module", "RPI-COMPUTE-MODULE"],

"0012" : ["Model A+", "RPI1"],
"0015" : ["Model A+", "RPI1"],

"a01041" : ["Pi 2 Model B v1.1", "RPI2"],
"a21041" : ["Pi 2 Model B v1.1", "RPI2"],

"a22042" : ["Pi 2 Model B v1.2", "RPI2"],

"900092" : ["Pi Zero v1.2", "RPI0"],

"900093" : ["Pi Zero v1.3", "RPI0"],

"9000C1" : ["Pi Zero W", "RPI0"],

"a02082" : ["Pi 3 Model B", "RPI3"],
"a22082" : ["Pi 3 Model B", "RPI3"],
"a020d3" : ["Pi 3 Model B+", "RPI3B+"],
}

# represents indexes for each corresponding key in the above dictionary
RPI_MODEL_AND_PCBREV = 0
RPI_GENERATION_MODEL = 1

def getRPIHardwareRevCode():
    """
    Returns the hardware revision of the Raspberry Pi.
    If it can't find anything, it returns "NOT_FOUND".
    If there's an error while reading the file, it returns a None.
    Examples of strings returned : "Model B Rev 2", "Model A+", "Pi 3 Model B", etc.
    Look into the dictionary to see all the possible variants.
    """
    cpuinfo_lines = readLinesFromFile("/proc/cpuinfo")
    rpi_description = ""

    if not cpuinfo_lines is None:
        revision_line = cpuinfo_lines[-2]
        revision = revision_line.split(":")[-1]
        revision = revision.strip()

        if revision in RPI_VARIANTS.keys():
            rpi_description = RPI_VARIANTS[revision][RPI_MODEL_AND_PCBREV]
        else:
            rpi_description = "NOT_FOUND"

    return rpi_description

def getRPIGenerationCode():
    """
    Returns the Raspberry Pi's generation model.
    If it can't find anything, it returns "NOT_FOUND".
    If there's an error while reading the file, it returns a None.
    Depending on the Raspberry Pi's model, the function can return the following strings:
    "RPI0"
    "RPI1"
    "RPi2"
    "RPI3"
    "RPI-COMPUTE-MODULE"
    """

    cpuinfo_lines = readLinesFromFile("/proc/cpuinfo")
    rpi_description = ""

    if not cpuinfo_lines is None:
        revision_line = cpuinfo_lines[-2]
        revision = revision_line.split(":")[-1]
        revision = revision.strip()

        if revision in RPI_VARIANTS.keys():
            rpi_description = RPI_VARIANTS[revision][RPI_GENERATION_MODEL]
        else:
            rpi_description = "NOT_FOUND"

    return rpi_description

def readLinesFromFile(filename):
    """
    Returns the read file as a list of strings.
    Each element of the list represents a line.
    On error it returns None.
    """
    try:
        with open(filename, "r") as input_file:
            lines = input_file.readlines()
        return lines

    except EnvironmentError:
        return None
