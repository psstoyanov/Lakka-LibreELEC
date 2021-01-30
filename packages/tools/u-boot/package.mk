# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="u-boot"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_DEPENDS_TARGET="toolchain swig:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."

PKG_IS_KERNEL_PKG="yes"
PKG_STAMP="$UBOOT_SYSTEM $UBOOT_TARGET"

if [ -n "$UBOOT_FIRMWARE" ]; then
  PKG_DEPENDS_TARGET+=" $UBOOT_FIRMWARE"
  PKG_DEPENDS_UNPACK+=" $UBOOT_FIRMWARE"
fi

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"
[ -n "$DEVICE" ] && PKG_NEED_UNPACK+=" $PROJECT_DIR/$PROJECT/devices/$DEVICE/bootloader"

case "$PROJECT" in
  Allwinner)
    case "$DEVICE" in 
      PinePhone)
        PKG_VERSION="7206996ef7f89375dd74b275ced62d85f8bc7f42"
        PKG_SHA256="33cbab12e4b69f5bb4c0d88d83f3231289c8798096f91447009ad117544a717e"
        PKG_URL="https://gitlab.com/pine64-org/u-boot/-/archive/$PKG_VERSION/u-boot-$PKG_VERSION.tar.gz"
        ;;
      *)
    esac
    ;;
  Rockchip)
    case "$DEVICE" in
      OdroidGoAdvance)
        PKG_VERSION="8273f6996fd8c275ee6ede942b48bbc4c1142cd3"
        PKG_SHA256="4547d7e98643193ff4cb5fe87f20554a6f413c5eabbe12859fdbc8df1f258500"
        PKG_URL="https://github.com/hardkernel/u-boot/archive/$PKG_VERSION.tar.gz"
        ;;
      *)
        PKG_VERSION="8659d08d2b589693d121c1298484e861b7dafc4f"
        PKG_SHA256="3f9f2bbd0c28be6d7d6eb909823fee5728da023aca0ce37aef3c8f67d1179ec1"
        PKG_URL="https://github.com/rockchip-linux/u-boot/archive/$PKG_VERSION.tar.gz"
        PKG_PATCH_DIRS="rockchip"
        ;;
    esac
    ;;
  *)
    PKG_VERSION="2019.04"
    PKG_SHA256="76b7772d156b3ddd7644c8a1736081e55b78828537ff714065d21dbade229bef"
    PKG_URL="http://ftp.denx.de/pub/u-boot/u-boot-$PKG_VERSION.tar.bz2"
    ;;
esac

post_patch() {
  if [ -n "$UBOOT_SYSTEM" ] && find_file_path bootloader/config; then
    PKG_CONFIG_FILE="$PKG_BUILD/configs/$($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config)"
    if [ -f "$PKG_CONFIG_FILE" ]; then
      cat $FOUND_PATH >> "$PKG_CONFIG_FILE"
    fi
  fi
  #host gcc 10 build issue
  if [ -f $PKG_BUILD/scripts/dtc/dtc-lexer.l ]; then
    sed -i '/YYLTYPE yylloc/d' $PKG_BUILD/scripts/dtc/dtc-lexer.l
  fi
  #Rockchip u-boot fix
  if [ -f $PKG_BUILD/scripts/dtc/dtc-lexer.lex.c_shipped ]; then
    sed -i '/YYLTYPE yylloc/d' $PKG_BUILD/scripts/dtc/dtc-lexer.lex.c_shipped
  fi
}

make_target() {
  if [ -z "$UBOOT_SYSTEM" ]; then
    echo "UBOOT_SYSTEM must be set to build an image"
    echo "see './scripts/uboot_helper' for more information"
  else
    [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
    [ -n "$UBOOT_FIRMWARE" ] && find_file_path bootloader/firmware && . ${FOUND_PATH}
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm make mrproper
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm make $($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config)
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm _python_sysroot="$TOOLCHAIN" _python_prefix=/ _python_exec_prefix=/ make $UBOOT_TARGET HOSTCC="$HOST_CC" HOSTLDFLAGS="-L$TOOLCHAIN/lib" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

    # Only install u-boot.img et al when building a board specific image
    if [ -n "$UBOOT_SYSTEM" ]; then
      find_file_path bootloader/install && . ${FOUND_PATH}
    fi

    # Always install the update script
    find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader

    # Always install the canupdate script
    if find_file_path bootloader/canupdate.sh; then
      cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
      sed -e "s/@PROJECT@/${DEVICE:-$PROJECT}/g" \
          -i $INSTALL/usr/share/bootloader/canupdate.sh
    fi
}
