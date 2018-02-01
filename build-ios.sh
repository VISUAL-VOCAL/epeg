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

DEBUG_CFLAGS=-O3
INSTALL_TARGET=install-strip

# uncomment these to enable debug symbols
#DEBUG_CFLAGS=-g
#INSTALL_TARGET=install

#
# ARMv7 (32-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv7
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV7=${BUILD_DIRECTORY}

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

export host_alias=arm-apple-darwin10
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-mfloat-abi=softfp -isysroot ${IOS_SYSROOT[0]} -arch armv7 -miphoneos-version-min=8.0 ${DEBUG_CFLAGS}"
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

make
make ${INSTALL_TARGET}
# merge dependent libs into epeg
ld ${BUILD_DIRECTORY}/src/lib/epeg_main.o ${BUILD_DIRECTORY}/src/lib/epeg_xmp.o ${MERGE_LIBS} ${LIB_DIRS} -r -x -exported_symbol \*epeg\* -S -o ${BUILD_DIRECTORY}/install/lib/libepeg_with_deps.a

#
# ARMv7s (32-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv7s
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"
BUILD_DIRECTORY_ARMV7S=${BUILD_DIRECTORY}

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

export host_alias=arm-apple-darwin10
export CC=${XCODE}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
export CFLAGS="-mfloat-abi=softfp -isysroot ${IOS_SYSROOT[0]} -arch armv7s -miphoneos-version-min=8.0"
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

make
make ${INSTALL_TARGET}
# merge dependent libs into epeg
ld ${BUILD_DIRECTORY}/src/lib/epeg_main.o ${BUILD_DIRECTORY}/src/lib/epeg_xmp.o ${MERGE_LIBS} ${LIB_DIRS} -r -x -exported_symbol \*epeg\* -S -o ${BUILD_DIRECTORY}/install/lib/libepeg_with_deps.a

#
# ARMv8 (64-bit)
#
BUILD_DIRECTORY_SUFFIX=output/ios-armv8
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
export CFLAGS="-isysroot ${IOS_SYSROOT[0]} -arch arm64 -miphoneos-version-min=8.0 -funwind-tables"
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

make
make ${INSTALL_TARGET}
# merge dependent libs into epeg
ld ${BUILD_DIRECTORY}/src/lib/epeg_main.o ${BUILD_DIRECTORY}/src/lib/epeg_xmp.o ${MERGE_LIBS} ${LIB_DIRS} -r -x -exported_symbol \*epeg\* -S -o ${BUILD_DIRECTORY}/install/lib/libepeg_with_deps.a

#
# Unified multi-architecture library
#
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/output/ios-all"
LIBNAME=libepeg.a
INPUT_LIBNAME=libepeg_with_deps.a
cd ${SOURCE_DIRECTORY}
mkdir -p ${BUILD_DIRECTORY}
lipo -create -output ${BUILD_DIRECTORY}/${LIBNAME} \
  -arch armv7 ${BUILD_DIRECTORY_ARMV7}/install/lib/${INPUT_LIBNAME} \
  -arch armv7s ${BUILD_DIRECTORY_ARMV7S}/install/lib/${INPUT_LIBNAME} \
  -arch arm64v8 ${BUILD_DIRECTORY_ARMV8}/install/lib/${INPUT_LIBNAME}

