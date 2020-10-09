FROM golang:1.12-alpine AS build_base

ENV GO111MODULE=on
ENV CGO_ENABLED=0
RUN apk add --no-cache git  git gcc g++

# Set the Current Working Directory inside the container
WORKDIR /src

# We want to populate the module cache based on the go.{mod,sum} files.
COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

# Build the Go app
RUN go build -o ./out/app ./cmd/api/main.go

# Start fresh from a smaller image
FROM alpine:3.9
RUN apk add ca-certificates

COPY --from=build_base /src/out/app /app/restapi

# This container exposes port 8080 to the outside world
EXPOSE 3000

# Run the binary program produced by `go install`
CMD ["/app/restapi"]