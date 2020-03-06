#! /bin/bash
# Copyright Dexter Industries, 2017.
# Install the Scratch GUI.
# Dev Notes:
# Helpful Link on Bin Paths:  http://www.cyberciti.biz/faq/how-do-i-find-the-path-to-a-command-file/


PIHOME=/home/pi
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots
DEXTER=Dexter
LIB=lib
LIB_PATH=$PIHOME/$DEXTER/$LIB
DEXTERLIB_PATH=$LIB_PATH/$DEXTER

#double check this name
RFR_TOOLS=$DEXTERLIB_PATH/RFR_Tools
SCRATCH=Scratch_GUI
FINAL_SCRATCH_PATH=$DEXTERLIB_PATH/$SCRATCH

# script_tools is installed within each robot's install script
# script_tools isn't installed with RFR_Tools
source $PIHOME/$DEXTER/lib/$DEXTER/script_tools/functions_library.sh

if ! quiet_mode
then
    sudo apt-get install python-wxgtk3.0 python-wxtools python-psutil --yes
fi

# ensure ~/Dexter/lib/Dexter exists
mkdir -p $DEXTERLIB_PATH
pushd $DEXTERLIB_PATH >/dev/null

feedback "Installing Scratch Environment"
cp -r $RFR_TOOLS/$SCRATCH/ $DEXTERLIB_PATH/

# if the old location exists, get rid of it
if [ -d $PIHOME/Desktop/GoBox/Scratch_GUI ] ; then
	sudo rm -r $PIHOME/Desktop/GoBox/Scratch_GUI
fi

# reinstall scratchpy
pushd $LIB_PATH > /dev/null
delete_folder scratchpy
git clone --quiet --depth=1 https://github.com/DexterInd/scratchpy
cd scratchpy
sudo make install > /dev/null
popd > /dev/null

# Copy shortcut to desktop.
feedback "Installing Scratch on the desktop"
sudo cp -f $FINAL_SCRATCH_PATH/Scratch_Start.desktop $PIHOME/Desktop
sudo cp -f $FINAL_SCRATCH_PATH/Scratch_Start.desktop /usr/share/applications/
sudo rm -f /usr/share/raspi-ui-overrides/applications/scratch.desktop
sudo rm -f /usr/share/applications/scratch.desktop
sudo lxpanelctl restart
# Make shortcut executable

# Desktop shortcut permissions.
sudo chmod +x $PIHOME/Desktop/Scratch_Start.desktop
# Remove the Scratch Start button in the Menu
# sudo rm /usr/share/applications/scratch.desktop

######
# Added these to solve the menu problem of scratch.  Then removed them.
# These are removed for now, the call up the Scratch Gui, not the scratch start.
# Desktop shortcut permissions.
# sudo rm /usr/share/raspi-ui-overrides/applications/scratch.desktop
# Remove the Scratch Start button in the Menu
# Copy the Scratch_Start to the Menu
# sudo cp /home/pi/$DEXTER/Scratch_GUI/Scratch_Start.desktop /usr/share/applications/scratch.desktop
# Copy the Scratch_Start to the Menu
# sudo cp /home/pi/$DEXTER/Scratch_GUI/Scratch_Start.desktop /usr/share/raspi-ui-overrides/applications/scratch.desktop
# Menu Shortcut Permissions.
# sudo chmod 777 /usr/share/applications/scratch.desktop
# Menu Shortcut Permissions.
# sudo chmod 777 /usr/share/raspi-ui-overrides/applications/scratch.desktop

# # Make run_scratch_gui executable.
sudo chmod +x $FINAL_SCRATCH_PATH/Scratch_Start.sh
# # Make scratch start example read only.
sudo chmod ugo+r $FINAL_SCRATCH_PATH/new.sb	# user, group, etc are just read only
# # Make select_state, error_log, nohup.out readable and writable
sudo chmod 666 $FINAL_SCRATCH_PATH/selected_state
sudo chmod 666 $FINAL_SCRATCH_PATH/error_log

#leftover from Wheezy and probably Jessie
[ -f $PIHOME/nohup.out ] && sudo chmod 666 $PIHOME/nohup.out

