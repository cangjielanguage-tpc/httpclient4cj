#! /bin/bash

dns_path=$(cd `dirname $0`; pwd)

mkdir -p lib

# libdns
cd ${dns_path}/dns
if [ -f "Makefile" ];then
    make clean
fi

./configure
make

# okhttp
cd  ${dns_path}/
echo start build okhttp
cpm build -V
cp ${dns_path}/lib/*.so ${dns_path}/build/okhttp/
echo end build okhttp
