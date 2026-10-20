# Jenkins CI/CD Pipeline Setup & Configuration Guide

This guide provides exact, step-by-step instructions for installing, configuring, and executing the Jenkins CI/CD pipeline for the **CI/CD Pipeline Automation System**.

---

## 1. Launching Jenkins (Docker-Out-of-Docker)

The fastest, cleanest way to run Jenkins on any developer machine without messy local Java/dependency conflicts is using Docker with the host Docker socket mounted.

### Option A: Using the Automated Script

#### On Linux / macOS / Git Bash:
```bash
chmod +x scripts/setup_jenkins.sh
./scripts/setup_jenkins.sh
```

#### On Windows PowerShell:
```powershell
.\scripts\setup_jenkins.ps1
```

### Option B: Using Docker Compose
```bash
docker compose up -d jenkins
```

### Option C: Direct Docker Command
```bash
docker run -d \
  --name jenkins-ci-server \
  --restart unless-stopped \
  -u root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v //var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts-jdk17
```

---

## 2. Unlocking Jenkins & Initial Wizard

1. Open your browser and navigate to: **`http://localhost:8080`**
2. Retrieve the initial administrator password:
   ```bash
   docker exec jenkins-ci-server cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Paste the password into the prompt and click **Continue**.
4. Choose **Install suggested plugins** (includes Git, Pipeline, Credentials, Workspace Cleanup).
5. Create your initial admin user (e.g., `admin` / `password123`) or click **Continue as admin**.

---

## 3. Installing Required Plugins

Ensure the following plugins are installed under **Manage Jenkins** ➔ **Plugins** ➔ **Available plugins**:

1. **Docker Pipeline** (`docker-workflow`) — Enables `docker.build` and `withRegistry` pipeline steps.
2. **JUnit Plugin** (`junit`) — Enables publishing and graphing automated unit test results.
3. **AnsiColor** (`ansicolor`) — Enables colored ANSI terminal logs inside Jenkins console output.

*Click "Install without restart" and wait for completion.*

---

## 4. Configuring Docker Hub Credentials in Jenkins

The `Jenkinsfile` securely pulls credentials without hardcoding secrets:

1. Navigate to: **Manage Jenkins** ➔ **Credentials** ➔ **System** ➔ **Global credentials (unrestricted)**.
2. Click **Add Credentials** in the top-right corner.
3. Configure the credential fields:
   - **Kind:** `Username with password`
   - **Scope:** `Global (Jenkins, nodes, items, all child items, etc)`
   - **Username:** Your Docker Hub username (e.g., `shaikmohamed673`)
   - **Password:** Your Docker Hub **Personal Access Token** (or account password)
   - **ID:** `docker-hub-credentials` *(Must match the variable in `Jenkinsfile`)*
   - **Description:** `Docker Hub Registry Publishing Credentials`
4. Click **Create**.

---

## 5. Creating the Jenkins Pipeline Project

1. From the Jenkins Dashboard, click **New Item**.
2. Enter Item Name: **`cicd-pipeline-automation-system`**.
3. Select **Pipeline** as the project type and click **OK**.
4. In the Project Configuration:
   - Check **Discard old builds** ➔ Max # of builds to keep: `15`.
   - Under **Build Triggers**, check **GitHub hook trigger for GITScm polling** (or Poll SCM: `H/5 * * * *` for polling every 5 mins).
5. Scroll down to the **Pipeline** section:
   - **Definition:** Select `Pipeline script from SCM`.
   - **SCM:** Select `Git`.
   - **Repository URL:** `https://github.com/shaikmohamed673-dev/cicd-pipeline-automation-system.git`
   - **Credentials:** None (if public repository) or GitHub personal access token (if private).
   - **Branch Specifier:** `*/main`
   - **Script Path:** `Jenkinsfile`
   - Check **Lightweight checkout**.
6. Click **Save**.

---

## 6. Executing Your First Build

1. On the project page, click **Build Now** in the left sidebar.
2. Monitor build progress under **Build History**.
3. Click on build `#1` ➔ **Console Output** to observe live stage execution.
4. Once completed, view the green **Pipeline Stage View** showing all 8 stages passed:
   - `Checkout & Environment Audit`
   - `Code Quality & Linting`
   - `Automated Testing & Reporting`
   - `Docker Image Build`
   - `Container Security Scan`
   - `Push to Docker Hub`
   - `Continuous Deployment`
   - `Health & Smoke Verification`
5. Test the live running container at: **`http://localhost:3000`**

---

## 7. Configuring GitHub Webhook for Automatic Builds

To automatically trigger a build whenever you push code to GitHub:
1. In your GitHub repository, go to **Settings** ➔ **Webhooks** ➔ **Add webhook**.
2. **Payload URL:** `http://<YOUR_PUBLIC_IP_OR_NGROK>:8080/github-webhook/`
3. **Content type:** `application/json`
4. Which events? Select **Just the push event**.
5. Click **Add webhook**.
