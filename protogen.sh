#!/bin/bash

set -e

cd /output

rm -rf * && mkdir -p {server,swagger,elm}


protoc \
    -I /input \
    -I/usr/include \
    -I$GOPATH/src \
    -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
    --go_out=plugins=grpc:server \
    --grpc-gateway_out=logtostderr=true:server \
    --swagger_out=logtostderr=true:swagger \
    helloworld/helloworld.proto

sed -i 's/"swagger": "2.0",/"swagger": "2.0", "host": "localhost:8080",/' swagger/helloworld/helloworld.swagger.json

java -jar /usr/bin/openapi-generator-cli.jar generate \
    -i swagger/helloworld/helloworld.swagger.json \
    -g elm \
    -o elm
 