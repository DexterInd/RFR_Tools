#! /bin/bash
# Copyright Dexter Industries, 2015.
# Install the Troubleshooting GUI.
# Dev Notes:
# Helpful Link on Bin Paths:  http://www.cyberciti.biz/faq/how-do-i-find-the-path-to-a-command-file/
# needs to be sourced from here when we call this as a standalone

PIHOME=/home/pi
DEXTER=Dexter
DEXTER_PATH=$PIHOME/$DEXTER
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots

PIHOME=/home/pi
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots
DEXTER=Dexter
LIB=lib
LIB_PATH=$PIHOME/$DEXTER/$LIB
DEXTERLIB_PATH=$LIB_PATH/$DEXTER
RFR_TOOLS_PATH=$DEXTERLIB_PATH/RFR_Tools
TROUBLESHOOTING=Troubleshooting_GUI
TROUBLESHOOTING_PATH=$DEXTERLIB_PATH/$TROUBLESHOOTING

sudo sh -c "curl -kL dexterindustries.com/update_tools | bash"
source DEXTERLIB_PATH/script_tools/functions_library.sh
mkdir -p TROUBLESHOOTING_PATH

if ! quiet_mode
then
    sudo apt-get install python-wxgtk2.8 python-wxgtk3.0 python-wxtools wx2.8-i18n python-psutil --yes 
fi

sudo cp -r RFR_TOOLS_PATH/ $TROUBLESHOOTING_PATH
# Copy shortcut to desktop.
#sudo rm /home/pi/Desktop/Troubleshooting_Start.desktop
# by using -f we force the copy
sudo cp -f $TROUBLESHOOTING_PATH/Troubleshooting_Start.desktop /home/pi/Desktop
# Make shortcut executable
sudo chmod +x /home/pi/Desktop/Troubleshooting_Start.desktop

delete_folder /home/pi/GoBox/Troubleshooting
# Make troubleshooting_start executable.
sudo chmod +x /home/pi/Desktop/GoBox/Troubleshooting_GUI/Troubleshooting_Start.sh