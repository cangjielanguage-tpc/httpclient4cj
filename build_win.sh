#! /bin/bash

project_path=$(cd `dirname $0`; pwd)

# httpclient4cj
cd  ${project_path}/
echo start build httpclient4cj
cjpm build -V
echo end build httpclient4cj
