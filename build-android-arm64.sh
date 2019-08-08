#!/bin/sh

# uncomment to use libexif
#export USE_LIBEXIF=1

# Set these variables to suit your needs
SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"
BUILD_DIRECTORY_SUFFIX=output/android
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"

NDK_PATH="${SOURCE_DIRECTORY}/../ndk/android-ndk-r18b"
TOOLCHAIN="${SOURCE_DIRECTORY}/../ndk/toolchains/r18b-arm64-24"
SYSROOT="${TOOLCHAIN}/sysroot"
BUILD_PLATFORM="linux-x86_64"
TOOLCHAIN_VERSION="4.9"
ANDROID_VERSION="24"

LIBJPEGDIR="${SOURCE_DIRECTORY}/../libjpeg-turbo/build/android/install"
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

# It should not be necessary to modify the rest
TARGET_HOST=aarch64-linux-android
ANDROID_CFLAGS="--target=arm64v8-none-linux-androideabi --sysroot=${SYSROOT} -D__ANDROID_API__=${ANDROID_VERSION}"

ANDROID_INCLUDES="-I${SYSROOT}/usr/include -I${TOOLCHAIN}/lib/gcc/${TARGET_HOST}/${TOOLCHAIN_VERSION}.x/include -I${TOOLCHAIN}/prebuilt_include/clang/include"

export CC=${TOOLCHAIN}/bin/${TARGET_HOST}-clang
export CXX=${TOOLCHAIN}/bin/${TARGET_HOST}-clang++
export AR=${TOOLCHAIN}/bin/${TARGET_HOST}-ar
export RANLIB=${TOOLCHAIN}/bin/${TARGET_HOST}-ranlib
export NM=${TOOLCHAIN}/bin/${TARGET_HOST}-nm

export CPP="${TOOLCHAIN}/bin/${TARGET_HOST}-clang -E"
export AS=${TOOLCHAIN}/bin/${TARGET_HOST}-clang
export LD=${TOOLCHAIN}/bin/${TARGET_HOST}-ld
export OBJDUMP=${TOOLCHAIN}/bin/${TARGET_HOST}-objdump
export STRIP=${TOOLCHAIN}/bin/${TARGET_HOST}-strip

export PATH=${PATH}:${TOOLCHAIN}/bin
export NDK=${NDK_PATH}
export ANDROID_NDK_ROOT=${NDK_PATH}
export SYSROOT=${SYSROOT}

export CFLAGS="${INCLUDE_DIRS} ${LIB_DIRS} ${ANDROID_INCLUDES} ${ANDROID_CFLAGS} -O3 -fPIC -pie"
export CXXFLAGS="${INCLUDE_DIRS} ${LIB_DIRS} ${ANDROID_INCLUDES} ${ANDROID_CFLAGS} -O3 -fPIC -pie"
export CPPFLAGS="${INCLUDE_DIRS} ${LIB_DIRS} ${ANDROID_INCLUDES} ${ANDROID_CFLAGS}"
export ASFLAGS="${INCLUDE_DIRS} ${LIB_DIRS} ${ANDROID_CFLAGS}"
export LDFLAGS="${INCLUDE_DIRS} ${LIB_DIRS} ${ANDROID_CFLAGS} -fPIC -pie"

cd ${SOURCE_DIRECTORY}
mkdir --parents ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${TARGET_HOST} \
  --prefix=${BUILD_DIRECTORY}/install \
  --disable-nls \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  LIBS=-lm \
  ${CONFIGURE_EXIF} \
  --with-simd ${1+"$@"}

make
make install-strip
