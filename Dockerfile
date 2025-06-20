# Step 1: Build the Go app with static linking
FROM golang:1.22 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy go.mod and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build a statically linked binary (no glibc needed)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o myapp

# Step 2: Use a minimal image to run the binary
FROM scratch

WORKDIR /app

# Copy the statically built binary
COPY --from=builder /app/myapp .

# Copy static files if needed (e.g., HTML, CSS, JS)
COPY --from=builder /app/static ./static

# Expose the app's port
EXPOSE 8080

# Start the app
CMD ["./myapp"]