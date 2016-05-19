# build-script
Build env for fastbot BBP 

1.mkdir ~/fastbot
  mkdir ~/fastbot/tools/

2.download gcc compile tool and extract file to put them into tools directory.
download address is https://onedrive.live.com/redir?resid=F126DF2F21ED21A1!124&authkey=!ABtPtGiUpozdNys&ithint=file%2cxz
The final tools directory struct like this
ls tools/
gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux

3.git clone https://github.com/fastbot3d/build-script.git
cp ./build-script/build.sh . 
chmod u+x build.sh
./build.sh init

4.Ok, it's ready. compile right step 
./build.sh uboot
./build.sh kernel
./build.sh driver
./build.sh fw


