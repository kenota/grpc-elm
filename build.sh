#!/bin/bash

docker run --rm -v $(pwd)/proto/src:/input -v $(pwd)/proto/gen:/output -v $(pwd)/protogen.sh:/bin/protogen.sh kkenota/go-grpc-swagger 