const app = require('./app');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

const server = app.listen(PORT, HOST, () => {
  console.log('====================================================');
  console.log('🚀 CI/CD Pipeline Automation System - Web Application');
  console.log(`🌐 Server listening on http://${HOST}:${PORT}`);
  console.log(`🩺 Health check ready at http://${HOST}:${PORT}/health`);
  console.log(`📊 Metrics telemetry at http://${HOST}:${PORT}/metrics`);
  console.log(`📦 Node Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`🏷️  App Version: ${process.env.APP_VERSION || '1.0.0'} | Build: ${process.env.BUILD_NUMBER || 'local'}`);
  console.log('====================================================');
});

// Graceful shutdown handling for Docker and Kubernetes orchestration
function handleShutdown(signal) {
  console.log(`\n🛑 Received ${signal}. Initiating graceful shutdown...`);
  server.close(() => {
    console.log('✅ HTTP server closed gracefully. Exiting process.');
    process.exit(0);
  });

  // Force close if graceful termination hangs
  setTimeout(() => {
    console.error('⚠️  Forcefully terminating after timeout.');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', () => handleShutdown('SIGTERM'));
process.on('SIGINT', () => handleShutdown('SIGINT'));
