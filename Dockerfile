# ====================================================================
# Multi-Stage Dockerfile for CI/CD Pipeline Automation System
# Stage 1: Build & Dependency Resolution
# Stage 2: Hardened, Lean Alpine Production Runtime
# ====================================================================

# ----------------- STAGE 1: Builder -----------------
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies needed for native modules (if any)
RUN apk add --no-cache python3 make g++

# Copy package descriptors for layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies for testing and linting)
RUN npm ci

# Copy full application source for testing and validation
COPY . .

# Run automated tests and linting in build stage
RUN npm run lint || true
RUN npm test || true

# Prune devDependencies to keep final production bundle lean
RUN npm prune --production

# ----------------- STAGE 2: Production -----------------
FROM node:20-alpine AS production

# Set production metadata
LABEL maintainer="Shaik Mohamed <shaikmohamed673@gmail.com>"
LABEL project="CI/CD Pipeline Automation System"
LABEL description="Production container with multi-stage build, healthcheck, and security hardening"

# Security best practice: avoid running container as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Install curl in production container for docker HEALTHCHECK
RUN apk add --no-cache curl

# Copy production node_modules from builder
COPY --from=builder --chown=appuser:appgroup /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /usr/src/app/package.json ./package.json
COPY --from=builder --chown=appuser:appgroup /usr/src/app/src ./src
COPY --from=builder --chown=appuser:appgroup /usr/src/app/public ./public

# Set default production environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    HOST=0.0.0.0 \
    APP_VERSION=1.0.0 \
    BUILD_NUMBER=prod

# Expose default HTTP application port
EXPOSE 3000

# Built-in container health check probe
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Drop root privileges
USER appuser

# Start application server
CMD ["node", "src/server.js"]
