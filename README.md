# DevOps Assessment – Flask API

## 1. Bug Fix Explanation
The starter app bound Flask to `127.0.0.1`, so inside the container it only listened on loopback and was unreachable through the published port. I changed the bind address to `0.0.0.0` and aligned the port (`5000`) across `app.py`, `Dockerfile` and `docker-compose.yml`. The app now runs with Gunicorn inside the container.

## 2. Links
- GitHub: https://github.com/HardikChaudhary1310/devops-flask
- Docker Hub: https://hub.docker.com/hardik713/devops-flask

## 3. Local Setup & Execution
```bash
git clone https://github.com/HardikChaudhary1310/devops-flask.git
cd devops-flask
cp .env.example .env  

# Run tests
python -m venv venv && source venv/bin/activate
pip install -r requirements-dev.txt && pytest -v

# Build & run locally
docker compose up -d --build
curl http://localhost:5000/ && curl http://localhost:5000/health

# Pull the published image from Docker Hub instead
docker pull hardik713/devops-flask:latest
docker compose up -d
# Zero-ish downtime redeploy
./deploy.sh
# Health monitor logs (every 10s)
docker compose logs -f monitor
```

## 4. Architecture & Design Choices
- **Deployment: Option A (Docker Compose + deploy.sh).** Simplest local setup with no cluster required; `deploy.sh` pulls the new image, recreates only the `web` service, and waits for the Docker health check to pass before finishing.
- **Health monitoring:** native Compose `healthcheck` plus a lightweight `monitor` container running `healthcheck.sh`, which logs timestamp + HTTP code every 10s.
- **Secrets:** config is loaded from `.env` via `env_file`; `.env.example` is committed, `.env` is gitignored and dockerignored. CI uses GitHub Secrets (`DOCKER_USERNAME`, `DOCKER_PAT`) — no credentials in Git.
- **CI/CD:** GitHub Actions → flake8 + pytest → Trivy scan → build, tag (`latest`, `sha-<commit>`) and push to Docker Hub. PRs build and scan but do not push.
- **Image hardening:** slim base, non-root user, no secrets baked in.

## 5. Demo Video
The walkthrough is split into two short parts:

- **Part 1 – Live demo, health monitoring and CI/CD pipeline:** https://www.loom.com/share/56e2fff2376a4e78a79f1f68cbd84923
- **Part 2 – Docker Hub, code and deployment walkthrough:** https://www.loom.com/share/c8bce681cb7d46a5a3f48f5f29ddbc2b
