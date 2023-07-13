#! /bin/bash

dns_path=$(cd `dirname $0`; pwd)

mkdir -p lib

# libdns
cd ${dns_path}/dns
if [ -f "Makefile" ];then
    make clean
fi

# "/usr1/ohos/llvm/bin/"为ohos编译路径，
# "/usr1/ohos/llvm/include/aarch64-linux-ohos"为ohos头文件路径，请自行修改
./configure --cc="/usr1/ohos/llvm/bin/clang" --cross-prefix="/usr1/ohos/llvm/bin/llvm-" \
--target=aarch64-linux-ohos --cflags="-I/usr1/ohos/llvm/include/aarch64-linux-ohos"
make

# httpclient4cj
cd  ${dns_path}/
echo start build httpclient4cj
cjpm build -V
cp ${dns_path}/lib/*.so ${dns_path}/build/httpclient4cj/
echo end build httpclient4cj
