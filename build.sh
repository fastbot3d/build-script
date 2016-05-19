#!/bin/bash
set -e
#-------------------------------------------------------------
# Top level build scripts
# truby <truby.zong@gmail.com>
#
# To see which options supported, please use:
# ./build.sh help
#------------------------------------------------------------

PRJROOT=`pwd`
KERNEL_DIR=$PRJROOT/linux-3.2.0
UBOOT_DIR=$PRJROOT/u-boot
DRV_DIR=$PRJROOT/drivers
FW_DIR=$PRJROOT/firmware

OUTPUT_DIR=$PRJROOT/output
IMAGES_DIR=$OUTPUT_DIR/images
ROOTFS_DIR=$OUTPUT_DIR/target
mkdir -p $OUTPUT_DIR $IMAGES_DIR $ROOTFS_DIR 

INSTALL_DRV_DIR="$ROOTFS_DIR"/driver/
mkdir -p $INSTALL_DRV_DIR

export ROOTFS_DIR=$OUTPUT_DIR/target
export INSTALL_DRV_DIR=$INSTALL_DRV_DIR
export KERNEL_DIR="$KERNEL_DIR"
export PATH=$PRJROOT/tools/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/:$PATH
export CROSS_COMPILE=arm-linux-gnueabihf-

TARGET=arm-linux-gnueabihf
KERNEL_DEF_CFG=am335x_evm_android_defconfig
UBOOT_DEF_CFG=am335x_evm

usage() 
{
	echo "usage: $0 [options...]"
	echo ""
	echo "Options: all           build all"
	echo "         kernel        build kernel"
	echo "         uboot         build u-boot"
	echo "         driver        build drivers"
	echo "         fw            build firmware"
	echo "         app           build octoprint"
	echo ""
	echo "         clean         clean all"
	echo "         kernel_clean  clean kernel"
	echo "         uboot_clean   clean u-boot"
	echo "         driver_clean  clean driver"
	echo "         fw_clean      clean firmware"
	echo "         app_clean     clean octoprint"
	echo ""
	echo "         help          display usage"
    exit 1
}

build_all() 
{
    echo "----------------------------------------------------------------"
    echo "-- Start to bulding kernel/u-boot/fw/drivers            ---" 
    echo "----------------------------------------------------------------"
    build_kernel
    build_uboot
    build_driver
    build_fw
    echo "-----------------------------------------------------------------"
    echo "build (kernel, u-boot, x-loader, fw, drivers) completed --"
    echo "-----------------------------------------------------------------"
}

build_all_clean() 
{
    echo "-----------------------------------------------------------------"
    echo "-- Start to cleaning kernel/u-boot/drivers                --" 
    echo "-----------------------------------------------------------------"
    build_kernel_clean
    build_uboot_clean
    build_driver_clean
    build_fw_clean
    echo "-----------------------------------------------------------------"
    echo "-- clean (kernel u-boot x-loader drivers) completed       --"
    echo "-----------------------------------------------------------------"
}

build_kernel() 
{
    echo "--------------------------------------"
    echo "-- Start to bulding kernel          --" 
    echo "--------------------------------------"
    cd $KERNEL_DIR 
    if [ ! -f ".config" ]; then
        echo ""
        echo "Use the BBP default config"
        cp arch/arm/configs/$KERNEL_DEF_CFG .config 
        echo ""
    fi
    make ARCH=arm -j8 uImage
    cp -f arch/arm/boot/uImage $IMAGES_DIR/uImage
	mkdir -p $ROOTFS_DIR/boot/
	cp $IMAGES_DIR/uImage $ROOTFS_DIR/boot/

    make ARCH=arm modules
    make ARCH=arm INSTALL_MOD_PATH=$ROOTFS_DIR modules_install
    make ARCH=arm INSTALL_FW_PATH=$ROOTFS_DIR/lib/firmware/ firmware_install 
    cd -
    echo "--------------------------------------"
    echo "-- build kernel completed!          --"
    echo "--------------------------------------"
}

build_kernel_clean() 
{
    echo "--------------------------------------"
    echo "-- Start to cleaning kernel         --" 
    echo "--------------------------------------"
    cd $KERNEL_DIR 
    make ARCH=arm clean
    cd -
    if [ -f "$IMAGES_DIR/uImage" ]; then
        rm $IMAGES_DIR/uImage
    fi
    echo "--------------------------------------"
    echo "-- clean kernel completed!          --"
    echo "--------------------------------------"
}

build_uboot() 
{
    echo "--------------------------------------"
    echo "-- Start to bulding u-boot         --" 
    echo "--------------------------------------"
    cd $UBOOT_DIR
    make O=am335x $UBOOT_DEF_CFG  -j10

	cp -f $UBOOT_DIR/am335x/MLO $IMAGES_DIR/MLO
	cp -f $UBOOT_DIR/am335x/u-boot.img $IMAGES_DIR/u-boot.img
	mkdir -p $ROOTFS_DIR/opt/backup/uboot/
	cp $IMAGES_DIR/MLO        $ROOTFS_DIR/opt/backup/uboot/
	cp $IMAGES_DIR/u-boot.img $ROOTFS_DIR/opt/backup/uboot/
	cd -

    echo "--------------------------------------"
    echo "-- build u-boot completed!          --"
    echo "--------------------------------------"
}

