#! /bin/bash

project_path=$(cd `dirname $0`; pwd)

# ohos_root为ohos交叉编译工具链目录 需手动设置
ohos_root="asd"

# httpclient4cj
cd  ${project_path}/
echo start build httpclient4cj

cjc.exe -V \
    --import-path build/aarch64-linux-ohos \
    --target=aarch64-linux-ohos \
    -B ${ohos_root}/out/rk3568/obj/third_party/musl/usr/lib/aarch64-linux-ohos \
    -B ${ohos_root}/prebuilts/clang/ohos/linux-x86_64/llvm/bin \
    -L ${ohos_root}/prebuilts/clang/ohos/linux-x86_64/llvm/lib/clang/12.0.1/lib/aarch64-linux-ohos \
    -L ${ohos_root}/prebuilts/clang/ohos/linux-x86_64/llvm/lib/aarch64-linux-ohos \
    -L ${ohos_root}/out/rk3568/obj/third_party/musl/usr/lib/aarch64-linux-ohos \
    --sysroot ${ohos_root}/out/rk3568/obj/third_party/musl \
    -O2 \
    -p "./src/httpclient4cj" \
    --module-name httpclient4cj \
    --output-type=dylib \
    --output-dir build/aarch64-linux-ohos/httpclient4cj \
    -o libhttpclient4cj_httpclient4cj.so

echo end build httpclient4cj
