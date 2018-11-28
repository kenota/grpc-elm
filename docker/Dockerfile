FROM grpc/go:1.0

RUN mkdir /input && \
    mkdir /output && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y openjdk-8-jre-headless && \
    rm -rf /var/lib/apt/lists* && \
    go get -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger \
        github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

ADD openapi-generator-cli.jar /usr/bin/openapi-generator-cli.jar

ENTRYPOINT /bin/protogen.sh