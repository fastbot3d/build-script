# build-script
Build env for fastbot BBP 
-------------------------

1. make directory <br> 
```
  mkdir ~/fastbot
  mkdir ~/fastbot/tools/ 
```

2.ready for tool.
2.1 download gcc compile tool and extract file to put them into tools directory. <br>
download address is https://onedrive.live.com/redir?resid=F126DF2F21ED21A1!124&authkey=!ABtPtGiUpozdNys&ithint=file%2cxz  <br>

2.2 download android-ndk-r10e  and extract file to put them into tools directory. <br>
download address is http://dl.google.com/android/repository/android-ndk-r10e-linux-x86.zip if your computer are is 32 bit.  <br>
download address is http://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip if your computer are is 64 bit.  <br>

The final tools directory struct like this  <br>
```
ls tools/  
gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux 
android-ndk-r10e
```

3.git clone https://github.com/fastbot3d/build-script.git <br>
```
cp ./build-script/build.sh .  
chmod u+x build.sh 
./build.sh init 
```

Compile step 
------------------
```
./build.sh uboot
./build.sh kernel
./build.sh driver
./build.sh fw
```

