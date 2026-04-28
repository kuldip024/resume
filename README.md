# 📄 Resume — DevEnv/Prod Deployment Automation

A fully automated CI/CD pipeline for deploying a personal resume site to **GitHub Pages**, with separate **development** and **production** environments, validation gates, and release tagging.

---

## 🗂️ Project Structure

```
resume-deploy/
├── .github/
│   └── workflows/
│       ├── deploy-dev.yml      ← Auto-deploy on push to dev branch
│       ├── deploy-prod.yml     ← Auto-deploy on push to main branch
│       └── pr-check.yml        ← Validates every Pull Request
├── src/
│   └── index.html              ← Random Resume
├── scripts/
│   └── deploy.sh               ← Local build & serve script
├── .gitignore
└── README.md
```

---

## ⚡ Quick Start

### 1 · Clone & set up

```bash
git clone https://github.com/YOURUSERNAME/resume.git
cd resume
chmod +x scripts/deploy.sh
```

### 2 · Edit your resume

Open `src/index.html` and replace the placeholder content:
- Your name, tagline, and contact links
- Work experience entries
- Skills, education, projects

### 3 · Run locally

```bash
# Dev mode — builds and serves at http://localhost:8080
./scripts/deploy.sh dev

# Production build — optimised bundle in ./dist/
./scripts/deploy.sh prod

# Clean build artifacts
./scripts/deploy.sh clean
```

---

## 🚀 GitHub Setup (one-time)

### Step 1 — Create your repository

```bash
git init
git remote add origin https://github.com/YOURUSERNAME/resume.git
```

### Step 2 — Enable GitHub Pages

1. Go to your repo → **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Save

### Step 3 — Create Environments

Go to **Settings → Environments** and create two environments:

| Environment | Protection Rules |
|---|---|
| `development` | None (auto-deploy) |
| `production` | Required reviewers (add yourself) |

> This means production deploys will pause and wait for your manual approval before going live.

### Step 4 — Create branches

```bash
# Development branch
git checkout -b dev
git push -u origin dev

# Production branch (main)
git checkout -b main
git push -u origin main
```

---

## 🔄 Deployment Flow

```
Feature Branch
      │
      ▼
  Pull Request  ──→  PR Checks (HTML validation, size check)
      │
      ▼
  dev branch   ──→  deploy-dev.yml  ──→  Development Environment
      │
      ▼
  main branch  ──→  deploy-prod.yml ──→  [Approval Gate] ──→  Production
                                                │
                                                ▼
                                        Auto-tag: prod-YYYY-MM-DD-SHA
```

### Dev workflow (auto)

```bash
git checkout dev
# make changes to src/index.html
git add . && git commit -m "update: add new job experience"
git push origin dev
# → triggers deploy-dev.yml automatically
```

### Production workflow (with approval)

```bash
git checkout main
git merge dev
git push origin main
# → triggers deploy-prod.yml
# → pauses at "production" environment gate
# → approve in GitHub UI → deploys
```

### Manual production deploy

Go to **Actions → Deploy — Production → Run workflow** and type `DEPLOY` to confirm.

---

##  Live URLs

| Environment | URL |
|---|---|
| Production | `https://YOURUSERNAME.github.io/resume/` |
| Development | `https://YOURUSERNAME.github.io/resume/` (same Pages, dev branch) |

> **Tip:** If you want separate URLs per environment, use Netlify or Vercel instead of GitHub Pages — see the [Netlify section](#optional-netlify--vercel) below.

---

##  What Each Workflow Does

### `deploy-dev.yml`
| Step | Description |
|---|---|
| Build | Injects `development` env badge + build SHA |
| Deploy | Pushes to GitHub Pages dev environment |
| Notify | Logs deploy summary |

### `deploy-prod.yml`
| Step | Description |
|---|---|
| Guard | Confirms manual trigger with `DEPLOY` keyword |
| Build | Injects `production` meta, minifies HTML/CSS/JS |
| Deploy | Pushes to GitHub Pages production with approval gate |
| Verify | Curls the live URL to confirm HTTP 200 |
| Tag | Creates `prod-YYYY-MM-DD-SHA` release tag automatically |
| Notify | Full deploy summary |

### `pr-check.yml`
| Step | Description |
|---|---|
| HTML Validate | Catches broken markup before it merges |
| Size Check | Warns if resume exceeds 100KB |

---

## 🎛️ Customisation

### Change your domain

If you have a custom domain (e.g. `yourname.dev`):

1. Add a `CNAME` file to `src/`:
   ```
   yourname.dev
   ```
2. Update the canonical URL in `deploy-prod.yml`:
   ```yaml
   sed -i 's|https://yourusername.github.io/resume/|https://yourname.dev/|'
   ```
3. Add your custom domain in **Settings → Pages → Custom domain**

### Add Slack/email notifications

Add a step to `notify` jobs:

```yaml
- name: Slack notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

Store `SLACK_WEBHOOK` in **Settings → Secrets and variables → Actions**.

---

## 🔧 Optional: Netlify / Vercel

For true separate URLs per environment, add a `netlify.toml`:

```toml
[build]
  publish = "src"

[context.production]
  environment = { DEPLOY_ENV = "production" }

[context.deploy-preview]
  environment = { DEPLOY_ENV = "development" }
```

Then connect your repo to [Netlify](https://netlify.com) — it auto-detects branch deploys.

---

## 📋 Requirements

- GitHub account (free tier is enough)
- GitHub Pages enabled on your repo
- No build tools required — pure HTML

---

## 📄 License

MIT — do whatever you want with it.
