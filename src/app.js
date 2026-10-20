const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const os = require('os');

const app = express();

const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const BUILD_NUMBER = process.env.BUILD_NUMBER || 'local-dev';
const GIT_COMMIT = process.env.GIT_COMMIT || 'development';
const ENVIRONMENT = process.env.NODE_ENV || 'production';
const START_TIME = new Date();

// Security and middleware
app.use(helmet({
  contentSecurityPolicy: false // Allow inline scripts and dashboard styling
}));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Structured logging in non-test environments
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan(':date[iso] | :method :url | :status | :response-time ms - :res[content-length]'));
}

// Serve static frontend assets
app.use(express.static(path.join(__dirname, '../public')));

/**
 * Health Check Endpoint
 * Used by Jenkins pipeline stage, Docker HEALTHCHECK, and load balancers
 */
app.get('/health', (req, res) => {
  const uptimeSeconds = Math.floor(process.uptime());
  const memUsage = process.memoryUsage();

  res.status(200).json({
    status: 'UP',
    statusCode: 200,
    service: 'cicd-pipeline-automation-system',
    timestamp: new Date().toISOString(),
    uptime: {
      seconds: uptimeSeconds,
      formatted: `${Math.floor(uptimeSeconds / 3600)}h ${Math.floor((uptimeSeconds % 3600) / 60)}m ${uptimeSeconds % 60}s`
    },
    version: APP_VERSION,
    build: {
      number: BUILD_NUMBER,
      commit: GIT_COMMIT
    },
    system: {
      hostname: os.hostname(),
      platform: os.platform(),
      arch: os.arch(),
      nodeVersion: process.version,
      cpus: os.cpus().length,
      freeMemoryBytes: os.freemem(),
      totalMemoryBytes: os.totalmem()
    },
    process: {
      pid: process.pid,
      memoryRssMB: (memUsage.rss / 1024 / 1024).toFixed(2),
      heapUsedMB: (memUsage.heapUsed / 1024 / 1024).toFixed(2),
      heapTotalMB: (memUsage.heapTotal / 1024 / 1024).toFixed(2)
    }
  });
});

/**
 * Application Metadata Endpoint
 */
app.get('/api/info', (req, res) => {
  res.status(200).json({
    application: 'CI/CD Pipeline Automation System',
    description: 'Automated CI/CD pipeline for application build, testing, and deployment',
    author: 'Shaik Mohamed',
    organization: 'Cognevance Internship Project',
    version: APP_VERSION,
    buildNumber: BUILD_NUMBER,
    gitCommit: GIT_COMMIT,
    environment: ENVIRONMENT,
    startedAt: START_TIME.toISOString(),
    containerized: true,
    dockerEngine: 'Docker Engine & Docker Hub Integrated'
  });
});

/**
 * System Status Endpoint
 */
app.get('/api/status', (req, res) => {
  res.status(200).json({
    healthy: true,
    status: 'ONLINE',
    trafficAccepting: true,
    timestamp: new Date().toISOString()
  });
});

/**
 * Metrics Telemetry Endpoint
 */
app.get('/metrics', (req, res) => {
  const mem = process.memoryUsage();
  res.status(200).json({
    processUptimeSeconds: Math.floor(process.uptime()),
    systemUptimeSeconds: Math.floor(os.uptime()),
    memory: {
      rss: mem.rss,
      heapTotal: mem.heapTotal,
      heapUsed: mem.heapUsed,
      external: mem.external
    },
    loadAverage: os.loadavg ? os.loadavg() : [0, 0, 0],
    cpuCount: os.cpus().length,
    activeHandles: process._getActiveHandles ? process._getActiveHandles().length : 0
  });
});

/**
 * Simulated Load Endpoint (For testing & demo purposes)
 */
app.post('/api/simulate-load', (req, res) => {
  const { durationMs = 50 } = req.body;
  const start = Date.now();
  while (Date.now() - start < Math.min(durationMs, 500)) {
    // intentional brief CPU workload
  }
  res.status(200).json({
    message: `Simulated load executed for ${durationMs}ms`,
    timestamp: new Date().toISOString(),
    success: true
  });
});

// Fallback 404 handler
app.use((req, res) => {
  if (req.accepts('html')) {
    res.status(404).sendFile(path.join(__dirname, '../public/index.html'));
    return;
  }
  res.status(404).json({
    error: 'Not Found',
    path: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

// Centralized error handler
app.use((err, req, res, next) => {
  console.error('Unhandled Application Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

module.exports = app;
