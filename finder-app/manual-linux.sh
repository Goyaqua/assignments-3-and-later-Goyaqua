#!/bin/bash
# Script to install and build Linux kernel and a minimal root filesystem.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
TOOLCHAIN_PATH=$(dirname $(which ${CROSS_COMPILE}gcc))

if [ $# -lt 1 ]; then
  echo "Using default directory ${OUTDIR} for output"
else
  OUTDIR=$1
  echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}
if [ $? -ne 0 ]; then
  echo "Could not create ${OUTDIR}"
  exit 1
fi

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
  echo "Cloning Linux kernel version ${KERNEL_VERSION}"
  git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
  cd linux-stable
  echo "Checking out version ${KERNEL_VERSION}"
  git checkout ${KERNEL_VERSION}

  make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
  make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
  make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
  make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image

cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	  echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

mkdir -pv ${OUTDIR}/rootfs/{bin,dev,etc,home,lib,lib64,proc,sbin,sys,tmp}
mkdir -pv ${OUTDIR}/rootfs/usr/{bin,lib,sbin}
mkdir -pv ${OUTDIR}/rootfs/var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]; then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
  make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
  make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
else
    cd busybox
fi

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

SYSROOT=$(aarch64-none-linux-gnu-gcc -print-sysroot)

# TODO: Add library dependencies to rootfs
cd ${OUTDIR}/rootfs
cp ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
cp ${SYSROOT}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

echo "Creating device nodes..."
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 600 ${OUTDIR}/rootfs/dev/console c 5 1

echo "Copying user applications and scripts..."
mkdir -p ${OUTDIR}/rootfs/home

cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=$CROSS_COMPILE

cp -ar ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home/
cp -ar ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
cp -ar ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/
cp -ar ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home/
cp -ar ${FINDER_APP_DIR}/../conf ${OUTDIR}/rootfs/home/

# Fix path inside finder-test.sh
sed -i 's|../conf/assignment.txt|conf/assignment.txt|' ${OUTDIR}/rootfs/home/finder-test.sh

echo "Setting ownership and creating init link..."
cd ${OUTDIR}/rootfs
sudo chown -R root:root .
sudo ln -sf bin/sh init

echo "Creating initramfs.cpio.gz..."
find . | cpio -H newc -ov --owner root:root 2>/dev/null | gzip > ${OUTDIR}/initramfs.cpio.gz
echo "Done: ${OUTDIR}/initramfs.cpio.gz created"

