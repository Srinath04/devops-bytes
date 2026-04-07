cat > scripts/setup-codebeamer.sh << 'EOF'
#!/bin/bash
# Codebeamer 22.10-SP11 Setup Script
# Run on fresh Ubuntu 22.04 EC2

set -e

echo "=== Setting up Codebeamer ==="

# Create network
docker network create cb-network

# Start PostgreSQL 12
docker run -d \
  --name cb-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD= \
  -e POSTGRES_DB=postgres \
  -v cb-pgdata:/var/lib/postgresql/data \
  --network cb-network \
  --restart unless-stopped \
  postgres:12

echo "Waiting for PostgreSQL..."
sleep 20

# Start Codebeamer
docker run -d \
  --name codebeamer \
  -p 8080:8080 \
  -v cb-data:/opt/codebeamer/repository \
  --network cb-network \
  --restart unless-stopped \
  intland/codebeamer:22.10-SP11

echo "=== Done! Access at http://<your-ip>:8080/cb in few mins ==="
EOF

chmod +x scripts/setup-codebeamer.sh