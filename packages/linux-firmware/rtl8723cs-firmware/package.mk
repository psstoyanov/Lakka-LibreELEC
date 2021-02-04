# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rtl8723cs-firmware"
PKG_VERSION="39da5959deff5041160fa85e62dddb89066471b3"
PKG_LICENSE="custom"
PKG_SITE="https://github.com/anarsoul/rtl8723bt-firmware"
PKG_URL="https://github.com/anarsoul/rtl8723bt-firmware/archive/$PKG_VERSION.tar.gz"

PKG_LONGDESC="Linux driver for Realtek RTL8723CS chip"
PKG_TOOLCHAIN="toolchain"


makeinstall_target(){
	# Doesn't move the 
	#cp -v $(get_build_dir) $INSTALL/$(get_full_firmware_dir)/rtl_bt
}