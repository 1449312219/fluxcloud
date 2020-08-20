FROM alpine:3.10.0@sha256:ca1c944a4f8486a153024d9965aafbe24f5723c1d5c02f4964c045a16d19dc54
RUN apk update && apk add ca-certificates

FROM golang:1.12.5@sha256:5bc207d20bd9e97c57dc2ad013f2b02d982cc6e411d48bdc79d90bb601696650
WORKDIR /apps
ADD . .
RUN GO111MODULE=on GOCACHE=/build/.gocache GOPATH=/build/.go GOBIN=/build/bin/ CGO_ENABLED=0 GOOS=linux go build -ldflags '-w -extldflags -static' -o ./fluxcloud ./cmd/

FROM gcr.io/distroless/static@sha256:48e0d165f07d499c02732d924e84efbc73df8021b12c24940e18a9306589430e
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=1 /apps/fluxcloud /fluxcloud
EXPOSE 3031
ENTRYPOINT ["/fluxcloud"]
