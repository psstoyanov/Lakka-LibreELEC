# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC

PKG_NAME="atf"
PKG_VERSION="e2c509a39c6cc4dda8734e6509cdbe6e3603cdfc"
PKG_SHA256="6619db686c2117baab2bc4798b825f66c66d524b6648a7d9990acff9962d018b"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3c"
PKG_SITE="https://github.com/ARM-software/arm-trusted-firmware"
PKG_URL="https://github.com/crust-firmware/arm-trusted-firmware/archive/$PKG_VERSION.tar.gz"
PKG_LONGDESC="ARM Trusted Firmware is a reference implementation of secure world software, including a Secure Monitor executing at Exception Level 3 and various Arm interface standards."
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" CFLAGS="" make PLAT=$ATF_PLATFORM bl31
}

post_make_target() {
  cp -av build/$ATF_PLATFORM/release/bl31.bin .
}
