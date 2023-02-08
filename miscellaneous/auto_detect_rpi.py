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

# For every change brought to this file, don't forget to update its counterpart in DexterOS.

# RPI_VARIANTS
# This module is meant for retrieving the Raspberry Pi's generation model, PCB model (dimension-wise) and PCB revision
# the official list is https://www.raspberrypi.org/documentation/hardware/raspberrypi/revision-codes/README.md
# first inspired from http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/
# Also check https://elinux.org/RPi_HardwareHistory for missing revision codes.
# Works with Python 3 & 2 !!!

# Each key represents the hardware revision number
# This isn't the same as the RaspberryPi revision
# Having the hardware revision number is useful when working with hardware or software.

RPI_VARIANTS = {
"0002" : ["Model B Rev v1.0", "RPI1"],

"0003" : ["Model B Rev v1.0 ECN0001 (no fuses, D14 removed)", "RPI1"],

"0004" : ["Model B Rev v2.0", "RPI1"],
"0005" : ["Model B Rev v2.0", "RPI1"],
"0006" : ["Model B Rev v2.0", "RPI1"],

"0007" : ["Model A v2.0", "RPI1"],
"0008" : ["Model A v2.0", "RPI1"],
"0009" : ["Model A v2.0", "RPI1"],

"000d" : ["Model B Rev v2.0", "RPI1"],
"000e" : ["Model B Rev v2.0", "RPI1"],
"000f" : ["Model B Rev v2.0", "RPI1"],

"0010" : ["Model B+ v1.2", "RPI1"],
"0013" : ["Model B+ v1.2", "RPI1"],
"900032" : ["Model B+ v1.2", "RPI1"],

"0011" : ["Compute Module v1.0", "RPI-COMPUTE-MODULE"],
"0014" : ["Compute Module v1.0", "RPI-COMPUTE-MODULE"],

"900061" : ["Compute Module v1.1", "RPI-COMPUTE-MODULE"],

"0012" : ["Model A+ v1.1", "RPI1"],
"0015" : ["Model A+ v1.1", "RPI1"],
"900021" : ["Model A+ v1.1", "RPI1"],

"a01040" : ["Pi 2 Model B v1.0", "RPI2"],

"a01041" : ["Pi 2 Model B v1.1", "RPI2"],
"a21041" : ["Pi 2 Model B v1.1", "RPI2"],

"a22042" : ["Pi 2 Model B v1.2", "RPI2"],
"a02042" : ["Pi 2 Model B v1.2", "RPI2"],

"900092" : ["Pi Zero v1.2 Sony", "RPI0"],
"920092" : ["Pi Zero v1.2 Embest", "RPI0"],

"900093" : ["Pi Zero v1.3 Sony", "RPI0"],
"920093" : ["Pi Zero v1.3 Embest", "RPI0"],

"9000C1" : ["Pi Zero W v1.1", "RPI0"],

"902120" : ["Pi Zero 2W v1.0", "RPI0-2"],

"a02082" : ["Pi 3 Model B v1.2", "RPI3"],
"a22082" : ["Pi 3 Model B v1.2", "RPI3"],
"a32082" : ["Pi 3 Model B v1.2", "RPI3"],
"a52082" : ["Pi 3 Model B v1.2", "RPI3"],
"a22083" : ["Pi 3 Model B v1.3", "RPI3"],

"a020d3" : ["Pi 3 Model B+ v1.3", "RPI3B+"],

"9020e0" : ["Pi 3 Model A+ v1.0", "RPI3A+"],

"a03111" : ["Pi 4 Model B 1G v1.1", "RPI4"],
"b03111" : ["Pi 4 Model B 2G v1.1", "RPI4"],
"b03112" : ["Pi 4 Model B 2G v1.2", "RPI4"],
"b03114" : ["Pi 4 Model B 2G v1.4", "RPI4"],
"b03115" : ["Pi 4 Model B 2G v1.5", "RPI4"],
"c03111" : ["Pi 4 Model B 4G v1.1", "RPI4"],
"c03112" : ["Pi 4 Model B 4G v1.2", "RPI4"],
"c03114" : ["Pi 4 Model B 4G v1.4", "RPI4"],
"c03115" : ["Pi 4 Model B 4G v1.5", "RPI4"],
"d03114" : ["Pi 4 Model B 8G v1.4", "RPI4"],
"d03115" : ["Pi 4 Model B 8G v1.5", "RPI4"],

"c03130" : ["Pi 400 v1.0", "RPI400"],

"a020a0" : ["Compute Module 3 v1.0", "RPI-COMPUTE-MODULE3"],
"a220a0" : ["Compute Module 3 v1.0 Embest", "RPI-COMPUTE-MODULE3"],
"a02100" : ["Compute Module 3+ v1.0", "RPI-COMPUTE-MODULE3"],

"a03140" : ["Compute Module 4 1G v1.0", "RPI-COMPUTE-MODULE4"],
"b03140" : ["Compute Module 4 2G v1.0", "RPI-COMPUTE-MODULE4"],
"c03140" : ["Compute Module 4 4G v1.0", "RPI-COMPUTE-MODULE4"],
"d03140" : ["Compute Module 4 8G v1.0", "RPI-COMPUTE-MODULE4"]
}

# represents indexes for each corresponding key in the above dictionary
RPI_MODEL_AND_PCBREV = 0
RPI_GENERATION_MODEL = 1

def find_revision_line(lines):
    for line in lines:
        if line.split("\t")[0] == "Revision":
            return line



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

    if  cpuinfo_lines is not None:
        revision_line = find_revision_line(cpuinfo_lines)
        revision = revision_line.split(":")[-1]
        revision = revision.strip()

        if revision in RPI_VARIANTS.keys():
            rpi_description = RPI_VARIANTS[revision][RPI_MODEL_AND_PCBREV]
        else:
            rpi_description = "NOT_FOUND_" + revision

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
    "RPI3B+"
    "RPI3A+"
    "RPI4"
    "RPI-COMPUTE-MODULE"
    """

    cpuinfo_lines = readLinesFromFile("/proc/cpuinfo")
    rpi_description = ""

    if not cpuinfo_lines is None:
        revision_line = find_revision_line(cpuinfo_lines)
        revision = revision_line.split(":")[-1]
        revision = revision.strip()

        if revision in RPI_VARIANTS.keys():
            rpi_description = RPI_VARIANTS[revision][RPI_GENERATION_MODEL]
        else:
            rpi_description = "NOT_FOUND_" + revision

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

if __name__ == '__main__':

    print( getRPIGenerationCode())
