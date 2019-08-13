#!/bin/sh

# uncomment to use libexif
#export USE_LIBEXIF=1

if [ -z ${ANDROID_HOME+x} ]; then
  echo "Build aborted: ANDROID_HOME not set. You should export it set to the location where your Android NDKs are installed. \n   ... e.g. export ANDROID_HOME=\"\$HOME/Library/Android\""
  exit 1
fi

HOST_OS=$(uname -s)

case $HOST_OS in
  Linux)
    HOST_TAG="linux-x86_64" 
    ;;
  Darwin)
    HOST_TAG="darwin-x86_64"
    ;;
  *)
    echo "Build aborted: OS '$HOST_OS' is not supported"
    exit 1
    ;;
esac


# Set these variables to suit your needs
SOURCE_DIRECTORY="$(dirname $0)"
cd ${SOURCE_DIRECTORY}
PWD=`pwd`
SOURCE_DIRECTORY="${PWD}"


NDK_PATH="${ANDROID_HOME}/android-ndk-r20"
TOOLCHAIN="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_TAG}"
SYSROOT="${TOOLCHAIN}/sysroot"
BUILD_PLATFORM="${HOST_TAG}"
TOOLCHAIN_VERSION="4.9"

if [ ! -d "$NDK_PATH" ]; then
  echo "Build aborted: Could not find Android NDK installed at: $NDK_PATH"
  echo "Did you install the correct NDK? Is your ANDROID_HOME set correctly?"
  exit 1
fi


#
# armeabi-v7a (32-bit)
#
echo ""
echo "Building armeabi-v7a ..."
echo ""

# Current minimum required version for Vv app is 19 aka KitKat:
ANDROID_VERSION="19"
TARGET_HOST=arm-linux-androideabi
TARGET_HOST_CLANG_PREFIX=armv7a-linux-androideabi
ANDROID_CFLAGS="-mfloat-abi=softfp -mfpu=neon"
# ANDROID_CFLAGS="-march=armv7-a -mfloat-abi=softfp -fprefetch-loop-arrays --sysroot=${SYSROOT} -D__ANDROID_API__=${ANDROID_VERSION}"
# ANDROID_INCLUDES="-I${SYSROOT}/usr/include -I${TOOLCHAIN}/lib/gcc/${TARGET_HOST}/${TOOLCHAIN_VERSION}.x/include -I${TOOLCHAIN}/prebuilt_include/clang/include"

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


export CC=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG_PREFIX}${ANDROID_VERSION}-clang
export CXX=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG_PREFIX}${ANDROID_VERSION}-clang++
export AR=${TOOLCHAIN}/bin/${TARGET_HOST}-ar
export RANLIB=${TOOLCHAIN}/bin/${TARGET_HOST}-ranlib
export NM=${TOOLCHAIN}/bin/${TARGET_HOST}-nm

export AS=${TOOLCHAIN}/bin/${TARGET_HOST_CLANG_PREFIX}${ANDROID_VERSION}-clang
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
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${TARGET_HOST} \
  --prefix=${BUILD_DIRECTORY}/install \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  LIBS=-lm \
  ${CONFIGURE_EXIF} ${1+"$@"}

make install-strip

echo ""
echo "Build completed for armeabi-v7a!"

#
# arm64-v8a (64-bit)
#
echo ""
echo "Building arm64-v8a ..."
echo ""

# Minimum required Android version than can run on 64bit hardware is 21 aka Lollipop --  older hardware will never see this binary.
ANDROID_VERSION="21"

TARGET_HOST=aarch64-linux-android

ANDROID_CFLAGS="-mfpu=neon"

BUILD_DIRECTORY_SUFFIX="build/android/arm64-v8a"
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

export CC=${TOOLCHAIN}/bin/${TARGET_HOST}${ANDROID_VERSION}-clang
export CXX=${TOOLCHAIN}/bin/${TARGET_HOST}${ANDROID_VERSION}-clang++
export AR=${TOOLCHAIN}/bin/${TARGET_HOST}-ar
export RANLIB=${TOOLCHAIN}/bin/${TARGET_HOST}-ranlib
export NM=${TOOLCHAIN}/bin/${TARGET_HOST}-nm

export AS=${TOOLCHAIN}/bin/${TARGET_HOST}${ANDROID_VERSION}-clang
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
mkdir -p ${BUILD_DIRECTORY}
export NOCONFIGURE=1
${SOURCE_DIRECTORY}/autogen.sh
cd ${BUILD_DIRECTORY}
sh ${SOURCE_DIRECTORY}/configure \
  --host=${TARGET_HOST} \
  --prefix=${BUILD_DIRECTORY}/install \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  LIBS=-lm \
  ${CONFIGURE_EXIF} ${1+"$@"}

make install-strip

echo ""
echo "Build completed for arm64-v8a!"
