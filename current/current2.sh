#!/bin/bash

echo "Hello, I am a Current Shell."
echo "Current2 directory is $(pwd)"

# 2. 자식 쉘로 실행하는 경우
chmod +x ./sub2.sh
./sub2.sh

echo "Current2 directory is $(pwd)"