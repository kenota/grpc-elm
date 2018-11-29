# Type Safe api between golang and ELM without writing decoders

This repository contains code to demonstrate how type safe API can be created using [Go](http://golang.org) with client library for [ELM](https://elm-lang.org/) without writing any decoding/network code.

This is the code I demonstrated on the [London Elm Meetup](https://www.meetup.com/Elm-London-Meetup/) lightning talk called "Typesafe all the way". Talk slides are available [here](https://docs.google.com/presentation/d/1GvTgJvtKOHaECCmphjl_1zNJjIWk1dXKrq9v_NyX0aU/edit?usp=sharing)

## Running example

### Requriements

* Golang 1.11+
* Go [dep tool](https://github.com/golang/dep)
* elm 0.19
* [docker](https://www.docker.com/)

### Instructions

1. Clone the code `git clone https://github.com/kenota/grpc-elm.git`
1. Run `dep ensure`
2. Run `./build.sh` this will generate 3 things:
   1. Golang server/client stubs in `proto/gen/golang`
   2. Openapi V2 definitions in `proto/gen/swagger`
   3. ELM client library & decoders in `proto/gen/elm`
3. In terminal run `go run main.go`
4. Open another terminal, go to `frontend` folder and run `elm reactor`
5. Open [http://localhost:8000](http://localhost:8000) 
