# platform-templates: go.Dockerfile (v1)
# Multi-stage build for Go services. Service repos should NOT modify this file directly —
# propose changes upstream in platform-templates so all services benefit.

ARG GO_VERSION=1.22

# ---- build stage ----
FROM golang:${GO_VERSION}-alpine AS builder
WORKDIR /src
RUN apk add --no-cache git ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG SERVICE_NAME
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/${SERVICE_NAME} ./cmd/${SERVICE_NAME}

# ---- runtime stage ----
FROM gcr.io/distroless/static-debian12:nonroot AS runtime
ARG SERVICE_NAME
ENV SERVICE_BIN=/app/service
COPY --from=builder /out/${SERVICE_NAME} ${SERVICE_BIN}
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/service"]
