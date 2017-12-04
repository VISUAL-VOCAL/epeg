#!/bin/sh

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

#
# ARMv7 (32-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv7
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV7=${BUILD_DIRECTORY}

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include -I${LIBEXIFDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib -L${LIBEXIFDIR}/lib"

export host_alias=arm-apple-darwin10
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-mfloat-abi=softfp -isysroot ${IOS_SYSROOT[0]} -O3 -arch armv7 -miphoneos-version-min=8.0"
export CFLAGS="${CFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"
export LDFLAGS="${LDFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"

cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${host_alias} \
  --prefix=${BUILD_DIRECTORY}/install \
  --enable-static --disable-shared \
  $*

make
make install-strip

#
# ARMv7s (32-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv7s
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV7S=${BUILD_DIRECTORY}

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include -I${LIBEXIFDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib -L${LIBEXIFDIR}/lib"

export host_alias=arm-apple-darwin10
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-mfloat-abi=softfp -isysroot ${IOS_SYSROOT[0]} -O3 -arch armv7s -miphoneos-version-min=8.0"
export CFLAGS="${CFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"
export LDFLAGS="${LDFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"

cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${host_alias} \
  --prefix=${BUILD_DIRECTORY}/install \
  --enable-static --disable-shared \
  $*

make
make install-strip

#
# ARMv8 (64-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv8
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV8=${BUILD_DIRECTORY}

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include -I${LIBEXIFDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib -L${LIBEXIFDIR}/lib"

export host_alias=aarch64-apple-darwin
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-isysroot ${IOS_SYSROOT[0]} -O3 -arch arm64 -miphoneos-version-min=8.0 -funwind-tables"
export CFLAGS="${CFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"
export LDFLAGS="${LDFLAGS} ${INCLUDE_DIRS} ${LIB_DIRS}"

cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${host_alias} \
  --prefix=${BUILD_DIRECTORY}/install \
  --enable-static --disable-shared \
  $*

make
make install-strip

#
# Unified multi-architecture library
#
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/output/ios-all"
LIBNAME=libepeg.a
cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
lipo -create -output ${BUILD_DIRECTORY}/${LIBNAME} \
  -arch armv7 ${BUILD_DIRECTORY_ARMV7}/install/lib/${LIBNAME} \
  -arch armv7s ${BUILD_DIRECTORY_ARMV7S}/install/lib/${LIBNAME} \
  -arch arm64v8 ${BUILD_DIRECTORY_ARMV8}/install/lib/${LIBNAME}

