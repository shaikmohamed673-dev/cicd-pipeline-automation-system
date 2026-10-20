const request = require('supertest');
const app = require('../src/app');

describe('CI/CD Pipeline Automated Test Suite', () => {
  describe('GET /health (Health & Liveness Probe)', () => {
    it('should return 200 OK with status UP and system details', async () => {
      const res = await request(app)
        .get('/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(res.body).toHaveProperty('status', 'UP');
      expect(res.body).toHaveProperty('statusCode', 200);
      expect(res.body).toHaveProperty('service', 'cicd-pipeline-automation-system');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('uptime');
      expect(typeof res.body.uptime.seconds).toBe('number');
      expect(res.body).toHaveProperty('system');
      expect(res.body.system).toHaveProperty('hostname');
      expect(res.body.system).toHaveProperty('platform');
      expect(res.body.system).toHaveProperty('nodeVersion');
      expect(res.body).toHaveProperty('process');
      expect(res.body.process).toHaveProperty('heapUsedMB');
    });
  });

  describe('GET /api/info (Metadata Telemetry)', () => {
    it('should return 200 OK with application metadata and author credentials', async () => {
      const res = await request(app)
        .get('/api/info')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(res.body).toHaveProperty('application', 'CI/CD Pipeline Automation System');
      expect(res.body).toHaveProperty('author', 'Shaik Mohamed');
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('buildNumber');
      expect(res.body).toHaveProperty('containerized', true);
    });
  });

  describe('GET /api/status (Microservice Availability)', () => {
    it('should return 200 OK with healthy true and ONLINE status', async () => {
      const res = await request(app)
        .get('/api/status')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(res.body).toHaveProperty('healthy', true);
      expect(res.body).toHaveProperty('status', 'ONLINE');
      expect(res.body).toHaveProperty('trafficAccepting', true);
    });
  });

  describe('GET /metrics (Prometheus / System Metrics)', () => {
    it('should return memory statistics and CPU count', async () => {
      const res = await request(app)
        .get('/metrics')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(res.body).toHaveProperty('memory');
      expect(res.body.memory).toHaveProperty('heapUsed');
      expect(res.body).toHaveProperty('cpuCount');
      expect(typeof res.body.cpuCount).toBe('number');
      expect(res.body.cpuCount).toBeGreaterThan(0);
    });
  });

  describe('POST /api/simulate-load (Synthetic Workload Test)', () => {
    it('should execute a workload and respond with success', async () => {
      const res = await request(app)
        .post('/api/simulate-load')
        .send({ durationMs: 20 })
        .expect('Content-Type', /json/)
        .expect(200);

      expect(res.body).toHaveProperty('success', true);
      expect(res.body).toHaveProperty('message');
    });
  });

  describe('GET / (Web Dashboard Route)', () => {
    it('should serve HTML dashboard with 200 OK', async () => {
      const res = await request(app)
        .get('/')
        .expect('Content-Type', /html/)
        .expect(200);

      expect(res.text).toContain('CI/CD Pipeline Automation System');
      expect(res.text).toContain('Shaik Mohamed');
    });
  });

  describe('Error Handling', () => {
    it('should return 404 for unknown JSON API routes', async () => {
      const res = await request(app)
        .get('/api/unknown-endpoint')
        .set('Accept', 'application/json')
        .expect(404);

      expect(res.body).toHaveProperty('error', 'Not Found');
    });
  });
});
