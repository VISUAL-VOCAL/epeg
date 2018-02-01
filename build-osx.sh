#!/bin/sh

# uncomment to use libexif
#export USE_LIBEXIF=1

SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"

BUILD_DIRECTORY_SUFFIX=output/osx
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="-I${LIBJPEGDIR}/include"
LIB_DIRS="-L${LIBJPEGDIR}/lib"

if [ -n "${USE_LIBEXIF+1}" ]
then
LIBEXIFDIR="${SOURCE_DIRECTORY}/../libexif/${BUILD_DIRECTORY_SUFFIX}/install"
INCLUDE_DIRS="${INCLUDE_DIRS} -I${LIBEXIFDIR}/include"
LIB_DIRS="${LIB_DIRS} -L${LIBEXIFDIR}/lib"
else
CONFIGURE_EXIF=--without-exif
fi

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
  ${CONFIGURE_EXIF} \
  $*

make
make install-strip
