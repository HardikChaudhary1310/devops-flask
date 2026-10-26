# DevOps Assessment – Flask API

## 1. Bug Fix Explanation
<!-- EDIT to match the actual bug you found in the starter repo -->
The starter app bound Flask to `127.0.0.1`, so inside the container it only listened on loopback and was unreachable through the published port. I changed the bind address to `0.0.0.0`, aligned the port (`5000`) across `app.py`, `Dockerfile` and `docker-compose.yml`, and run it with Gunicorn in production.

## 2. Links
- GitHub: https://github.com/<your-username>/devops-flask
- Docker Hub: https://hub.docker.com/r/<your-username>/devops-flask

## 3. Local Setup & Execution
```bash
git clone https://github.com/<your-username>/devops-flask.git
cd devops-flask
cp .env.example .env            # edit values
# Run tests
python -m venv venv && source venv/bin/activate
pip install -r requirements-dev.txt && pytest -v
# Build & run locally
docker compose up -d --build
curl http://localhost:5000/ && curl http://localhost:5000/health
# Pull the published image from Docker Hub instead
docker pull <your-username>/devops-flask:latest
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
https://www.loom.com/share/<your-video-id>
