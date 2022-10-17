#!/bin/bash

set -e

cd lambda
mkdir -p build package

GOOS=linux go build -o build/main main.go

jq -n {}