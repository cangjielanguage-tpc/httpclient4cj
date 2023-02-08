#!/bin/bash

cmd=$(grep $1 $3 | wc -l)

if [ $cmd -eq $2 ];then
	exit 0
else
	exit 1
fi
