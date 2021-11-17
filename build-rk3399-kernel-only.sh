#!/bin/bash

usage()
{
 echo "USAGE: [-o] [-u] [-v VERSION_NAME]"
 echo "No ARGS means use default build option"
 echo "WHERE: -o = generate ota package       "
 echo "       -u = generate update.img        "
 echo "       -v = set build version name for output image folder"
 exit 1
}

BUILD_UPDATE_IMG=false
BUILD_OTA=false
BUILD_VERSION="IMAGES"

# check pass argument
while getopts "ouv:" arg
do
  case $arg in
    o)
      echo "will build ota package"
      BUILD_OTA=true
      ;;
    u)
      echo "will build update.img"
      BUILD_UPDATE_IMG=true
      ;;
    v)
      BUILD_VERSION=$OPTARG
	  ;;
    ?)
      usage ;;
  esac
done

source build/envsetup.sh >/dev/null && setpaths
TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`

#set jdk version
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
# source environment and chose target product
DEVICE=`get_build_var TARGET_PRODUCT`
BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
UBOOT_DEFCONFIG=rk3399_defconfig
KERNEL_DEFCONFIG=rockchip_defconfig
KERNEL_DTS=rk3399-rockpro64-TFC-J9500MTWX50TC-01A
PACK_TOOL_DIR=RKTools/linux/Linux_Pack_Firmware
IMAGE_PATH=rockdev/Image-$TARGET_PRODUCT
export PROJECT_TOP=`gettop`

#lunch $DEVICE-$BUILD_VARIANT

PLATFORM_VERSION=`get_build_var PLATFORM_VERSION`
DATE=$(date  +%Y%m%d.%H%M)
STUB_PATH=Image/"$KERNEL_DTS"_"$PLATFORM_VERSION"_"$DATE"_"$BUILD_VERSION"
STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"
export STUB_PATH=$PROJECT_TOP/$STUB_PATH
export STUB_PATCH_PATH=$STUB_PATH/PATCHES
#echo $STUB_PATH

# build uboot
#echo "start build uboot"
#cd u-boot && make clean && make $UBOOT_DEFCONFIG && make ARCHV=aarch64 -j12 && cd -
#if [ $? -eq 0 ]; then
#    echo "Build uboot ok!"
#else
#    echo "Build uboot failed!"
#    exit 1
#fi


# build kernel
echo "Start build kernel"
# cd kernel && make clean  && make ARCH=arm64 $KERNEL_DEFCONFIG && make ARCH=arm64 $KERNEL_DTS.img -j12 && cd -
cd kernel && make ARCH=arm64 $KERNEL_DEFCONFIG && make ARCH=arm64 $KERNEL_DTS.img -j12 && cd -
if [ $? -eq 0 ]; then
    echo "Build kernel ok!"
else
    echo "Build kernel failed!"
    exit 1
fi
