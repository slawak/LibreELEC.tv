# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking@gmail.com)

PKG_NAME="lr-reicast"
PKG_VERSION="0271184656936712ce3fdd412ca4a5f807f208b7"
PKG_SHA256="08cfdc3c6d825e39e72eae35de73ea933f8c1420997fd4ffa4d719f45fd1b56a"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/reicast-emulator"
PKG_URL="https://github.com/libretro/reicast-emulator/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux glibc"
PKG_LONGDESC="Reicast is a multiplatform Sega Dreamcast emulator"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

PKG_LIBNAME="reicast_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"

PKG_MAKE_OPTS_TARGET="HAVE_OPENMP=0 GIT_VERSION=${PKG_VERSION:0:7} WITH_DYNAREC=${ARCH}"

configure_package() {
  # Apply project specific patches
  PKG_PATCH_DIRS="${PROJECT}"

  # Displayserver Support
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" xorg-server"
  fi

  # OpenGL Support
  if [ "${OPENGL_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
  fi

  # OpenGLES Support
  if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi
}

pre_configure_target() {
  export BUILD_SYSROOT=${SYSROOT_PREFIX}

  if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1"
  fi

  case ${PROJECT} in
    Amlogic_Legacy)
      PKG_MAKE_OPTS_TARGET+=" platform=rpi"
      ;;
    Generic)
      PKG_MAKE_OPTS_TARGET+=" AS=${AS} CC_AS=${AS} HAVE_OIT=1"
      ;;
    RPi)
      if [ "${DEVICE}" = "RPi2" ]; then
        PKG_MAKE_OPTS_TARGET+=" platform=rpi2"
      else
        PKG_MAKE_OPTS_TARGET+=" platform=rpi"
      fi
      ;;
   Rockchip)
      if [ "${DEVICE}" = "RK3399" ]; then
        PKG_MAKE_OPTS_TARGET+=" platform=rockpro64"
      fi
      ;;
    *)
      PKG_MAKE_OPTS_TARGET+=" AS=${AS} CC_AS=${AS}"
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_LIBPATH} ${INSTALL}/usr/lib/libretro/
}
