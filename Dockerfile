# Multi-stage build untuk Next.js dengan Bun dan Runtime ENV Injection

# Stage 1: Dependencies
FROM oven/bun:1 AS deps
WORKDIR /app

COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

# Stage 2: Builder (NO ENV VARIABLES HERE!)
FROM oven/bun:1 AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set build-time variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build WITHOUT environment variables
# Next.js akan menggunakan placeholder untuk runtime variables
RUN bun run build

# Stage 3: Production dengan Nginx + Runtime ENV Injection
FROM fholzer/nginx-brotli:v1.28.0 AS runner

# Install Bun, gettext (untuk envsubst), dan wget (untuk health check)
RUN apk add --no-cache curl unzip gettext wget bash && \
    curl -fsSL https://bun.sh/install | bash && \
    mv /root/.bun/bin/bun /usr/local/bin/bun && \
    rm -rf /root/.bun && \
    apk del curl unzip

WORKDIR /app

# Copy built application
COPY --from=builder --chown=nginx:nginx /app/public ./public
COPY --from=builder --chown=nginx:nginx /app/.next/static ./.next/static

# Copy PWA files
RUN cp -f /app/public/sw.js ./public/sw.js 2>/dev/null || true
RUN cp -f /app/public/workbox-*.js ./public/ 2>/dev/null || true
RUN cp -f /app/public/manifest.json ./public/manifest.json 2>/dev/null || true

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy env injection script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

EXPOSE 80

# Use entrypoint untuk inject env variables at runtime
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]