#!/bin/sh
set -e

# Color codes for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo "${RED}❌ $1${NC}"
}

echo "🚀 Starting JKT48 App with runtime environment injection..."
echo "=================================================="

# 1. Verify critical directories exist
log_info "Checking critical directories..."
if [ ! -d "/app" ]; then
    log_error "Directory /app does not exist!"
    exit 1
fi

if [ ! -d "/app/public" ]; then
    log_warning "Directory /app/public does not exist, creating..."
    mkdir -p /app/public
fi

log_success "Directories OK"

# 2. Generate env-config.js
log_info "Generating runtime environment configuration..."

cat > /app/public/env-config.js << EOF
// This file is generated at runtime by docker-entrypoint.sh
// Generated at: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
window.__ENV__ = {
  NEXT_PUBLIC_API_URL: "${NEXT_PUBLIC_API_URL}",
  NEXT_PUBLIC_ENVIRONMENT: "${NEXT_PUBLIC_ENVIRONMENT}",
  FIREBASE_API_KEY: "${NEXT_PUBLIC_FIREBASE_API_KEY}",
  FIREBASE_AUTH_DOMAIN: "${NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN}",
  FIREBASE_PROJECT_ID: "${NEXT_PUBLIC_FIREBASE_PROJECT_ID}",
  FIREBASE_STORAGE_BUCKET: "${NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET}",
  FIREBASE_MESSAGING_SENDER_ID: "${NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID}",
  FIREBASE_APP_ID: "${NEXT_PUBLIC_FIREBASE_APP_ID}",
};
console.log('🔧 Runtime ENV loaded:', Object.keys(window.__ENV__));
EOF

# Verify env-config.js was created
if [ ! -f "/app/public/env-config.js" ]; then
    log_error "Failed to create env-config.js"
    exit 1
fi

log_success "env-config.js generated"
echo ""
echo "📋 Environment Configuration:"
echo "   Environment: ${NEXT_PUBLIC_ENVIRONMENT:-not set}"
echo "   API URL: ${NEXT_PUBLIC_API_URL:-not set}"
echo "   Firebase Project: ${NEXT_PUBLIC_FIREBASE_PROJECT_ID:-not set}"
echo ""

# 3. Check if server.js exists
log_info "Checking Next.js server files..."
if [ ! -f "/app/server.js" ]; then
    log_error "server.js not found!"
    log_error "This usually means:"
    log_error "  - Build failed"
    log_error "  - Dockerfile didn't copy .next/standalone correctly"
    log_error "  - next.config.js missing 'output: standalone'"
    echo ""
    log_info "Directory listing /app:"
    ls -la /app
    exit 1
fi

if [ ! -d "/app/.next" ]; then
    log_error ".next directory not found!"
    log_error "Build artifacts are missing"
    echo ""
    log_info "Directory listing /app:"
    ls -la /app
    exit 1
fi

log_success "Server files OK"

# 4. Check Bun installation
log_info "Checking Bun runtime..."
if ! command -v bun >/dev/null 2>&1; then
    log_error "Bun is not installed!"
    log_error "Please check Dockerfile"
    exit 1
fi

BUN_VERSION=$(bun --version)
log_success "Bun v${BUN_VERSION} detected"

# 5. Start Next.js server with Bun
log_info "Starting Next.js server with Bun..."
echo "=================================================="

cd /app

# Create log file for debugging
LOG_FILE="/tmp/nextjs-startup.log"
touch $LOG_FILE

# Start Bun in background and capture PID
bun server.js > $LOG_FILE 2>&1 &
NEXTJS_PID=$!

log_info "Next.js PID: $NEXTJS_PID"

# Verify process started
sleep 1
if ! kill -0 $NEXTJS_PID 2>/dev/null; then
    log_error "Next.js process died immediately after start!"
    echo ""
    log_error "=== STARTUP LOGS ==="
    cat $LOG_FILE
    echo ""
    log_error "=== POSSIBLE CAUSES ==="
    echo "  1. Missing dependencies"
    echo "  2. Port 3000 already in use"
    echo "  3. Memory limit exceeded"
    echo "  4. Invalid configuration"
    echo "  5. Build artifacts corrupted"
    exit 1
fi

log_success "Process started successfully"

# 6. Wait for Next.js to be ready
log_info "Waiting for Next.js server to be ready..."
echo "=================================================="

