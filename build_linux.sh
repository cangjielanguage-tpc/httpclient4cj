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

# httpclient4cj
cd  ${dns_path}/
echo start build httpclient4cj
cjpm build -V
cp ${dns_path}/lib/*.so ${dns_path}/build/httpclient4cj/
echo end build httpclient4cj