build_uboot_clean() 
{
    echo "--------------------------------------"
    echo "-- Start to cleaning u-boot         --" 
    echo "--------------------------------------"
    cd $UBOOT_DIR
    make distclean
    cd -
    if [ -f "$IMAGES_DIR/u-boot.img" ]; then
        rm $IMAGES_DIR/u-boot.img
    fi
    if [ -f "$IMAGES_DIR/MLO" ]; then
        rm $IMAGES_DIR/MLO
    fi
    echo "--------------------------------------"
    echo "-- clean u-boot completed!          --"
    echo "--------------------------------------"
}

build_driver()
{
    echo "--------------------------------------"
    echo "-- Start to building drivers        --" 
    echo "--------------------------------------"

    cd $DRV_DIR/lmsw;      make;make install 
    cd $DRV_DIR/pwm;       make;make install 
    cd $DRV_DIR/pwr_button;make;make install 
    cd $DRV_DIR/regulator; make;make install 
    cd $DRV_DIR/temp; 	   make;make install 
    #cd $DRV_DIR/gpu; 	   make;make install 
    cd $DRV_DIR/stepper;   make;make install 
    cd $DRV_DIR/wifi/rtl8188C_8192C_usb_linux_v4.0.2_9000.20130911-android/  
		a=$(cat $KERNEL_DIR/include/generated/utsrelease.h | cut -d" " -f 3)
		KERNEL_VER=${a//\"/}
		make  ARCH=arm KSRC=$KERNEL_DIR CROSS_COMPILE=$CROSS_COMPILE modules 
    	make ARCH=arm KVER=$KERNEL_VER  install 
    cd $DRV_DIR/wifi/rtl8188C_8192C_v4.0.2_9000/  
		a=$(cat $KERNEL_DIR/include/generated/utsrelease.h | cut -d" " -f 3)
		KERNEL_VER=${a//\"/}
		make  ARCH=arm KSRC=$KERNEL_DIR CROSS_COMPILE=$CROSS_COMPILE modules 
    	make ARCH=arm KVER=$KERNEL_VER  install 
    echo "--------------------------------------"
    echo "-- building drivers completed!      --"
    echo "--------------------------------------"
}

build_driver_clean()
{
    echo "--------------------------------------"
    echo "-- Start to cleaning drivers        --" 
    echo "--------------------------------------"
	rm -rf "$INSTALL_DRV_DIR/"
    cd $DRV_DIR/lmsw;      make clean;make uninstall
    cd $DRV_DIR/pwm;       make clean;make uninstall
    cd $DRV_DIR/pwr_button;make clean;make uninstall
    cd $DRV_DIR/regulator; make clean;make uninstall
    cd $DRV_DIR/stepper;   make clean;make uninstall
    cd $DRV_DIR/wifi/rtl8188C_8192C_v4.0.2_9000/;  make uninstall
    echo "--------------------------------------"
    echo "-- cleaning drivers completed!      --"
    echo "--------------------------------------"
}

build_fw()
{
    echo "--------------------------------------"
    echo "-- Start to bulding firmware        --" 
    echo "--------------------------------------"
	cd $FW_DIR/pru_sw;  make
    cd $FW_DIR/unicorn;make clean;make

    if [ ! -d "$ROOTFS_DIR/usr/bin" ]; then
        mkdir -p $ROOTFS_DIR/usr/bin
    fi
    cp -f $FW_DIR/unicorn/build/target/bin/unicorn $ROOTFS_DIR/usr/bin/

    echo "--------------------------------------"
    echo "-- build firmware completed!        --"
    echo "--------------------------------------"
}

build_fw_clean()
{
    echo "--------------------------------------"
    echo "-- Start to cleaning firmware       --" 
    echo "--------------------------------------"
    cd $FW_DIR/pru_sw; make clean
    cd $FW_DIR/unicorn;make clean

    rm -f $FW_DIR/unicorn/build/target/bin/unicorn
    rm $ROOTFS_DIR/usr/bin/unicorn
    echo "--------------------------------------"
    echo "-- clean firmware completed!        --"
    echo "--------------------------------------"
}

build_init()
{
    echo "--------------------------------------"
    echo "-- Start to init development env    --" 
    echo "--------------------------------------"

	if [ ! -e $PRJROOT/u-boot ] ; then
		git clone https://github.com/fastbot3d/u-boot.git
	fi
	if [ ! -e $PRJROOT/drivers ] ; then
		git clone https://github.com/fastbot3d/drivers.git
    fi
	if [ ! -e $PRJROOT/linux-3.2.0 ] ; then
		git clone https://github.com/fastbot3d/linux-3.2.0.git
	fi
	if [ ! -e $PRJROOT/firmware ] ; then
		git clone https://github.com/fastbot3d/firmware.git
	fi

    echo "--------------------------------------"
    echo "-- build development env completed! --"
    echo "--------------------------------------"
}


if [ "$1" ]; then
    case "$1" in
        all)
            build_all;
        ;;
        clean)
            build_all_clean;
        ;;
        kernel)
            build_kernel;
        ;;
        kernel_clean)
            build_kernel_clean;
        ;;
        uboot)
            build_uboot;
        ;;
        uboot_clean)
            build_uboot_clean;
        ;;
        driver)
            build_driver;
        ;;
        driver_clean)
            build_driver_clean;
        ;;
        fw)
            build_fw;
        ;;
        fw_clean)
            build_fw_clean;
       ;;
        init)
            build_init;
       ;;
        help)
            usage;
        ;;
        *) 
            usage;
        ;;
    esac
else
    build_all
fi

