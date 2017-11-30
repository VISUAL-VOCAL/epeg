#!/bin/sh

SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"

BUILD_DIR_SUFFIX=output/win64
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIR_SUFFIX}"

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIR_SUFFIX}/.libs"
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIR_SUFFIX}/libexif/.libs"

TARGET_HOST="x86_64-pc-mingw32"

export CC="x86_64-w64-mingw32-gcc"
export CXX="x86_64-w64-mingw32-g++"
export AR="x86_64-w64-mingw32-ar"
export RANLIB="x86_64-w64-mingw32-ranlib"
export NM="x86_64-w64-mingw32-nm"
export LDFLAGS="-L/usr/local/lib ${LDFLAGS}"
export CPPFLAGS="-I/opt/libjpeg-turbo/include -I/usr/local/include/libexif -DBUILDING_DLL ${CPPFLAGS}"
export CFLAGS="-I/opt/libjpeg-turbo/include -I/usr/local/include/libexif -DBUILDING_DLL ${CFLAGS}"

echo "$F: calling ./configure with env vars:"
echo " CC = ${CC}"
echo " CFLAGS = ${CFLAGS}"
echo " LDFLAGS = ${LDFLAGS}"
echo " CPPFLAGS = ${CPPFLAGS}"
echo " LIBS = ${LIBS}"
echo " AR = ${AR}"
echo " RANLIB = ${RANLIB}"
echo " TARGET_HOST = ${TARGET_HOST}"

cd ${SOURCE_DIRECTORY}
mkdir --parents ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
${SOURCE_DIRECTORY}/configure --host=${TARGET_HOST} $*
make
make install-strip
