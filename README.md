# build-script
Build env for fastbot BBP 
-------------------------

1.mkdir ~/fastbot <br> 
  mkdir ~/fastbot/tools/ <br>

2.download gcc compile tool and extract file to put them into tools directory. <br>
download address is https://onedrive.live.com/redir?resid=F126DF2F21ED21A1!124&authkey=!ABtPtGiUpozdNys&ithint=file%2cxz  <br>
The final tools directory struct like this  <br>
ls tools/  <br>
gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux  <br>

3.git clone https://github.com/fastbot3d/build-script.git <br>
cp ./build-script/build.sh .  <br>
chmod u+x build.sh <br>
./build.sh init <br>

Compile step 
------------------
./build.sh uboot <br>
./build.sh kernel <br>
./build.sh driver <br>
./build.sh fw <br>


