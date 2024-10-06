#!/bin/bash

echo "Hello, I am a Current Shell."
echo "Current directory is $(pwd)"

# 1. 현재 쉘로 실행하는 경우
source ./sub.sh

echo "Current directory is $(pwd)"

# 2. 자식 쉘로 실행하는 경우
chmod +x ./sub.sh
./sub.sh

echo "Current directory is $(pwd)"
