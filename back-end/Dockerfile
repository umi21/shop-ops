# ─── Stage 1: Build ───────────────────────────────────────────
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install git (required for some Go modules)
RUN apk add --no-cache git

# Download dependencies first (cached if go.mod/go.sum don't change)
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /shopops-server ./Delivery/main.go

# ─── Stage 2: Run ────────────────────────────────────────────
FROM alpine:3.21

WORKDIR /app

# Add ca-certificates for HTTPS (e.g., MongoDB Atlas)
RUN apk add --no-cache ca-certificates tzdata

# Create directory for exports
RUN mkdir -p /app/tmp/exports

# Copy only the compiled binary from the builder
COPY --from=builder /shopops-server .

# Copy .env.example as reference (actual .env is mounted or env vars are set)
COPY .env.example .env.example

# Expose the default port
EXPOSE 8080

# Run the server
CMD ["./shopops-server"]
