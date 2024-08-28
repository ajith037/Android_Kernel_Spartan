#!/bin/bash
clear
echo Cloning AnyKernel
git clone https://github.com/yograjfire18/AnyKernel3 --depth=1 anykernel

DT=$(date +"%Y%m%d-%H%M")
config=vendor/kona-perf_defconfig

compile() {
export KBUILD_BUILD_HOST="$(uname -a | awk '{print $2}')"
export PATH="$pwd/tc/clang/bin:$PATH"
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
make O=out CC=clang $config
make O=out CC=clang LLVM=1 LLVM_IAS=1 AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip -j$(nproc --all) |& tee build.log
}

zipping() {
echo zipping kernel

cd anykernel || exit 1
    rm *zip
    cp ../out/arch/arm64/boot/Image .
    cp ../out/arch/arm64/boot/dtbo.img .
    cp ../out/arch/arm64/boot/dtb .
    zip -r9 perf-${DT}.zip *
    rm Image dtbo.img dtb
    cd ..
}

remove() {
cd out/arch/arm64/boot
rm Image dtbo.img dtb
}

compile
zipping
remove
