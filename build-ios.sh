#!/bin/sh

# uncomment to use libexif
#export USE_LIBEXIF=1

SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"

PATH=${SOURCE_DIRECTORY}:${PATH}

XCODE=`xcode-select -print-path`
echo XCODE=${XCODE}

IOS_PLATFORMDIR=${XCODE}/Platforms/iPhoneOS.platform
echo IOS_PLATFORMDIR=IOS_PLATFORMDIR=${OS_PLATFORMDIR}

IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneOS*.sdk)
echo IOS_SYSROOT=${IOS_SYSROOT}

DEBUG_CFLAGS=-Os

# uncomment these to enable debug symbols
#DEBUG_CFLAGS=-g

#
# ARMv8 (64-bit)
#
BUILD_DIRECTORY_SUFFIX=build/ios-armv8
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV8=${BUILD_DIRECTORY}

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib"
MERGE_LIBS=-ljpeg

if [ -n "${USE_LIBEXIF+1}" ]
then
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="${INCLUDE_DIRS} -I${LIBEXIFDIR}/include"
LIB_DIRS="${LIB_DIRS} -L${LIBEXIFDIR}/lib"
MERGE_LIBS="${MERGE_LIBS} -lexif"
else
CONFIGURE_EXIF=--without-exif
fi

export host_alias=aarch64-apple-darwin
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-isysroot ${IOS_SYSROOT[0]} -arch arm64 -miphoneos-version-min=11.0 -funwind-tables -fembed-bitcode"
export CFLAGS="${CFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS} ${DEBUG_CFLAGS}"
export LDFLAGS="${LDFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS} ${DEBUG_LDFLAGS}"

cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${host_alias} \
  --prefix=${BUILD_DIRECTORY}/install \
  --enable-static --disable-shared \
  ${CONFIGURE_EXIF} \
  $*

make install

# merge dependent libs into epeg
ld ${BUILD_DIRECTORY}/src/lib/epeg_main.o ${BUILD_DIRECTORY}/src/lib/epeg_xmp.o ${MERGE_LIBS} ${LIB_DIRS} -r -x -bitcode_bundle -exported_symbol \*epeg\* -S -o ${BUILD_DIRECTORY}/install/lib/libepeg_with_deps.a

