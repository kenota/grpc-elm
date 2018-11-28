package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"

	"google.golang.org/grpc/codes"

	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	"google.golang.org/grpc"

	pb "github.com/kenota/grpc-elm/proto/gen/server/helloworld"
	"github.com/rs/cors"
)

// Hardcoded config
const (
	grpcHostPort = "127.0.0.1:8383"
	webHostPort  = "0.0.0.0:8080"
)

type myGreeter struct {
}

// Business logic
func (p *myGreeter) SayHello(ctx context.Context, req *pb.ElmTalkRequest) (*pb.ElmTalkResponse, error) {
	var responseText string

	switch req.GreetingType {
	case pb.GreetingType_ELM_WAY:
		responseText = fmt.Sprintf("say (hello %s)", req.Name)
	case pb.GreetingType_NORMAL:
		responseText = fmt.Sprintf("hello %s", req.Name)
	default:
		return nil, grpc.Errorf(codes.InvalidArgument, "bad type for greeting type: %s", req.GreetingType.String())
	}
	return &pb.ElmTalkResponse{
		Greeting: responseText,
	}, nil
}

func makeHelloworldServer() pb.HelloWorldServiceServer {
	return &myGreeter{}
}

func mustMakeGrpcServer() *grpc.Server {
	res := grpc.NewServer()
	pb.RegisterHelloWorldServiceServer(res, makeHelloworldServer())

	return res
}

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	// Creating GRPC server which is exposing HTTP/2 interface
	grcpServer := mustMakeGrpcServer()

	listen, err := net.Listen("tcp", grpcHostPort)
	if err != nil {
		log.Fatalf("error opening socket on %s: %v", grpcHostPort, err)
	}
	go func() {
		err := grcpServer.Serve(listen)
		log.Printf("grpc server stopped. Last errorr %v", err)
	}()

	// Creating grpc-gateway, a HTTP-proxy which talks to underlying GRPC servier over HTTP/2
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	if err = pb.RegisterHelloWorldServiceHandlerFromEndpoint(ctx, mux, grpcHostPort, opts); err != nil {
		log.Fatalf("error starting grpc gateway: %v", err)
	}

	log.Printf("starting web gateway on %s...", webHostPort)

	// Allowing all cors headers
	handler := cors.Default().Handler(mux)
	err = http.ListenAndServe(webHostPort, handler)
	log.Printf("gateway exited. return error: %v", err)
}
