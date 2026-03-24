FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o product-service .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/product-service .
EXPOSE 8002
CMD ["./product-service"]