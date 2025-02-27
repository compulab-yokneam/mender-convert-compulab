#!/bin/bash -xv

D=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
O=$(readlink -e ${D}/overlay)
M=$(readlink -e ${D}/../mender-convert)
I=$(readlink -e ${D}/../mender-convert/input)

BINFMT=/usr/lib/systemd/systemd-binfmt
CONFIG=${M}/configs/compulab_debian_64bit_config
IMAGE=${IMAGE:-"${M}/input/debian-bookworm-arm64.img"}
MACHINE_CONSOLE=${MACHINE_CONSOLE:-"console=ttymxc1,115200 console=tty0,115200n8"}

function compulab_config() {
cat << EOF
source configs/mender_convert_config

MENDER_IGNORE_MISSING_EFI_STUB=1
MENDER_STORAGE_TOTAL_SIZE_MB=12000
MENDER_ENABLE_PARTUUID=y
MENDER_BOOT_PART="/dev/disk/by-partuuid/00000001-0001-0001-0001-000000000001"
MENDER_ROOTFS_PART_A="/dev/disk/by-partuuid/00000002-0002-0002-0002-000000000002"
MENDER_ROOTFS_PART_B="/dev/disk/by-partuuid/00000003-0003-0003-0003-000000000003"
MENDER_DATA_PART="/dev/disk/by-partuuid/00000004-0004-0004-0004-000000000004"

MENDER_CLIENT_DATA_DIR_SERVICE_URL="https://raw.githubusercontent.com/mendersoftware/\
meta-mender/refs/tags/scarthgap-v2024.07/meta-mender-core/recipes-mender/mender-client/files/mender-data-dir.service"

MENDER_COMPRESS_DISK_IMAGE="none"
MENDER_COPY_BOOT_GAP="none"
# TBD
# MENDER_GRUB_D_INTEGRATION="y"

function compulab_modify_hook() {
    sed -i 's/\(set console_bootargs\).*/\1="@@@MACHINE_CONSOLE@@@"/' work/boot/EFI/BOOT/grub.cfg
    # fix for 8mp images
    if [ -f work/boot/efi/boot/grub.cfg ];then
        cp work/boot/EFI/BOOT/grub.cfg work/boot/efi/boot/grub.cfg
    fi
    true
}
PLATFORM_MODIFY_HOOKS+=(compulab_modify_hook)
EOF
}

function compulab_init_console() {
    sed -i "s/@@@MACHINE_CONSOLE@@@/${MACHINE_CONSOLE}/g" ${CONFIG}
}

function compulab_config_update() {
cat << EOF

# This is an imx8mm config
MENDER_GRUB_KERNEL_IMAGETYPE=Image

function compulab_modify_hook_01() {
    cp @@@BOOT_SCRIPT@@@ work/boot/boot.scr
    true
}
PLATFORM_MODIFY_HOOKS+=(compulab_modify_hook_01)
EOF
}

function compulab_init_bootscr() {
    local _uri="https://raw.githubusercontent.com/compulab-yokneam/meta-mender-compulab/refs/heads/scarthgap-nxp/recipes-bsp/u-boot-scr/files/boot.script"
    local BOOT_SCRIPT="${I}/boot.scr"
    wget --directory-prefix ${I} ${_uri}
    mkimage -C none -A arm -T script -d ${I}/boot.script ${BOOT_SCRIPT}
    rm -rf ${I}/boot.script*
    compulab_config_update >> ${CONFIG}
    sed -i "s|@@@BOOT_SCRIPT@@@|${BOOT_SCRIPT}|g" ${CONFIG}
}

function compulab_init() {
[[ ! -f ${BINFMT} ]] || chmod 0644 ${BINFMT}
compulab_config > ${CONFIG}
compulab_init_console
[[ -z "${MACHINE_BOOTSCRIPT}" ]] || compulab_init_bootscr
}

function compulab_fini() {
[[ ! -f ${BINFMT} ]] || chmod 0755 ${BINFMT}
rm -rf ${CONFIG}
}

compulab_init

cd ${M}

MENDER_ARTIFACT_NAME=release-1 ${M}/mender-convert \
   --disk-image ${IMAGE} \
   --config ${CONFIG} \
   --overlay ${O}

compulab_fini
