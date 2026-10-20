// CI/CD Pipeline Automation System - Dashboard Client Logic

document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const uptimeEl = document.getElementById('telemetry-uptime');
  const startedEl = document.getElementById('telemetry-started');
  const hostnameEl = document.getElementById('telemetry-hostname');
  const platformEl = document.getElementById('telemetry-platform');
  const memoryEl = document.getElementById('telemetry-memory');
  const heapEl = document.getElementById('telemetry-heap');
  const latencyEl = document.getElementById('telemetry-latency');
  const consoleOutput = document.getElementById('console-output');
  const consoleLabel = document.getElementById('console-endpoint-label');
  const statusBadge = document.getElementById('system-status-badge');
  const themeToggle = document.getElementById('theme-toggle-btn');
  const copyBtn = document.getElementById('copy-console-btn');
  const simulateBtn = document.getElementById('simulate-pipeline-btn');

  // Active theme management
  const savedTheme = localStorage.getItem('cicd_theme') || 'dark';
  document.body.setAttribute('data-theme', savedTheme);

  themeToggle.addEventListener('click', () => {
    const current = document.body.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    document.body.setAttribute('data-theme', next);
    localStorage.setItem('cicd_theme', next);
  });

  // Fetch API helper with latency measurement
  async function fetchEndpoint(url, label, method = 'GET', body = null) {
    consoleLabel.textContent = `${method} ${url}`;
    consoleOutput.textContent = `// Sending ${method} request to ${url}...`;

    const startTime = performance.now();
    try {
      const options = {
        method,
        headers: { 'Content-Type': 'application/json' }
      };
      if (body) {
        options.body = JSON.stringify(body);
      }

      const res = await fetch(url, options);
      const latency = Math.round(performance.now() - startTime);
      latencyEl.textContent = `${latency} ms`;

      const data = await res.json();
      consoleOutput.textContent = JSON.stringify(data, null, 2);
      return { ok: res.ok, data, latency };
    } catch (err) {
      consoleOutput.textContent = `// Error connecting to ${url}:\n${err.message}`;
      return { ok: false, error: err };
    }
  }

  // Live telemetry polling
  async function updateTelemetry() {
    try {
      const start = performance.now();
      const res = await fetch('/health');
      const latency = Math.round(performance.now() - start);

      if (res.ok) {
        const data = await res.json();
        uptimeEl.textContent = data.uptime ? data.uptime.formatted : 'Active';
        hostnameEl.textContent = data.system.hostname || 'Docker Container';
        platformEl.textContent = `${data.system.platform} (${data.system.arch}) • Node ${data.system.nodeVersion}`;
        memoryEl.textContent = `${data.process.memoryRssMB} MB RSS`;
        heapEl.textContent = `${data.process.heapUsedMB} MB / ${data.process.heapTotalMB} MB`;
        latencyEl.textContent = `${latency} ms`;
        startedEl.textContent = new Date(data.timestamp).toLocaleTimeString();

        statusBadge.innerHTML = `
          <span class="status-dot pulsing"></span>
          <span class="status-label">HEALTHY (200 OK)</span>
        `;
      }
    } catch {
      statusBadge.innerHTML = `
        <span class="status-dot" style="background:#ef4444"></span>
        <span class="status-label" style="color:#ef4444">OFFLINE</span>
      `;
    }
  }

  // Button Listeners
  document.getElementById('btn-health-check').addEventListener('click', () => {
    fetchEndpoint('/health', 'Health Check');
  });

  document.getElementById('btn-api-info').addEventListener('click', () => {
    fetchEndpoint('/api/info', 'App Metadata');
  });

  document.getElementById('btn-metrics').addEventListener('click', () => {
    fetchEndpoint('/metrics', 'Metrics Telemetry');
  });

  document.getElementById('btn-simulate-load').addEventListener('click', () => {
    fetchEndpoint('/api/simulate-load', 'Simulate Load', 'POST', { durationMs: 100 });
  });

  // Copy to clipboard
  copyBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(consoleOutput.textContent).then(() => {
      copyBtn.textContent = 'Copied!';
      setTimeout(() => { copyBtn.textContent = 'Copy JSON'; }, 2000);
    });
  });

  // Pipeline simulation demonstration
  simulateBtn.addEventListener('click', async () => {
    const nodes = document.querySelectorAll('.stage-node');
    simulateBtn.disabled = true;
    simulateBtn.textContent = 'Running Pipeline...';

    // Reset all to pending
    nodes.forEach(node => {
      node.classList.remove('success', 'running');
      node.querySelector('.stage-status-pill').textContent = 'QUEUED';
      node.querySelector('.stage-status-pill').style.color = '#94a3b8';
    });

    const stageNames = [
      'Git Checkout', 'ESLint Code Check', 'Jest Unit Tests', 
      'Docker Build', 'Trivy Scan', 'Docker Hub Push', 
      'Container Rollout', 'Health Check'
    ];

    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      node.classList.add('running');
      const pill = node.querySelector('.stage-status-pill');
      pill.textContent = 'IN PROGRESS';
      pill.style.color = '#38bdf8';

      consoleLabel.textContent = `Jenkins Pipeline » Stage ${i+1}: ${stageNames[i]}`;
      consoleOutput.textContent = `[Jenkins Agent] Executing stage: ${stageNames[i]}...\n` +
        `Allocating runner context...\n` +
        `Command execution verified.`;

      await new Promise(r => setTimeout(r, 650));

      node.classList.remove('running');
      node.classList.add('success');
      pill.textContent = 'PASSED';
      pill.style.color = '#10b981';
    }

    simulateBtn.disabled = false;
    simulateBtn.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="btn-icon">
        <polygon points="5 3 19 12 5 21 5 3"></polygon>
      </svg>
      Simulate Run
    `;
    consoleLabel.textContent = 'Pipeline Finished Successfully';
    consoleOutput.textContent = `[SUCCESS] All 8 Pipeline stages completed successfully.\n` +
      `Docker Image pushed: shaikmohamed673/cicd-pipeline-app:latest\n` +
      `Container deployed to production port 3000.\n` +
      `Health check probe returned HTTP 200 OK.`;
  });

  // Initial fetch and periodic polling
  fetchEndpoint('/health', 'Initial Health Probe');
  setInterval(updateTelemetry, 4000);
});
