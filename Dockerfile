FROM golang:1.18-buster as build

ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y ca-certificates

WORKDIR src/server

RUN go env -w GOPROXY=direct

ADD go.mod go.sum ./
# RUN go mod download

ADD . .

RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /bin/server ./

FROM scratch
COPY --from=build /bin/server /server
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

WORKDIR go/src/server

EXPOSE 8081

ENTRYPOINT [ "/server" ]
