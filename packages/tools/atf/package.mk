# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC

PKG_NAME="atf"
PKG_VERSION="f928897fa5df6afa0f70bb1b1011e4bb03cb4596"
PKG_SHA256="5161a07ed9065c876cd0d37bd9b544b77a707bcde9d0cdf86b83c7b0b5bfa95b"
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
