FROM golang:alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o rdsrestore

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/app" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid 1000 \    
    appuser

FROM scratch
LABEL org.opencontainers.image.authors="f.kloeker@telekom.de"
LABEL version="0.0.1"
LABEL description="Restore RDS instance in Open Telekom Cloud (OTC)"

WORKDIR /app
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /app/rdsrestore /app/rdsrestore
USER appuser
CMD ["/app/rdsrestore"]
