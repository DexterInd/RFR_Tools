PIHOME=/home/pi
DEXTER=Dexter
DEXTER_PATH=$PIHOME/$DEXTER
LIB_PATH=$DEXTER_PATH/lib
DEXTERLIB_PATH=$LIB_PATH/$DEXTER
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots
RFR_TOOLS_PATH=$DEXTERLIB_PATH/RFR_Tools
ADV_COMMS=advanced_communications_options
ADV_COMMS_PATH=$DEXTERLIB_PATH/$ADV_COMMS

cp -r $ADV_COMMS_PATH/ $DEXTERLIB_PATH/
cp -f $ADV_COMMS_PATH/advanced_communications_options.desktop $PIHOME/desktop
sudo chmod +x /home/pi/Desktop/advanced_communications_options.desktop


