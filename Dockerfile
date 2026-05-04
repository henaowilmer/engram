FROM golang:1.25-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/engram ./cmd/engram

FROM alpine:3.21
RUN apk add --no-cache ca-certificates tzdata
RUN adduser -D -u 10001 engram
USER engram
WORKDIR /home/engram
COPY --from=builder /out/engram /usr/local/bin/engram

EXPOSE 18080
ENTRYPOINT ["engram"]
CMD ["cloud", "serve"]