MAX_WAIT=60
SLEEP_INTERVAL=2
elapsed=0
last_log_line=0

while ! netstat -tln | grep -q ":3000 "; do
    # Check if process is still alive
    if ! kill -0 $NEXTJS_PID 2>/dev/null; then
        log_error "Next.js process died during startup!"
        echo ""
        log_error "=== FULL STARTUP LOGS ==="
        cat $LOG_FILE
        echo ""
        log_error "=== DEBUGGING STEPS ==="
        echo "  1. Check if port 3000 is available:"
        echo "     netstat -tlnp | grep 3000"
        echo "  2. Try running manually:"
        echo "     docker exec -it <container> bun server.js"
        echo "  3. Check memory:"
        echo "     docker stats <container>"
        echo "  4. Check disk space:"
        echo "     df -h"
        exit 1
    fi
    
    if [ $elapsed -ge $MAX_WAIT ]; then
        log_error "Next.js server failed to start within $MAX_WAIT seconds"
        echo ""
        log_error "=== LATEST LOGS (last 50 lines) ==="
        tail -n 50 $LOG_FILE
        echo ""
        log_error "=== PROCESS INFO ==="
        echo "PID: $NEXTJS_PID"
        echo "Status: $(ps -p $NEXTJS_PID -o state= 2>/dev/null || echo 'Not running')"
        echo ""
        log_error "=== NETWORK CHECK ==="
        netstat -tlnp 2>/dev/null | grep -E "(Proto|3000)" || echo "netstat not available"
        echo ""
        log_error "=== SYSTEM RESOURCES ==="
        echo "Memory:"
        free -h 2>/dev/null || echo "free command not available"
        echo "Disk:"
        df -h /app 2>/dev/null || echo "df command not available"
        echo ""
        log_error "=== TROUBLESHOOTING COMMANDS ==="
        echo "  View full logs:"
        echo "    docker exec <container> cat /tmp/nextjs-startup.log"
        echo ""
        echo "  Check if port is listening:"
        echo "    docker exec <container> netstat -tlnp | grep 3000"
        echo ""
        echo "  Try manual start:"
        echo "    docker exec -it <container> sh"
        echo "    cd /app && bun server.js"
        echo ""
        echo "  Check environment variables:"
        echo "    docker exec <container> env | grep NEXT"
        exit 1
    fi
    
    # Show progress with log snippets
    current_log_lines=$(wc -l < $LOG_FILE)
    if [ $current_log_lines -gt $last_log_line ]; then
        # Show new log lines
        new_lines=$((current_log_lines - last_log_line))
        if [ $new_lines -gt 0 ]; then
            log_warning "Recent logs:"
            tail -n $new_lines $LOG_FILE | sed 's/^/    /'
        fi
        last_log_line=$current_log_lines
    fi
    
    elapsed=$((elapsed + SLEEP_INTERVAL))
    echo "   ⏳ Waiting... (${elapsed}s / ${MAX_WAIT}s) - Process: $(ps -p $NEXTJS_PID -o state= 2>/dev/null || echo 'Unknown')"
    sleep $SLEEP_INTERVAL
done

log_success "Next.js server is ready! (took ${elapsed}s)"
echo ""

# 7. Verify server is responding
log_info "Verifying server health..."
if wget -q -O /dev/null http://localhost:3000 2>/dev/null; then
    log_success "Server responding correctly"
else
    log_warning "Server port open but not responding properly"
    log_info "This might be normal, continuing..."
fi

# 8. Show startup summary
echo ""
echo "=================================================="
log_success "APPLICATION STARTED SUCCESSFULLY"
echo "=================================================="
echo "📊 Startup Summary:"
echo "   Next.js PID: $NEXTJS_PID"
echo "   Startup Time: ${elapsed}s"
echo "   Environment: ${NEXT_PUBLIC_ENVIRONMENT}"
echo "   API URL: ${NEXT_PUBLIC_API_URL}"
echo ""
echo "🔍 Monitoring:"
echo "   View logs: docker logs -f <container>"
echo "   Check health: curl http://localhost/health"
echo "   Next.js logs: docker exec <container> cat /tmp/nextjs-startup.log"
echo "=================================================="
echo ""

# 9. Start Nginx
log_info "Starting Nginx reverse proxy..."
exec "$@"