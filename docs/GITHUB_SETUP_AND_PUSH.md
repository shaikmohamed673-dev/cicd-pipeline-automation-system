# GitHub Repository Creation & Push Guide

Follow these quick commands to create and publish this repository to your GitHub profile:

**Target Repository Name:** `cicd-pipeline-automation-system`  
**GitHub Account:** `shaikmohamed673-dev`  

---

## Step 1: Create a New Repository on GitHub

1. Go to [https://github.com/new](https://github.com/new).
2. **Repository name:** `cicd-pipeline-automation-system`
3. **Description:** `Production CI/CD Pipeline Automation System with Jenkins, Docker, and Automated Testing`
4. **Visibility:** `Public` (recommended for portfolio & internship evaluation)
5. **Do NOT check** "Add a README file", ".gitignore", or "license" (we already created them locally).
6. Click **Create repository**.

---

## Step 2: Push Local Code to GitHub

Open PowerShell or Git Bash inside `c:\Users\shaik\OneDrive\Desktop\cicd-pipeline-automation-system`:

```bash
# Add the remote repository URL
git remote add origin https://github.com/shaikmohamed673-dev/cicd-pipeline-automation-system.git

# Set branch to main
git branch -M main

# Push all commits and tags to GitHub
git push -u origin main
```

*(If prompted, authenticate using your GitHub username and Personal Access Token or Browser Login).*

---

## Step 3: (Optional) Set GitHub Actions Secrets for Docker Hub

If you want GitHub Actions to also automatically push images to Docker Hub on every commit:
1. Go to your repository on GitHub ➔ **Settings** ➔ **Secrets and variables** ➔ **Actions**.
2. Click **New repository secret**:
   - Secret Name: `DOCKERHUB_USERNAME` ➔ Secret Value: `shaikmohamed673`
3. Click **New repository secret**:
   - Secret Name: `DOCKERHUB_TOKEN` ➔ Secret Value: `<YOUR_DOCKER_HUB_PERSONAL_ACCESS_TOKEN>`
4. Now, any commit pushed to GitHub will run both tests and publish Docker images automatically!

---

## Step 4: Verify Your Live GitHub Repository

Navigate to:  
`https://github.com/shaikmohamed673-dev/cicd-pipeline-automation-system`

You will see:
- Beautiful README with rendered architecture diagrams and pipeline preview.
- All code files, tests, scripts, and Jenkinsfile.
- GitHub Actions workflow running tests automatically with green checkmarks!
