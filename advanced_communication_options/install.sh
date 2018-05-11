PIHOME=/home/pi
DEXTER=Dexter
DEXTER_PATH=$PIHOME/$DEXTER
LIB_PATH=$DEXTER_PATH/lib
DEXTERLIB_PATH=$LIB_PATH/$DEXTER
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots
RFR_TOOLS_PATH=$DEXTERLIB_PATH/RFR_Tools
ADV_COMMS=advanced_communication_options
ADV_COMMS_PATH=$RFR_TOOLS_PATH/$ADV_COMMS

echo $ADV_COMMS_PATH  
pushd $ADV_COMMS_PATH
echo $DEXTERLIB_PATH
cp -r $ADV_COMMS_PATH/ $DEXTERLIB_PATH/
sudo cp -f $ADV_COMMS_PATH/advanced_comms_options.desktop $PIHOME/Desktop
sudo chmod +x /home/pi/Desktop/advanced_comms_options.desktop

popd

