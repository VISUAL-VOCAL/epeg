#!/bin/sh

SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"

BUILD_DIRECTORY_SUFFIX=output/osx
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include -I${LIBEXIFDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib -L${LIBEXIFDIR}/lib"

TARGET_HOST="x86_64-apple-darwin"

export CFLAGS="${INCLUDE_DIRS} ${LIB_DIRS}"
export CXXFLAGS="${INCLUDE_DIRS} ${LIB_DIRS}"
export CPPFLAGS="${INCLUDE_DIRS} ${LIB_DIRS}"
export ASFLAGS="${INCLUDE_DIRS} ${LIB_DIRS}"
export LDFLAGS="${INCLUDE_DIRS} ${LIB_DIRS}"

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
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
${SOURCE_DIRECTORY}/configure \
  --host=${TARGET_HOST} \
  --prefix=${BUILD_DIRECTORY}/install \
  $*

make
make install-strip
