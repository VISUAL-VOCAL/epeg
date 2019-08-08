#!/bin/sh

# uncomment to use libexif
#export USE_LIBEXIF=1

# Set these variables to suit your needs
SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"

NDK="${SOURCE_DIRECTORY}/../ndk/android-ndk-r20"
HOST_TAG="linux-x86_64"
TOOLCHAIN_VERSION="4.9"
ANDROID_VERSION="28"

TOOLCHAIN="${NDK}/toolchains/llvm/prebuilt/${HOST_TAG}"
SYSROOT="${TOOLCHAIN}/sysroot"

#
# armeabi-v7a (32-bit)
#
BUILD_DIRECTORY_SUFFIX="build/android/armeabi-v7a"
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

TARGET_HOST="arm-linux-androideabi"
TARGET_HOST_CLANG="armv7a-linux-androideabi${ANDROID_VERSION}"
ANDROID_CFLAGS="-v -march=armv7-a -mfloat-abi=softfp -fprefetch-loop-arrays --sysroot=${SYSROOT} -D__ANDROID_API__=${ANDROID_VERSION}"

ANDROID_INCLUDES="-I${SYSROOT}/usr/include"
ANDROID_INCLUDES="${ANDROID_INCLUDES} -I${TOOLCHAIN}/lib/gcc/${TARGET_HOST}/${TOOLCHAIN_VERSION}.x/include"

export AR=${TOOLCHAIN}/bin/${TARGET_HOST}-ar
export AS=${TOOLCHAIN}/bin/${TARGET_HOST}-as
export CC=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG}-clang
export CXX=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG}-clang++
export LD=${TOOLCHAIN}/bin/${TARGET_HOST}-ld
export NM=${TOOLCHAIN}/bin/${TARGET_HOST}-nm
export OBJDUMP=${TOOLCHAIN}/bin/${TARGET_HOST}-objdump
export RANLIB=${TOOLCHAIN}/bin/${TARGET_HOST}-ranlib
export STRIP=${TOOLCHAIN}/bin/${TARGET_HOST}-strip

export PATH=${PATH}:${TOOLCHAIN}/bin
export NDK=${NDK}
export ANDROID_NDK_ROOT=${NDK}
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

#
# arm64-v8a (64-bit)
#
BUILD_DIRECTORY_SUFFIX="build/android/arm64-v8a"
BUILD_DIRECTORY="${SOURCE_DIRECTORY}/${BUILD_DIRECTORY_SUFFIX}"

TOOLCHAIN="${NDK}/toolchains/llvm/prebuilt/${HOST_TAG}"
SYSROOT="${TOOLCHAIN}/sysroot"

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

TARGET_HOST="aarch64-linux-android"
TARGET_HOST_CLANG="${TARGET_HOST}${ANDROID_VERSION}"
ANDROID_CFLAGS="-v --sysroot=${SYSROOT} -D__ANDROID_API__=${ANDROID_VERSION}"

ANDROID_INCLUDES="-I${SYSROOT}/usr/include"
ANDROID_INCLUDES="${ANDROID_INCLUDES} -I${TOOLCHAIN}/lib/gcc/${TARGET_HOST}/${TOOLCHAIN_VERSION}.x/include"

export AR=${TOOLCHAIN}/bin/${TARGET_HOST}-ar
export AS=${TOOLCHAIN}/bin/${TARGET_HOST}-as
export CC=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG}-clang
export CXX=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG}-clang++
export LD=${TOOLCHAIN}/bin/${TARGET_HOST}-ld
export NM=${TOOLCHAIN}/bin/${TARGET_HOST}-nm
export OBJDUMP=${TOOLCHAIN}/bin/${TARGET_HOST}-objdump
export RANLIB=${TOOLCHAIN}/bin/${TARGET_HOST}-ranlib
export STRIP=${TOOLCHAIN}/bin/${TARGET_HOST}-strip

export PATH=${PATH}:${TOOLCHAIN}/bin
export NDK=${NDK}
export ANDROID_NDK_ROOT=${NDK}
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