# Note: there was a weird issue with the softlinks being created
# where they were not supposed to be.
# ensuring that there isn't a pre-existing softlink fixes this issue

# BrickPi+ link
sudo rm  /usr/share/scratch/Projects/BrickPi 2> /dev/null
sudo rm  /usr/share/scratch/Projects/BrickPi+ 2> /dev/null
sudo ln -s /home/pi/Dexter/BrickPi+/Software/BrickPi_Scratch/Examples /usr/share/scratch/Projects/BrickPi+ 2> /dev/null

# BrickPi3 link
sudo rm /usr/share/scratch/Projects/BrickPi3 2> /dev/null
sudo ln -s /home/pi/Dexter/BrickPi3/Software/Scratch/Examples /usr/share/scratch/Projects/BrickPi3 2> /dev/null

# GoPiGo link
sudo rm  /usr/share/scratch/Projects/GoPiGo 2> /dev/null
sudo ln -s /home/pi/Dexter/GoPiGo/Software/Scratch/Examples /usr/share/scratch/Projects/GoPiGo  2> /dev/null

# GoPiGo3 link
sudo rm  /usr/share/scratch/Projects/GoPiGo3 2> /dev/null
sudo ln -s /home/pi/Dexter/GoPiGo3/Software/Scratch/Examples /usr/share/scratch/Projects/GoPiGo3  2> /dev/null

# GrovePi Link
sudo rm /usr/share/scratch/Projects/GrovePi 2> /dev/null
sudo ln -s /home/pi/Dexter/GrovePi/Software/Scratch/Grove_Examples /usr/share/scratch/Projects/GrovePi 2> /dev/null

# PivotPi Link
sudo rm  /usr/share/scratch/Projects/PivotPi 2> /dev/null
sudo ln -s /home/pi/Dexter/PivotPi/Software/Scratch/Examples /usr/share/scratch/Projects/PivotPi 2> /dev/null


# Remove Scratch Shortcuts if they're there.
[ -f $PIHOME/Desktop/BrickPi_Scratch_Start.desktop ] && sudo rm $PIHOME/Desktop/BrickPi_Scratch_Start.desktop
[ -f $PIHOME/Desktop/GoPiGo_Scratch_Start.desktop ] && sudo rm $PIHOME/Desktop/GoPiGo_Scratch_Start.desktop
# [ -f $PIHOME/Desktop/scratch.desktop ] && sudo rm $PIHOME/Desktop/scratch.desktop

VERSION=$(sed 's/\..*//' /etc/debian_version)
echo "Version: $VERSION"

# fix espeak
# 1. set audio to the audio jack
amixer cset numid=3 1
# 2. set volume to 100%
sudo amixer set PCM -- 100%
# 3. remove current espeak
sudo apt-get remove -y espeak
# 4. reinstall espeak and helpers
sudo apt install -y espeak espeak-ng python3-espeak speech-dispatcher-espeak



if [ $VERSION -eq '8' ] ; then
    # Make sure that Scratch always starts Scratch GUI
    # We'll install these parts to make sure that if a user double-clicks on a file on the desktop
    # Scratch GUI is launched, and all other programs are killed.

    #delete scratch from /usr/bin
    sudo rm /usr/bin/scratch
    # make a new scratch in /usr/bin
    sudo cp $FINAL_SCRATCH_PATH/scratch_jessie /usr/bin/scratch
    # Change scratch permissions
    sudo chmod +x /usr/bin/scratch

    # set permissions
    # sudo chmod +x $PIHOME/$DEXTER/Scratch_GUI/scratch_launch
    sudo chmod +x $FINAL_SCRATCH_PATH/scratch_direct

    # remove annoying dialog that says remote sensors are enabled
    echo "remoteconnectiondialog = 0" > /home/pi/.scratch.ini
elif [ $VERSION -eq '9' ] ; then
    # associate Scratch file to our program
    sudo apt-get install -y nuscratch
    cp -f $FINAL_SCRATCH_PATH/mimeapps.list $PIHOME/.config/
elif [ $VERSION -eq '10' ] ; then
    # Buster
    sudo apt-get install -y nuscratch
    cp -f $FINAL_SCRATCH_PATH/mimeapps.list $PIHOME/.config/
fi

popd > /dev/null
