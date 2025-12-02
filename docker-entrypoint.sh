#!/bin/sh
set -e

echo "🚀 Starting application with runtime environment injection..."

# Function to replace env variables in JS files
inject_env_to_js() {
    local file=$1
    echo "📝 Injecting environment variables into: $file"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Replace environment variable placeholders
    # Format: process.env.NEXT_PUBLIC_* akan di-replace dengan actual values
    envsubst < "$file" > "$temp_file"
    
    # Move temp file back
    mv "$temp_file" "$file"
}

# Create env-config.js with runtime environment variables
# File ini akan di-load oleh aplikasi Next.js
cat > /app/public/env-config.js << EOF
// This file is generated at runtime
window.__ENV__ = {
  NEXT_PUBLIC_API_URL: "${NEXT_PUBLIC_API_URL}",
  NEXT_PUBLIC_ENVIRONMENT: "${NEXT_PUBLIC_ENVIRONMENT}",
  // Add other NEXT_PUBLIC_ variables here
  FIREBASE_API_KEY: "${NEXT_PUBLIC_FIREBASE_API_KEY}",
  FIREBASE_AUTH_DOMAIN: "${NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN}",
  FIREBASE_PROJECT_ID: "${NEXT_PUBLIC_FIREBASE_PROJECT_ID}",
  FIREBASE_STORAGE_BUCKET: "${NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET}",
  FIREBASE_MESSAGING_SENDER_ID: "${NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID}",
  FIREBASE_APP_ID: "${NEXT_PUBLIC_FIREBASE_APP_ID}",
};
EOF

echo "✅ Environment variables injected successfully"
echo "🔥 Environment: ${NEXT_PUBLIC_ENVIRONMENT:-production}"
echo "🌐 API URL: ${NEXT_PUBLIC_API_URL:-not set}"

# Start Bun server in background
echo "🏃 Starting Next.js server with Bun..."
cd /app
bun server.js &

# Wait for Next.js to be ready
echo "⏳ Waiting for Next.js server to be ready..."
timeout=60
counter=0
until wget --spider -q http://localhost:3000 2>/dev/null; do
    counter=$((counter + 1))
    if [ $counter -gt $timeout ]; then
        echo "❌ Next.js server failed to start within $timeout seconds"
        exit 1
    fi
    echo "   Waiting... ($counter/$timeout)"
    sleep 1
done

echo "✅ Next.js server is ready!"
echo "🌐 Starting Nginx..."

# Execute CMD (nginx in this case)
exec "$@"