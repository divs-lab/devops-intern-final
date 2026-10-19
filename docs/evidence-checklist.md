# Assessment Evidence Checklist

Capture genuine screenshots from the running services. Store them in `docs/screenshots/` and include the date and context in each filename. An evidence item remains pending until its screenshot exists and shows the relevant result.

| Evidence | What to capture | Services required | Status / artifact |
| --- | --- | --- | --- |
| Homepage | Browser page with project title and build ID | Docker Desktop and `evidence-nginx` on `127.0.0.1:8080` | **Screenshot saved:** [`application-homepage-assessment-check-2026-10-19.png`](screenshots/application-homepage-assessment-check-2026-10-19.png). Actual page from the assessment image. |
| Health endpoint | HTTP 200 and body `ok` | Docker Desktop and `evidence-nginx` on `127.0.0.1:8080` | **Screenshot saved:** [`healthz-http-200-2026-10-19.png`](screenshots/healthz-http-200-2026-10-19.png). Actual `/healthz` response. |
| Docker | Image, non-root user, container health, and image size from terminal | Docker Desktop engine and `evidence-nginx` | Text evidence saved in [`docker-app.txt`](evidence/docker-app.txt). **Screenshot saved:** [`docker-image-nonroot-health-2026-10-19.png`](screenshots/docker-image-nonroot-health-2026-10-19.png). |
| ShellCheck / Hadolint | Successful lint commands and exit codes from terminal | Docker Desktop engine (versioned lint tool images) | Text evidence saved in [`shellcheck.txt`](evidence/shellcheck.txt). Terminal screenshot pending: `shellcheck-hadolint-pass-2026-10-19.png`. |
| Nomad | Job deployment and healthy allocation | Nomad agent and running `devops-intern-final` job | Text evidence saved in [`nomad-consul.txt`](evidence/nomad-consul.txt). **Screenshot saved:** [`nomad-healthy-allocation-2026-10-19.png`](screenshots/nomad-healthy-allocation-2026-10-19.png). |
| Consul | `nginx-health` passing and dynamic host URL | Consul agent and the Nomad allocation | Text evidence saved in [`nomad-consul.txt`](evidence/nomad-consul.txt). **Screenshot saved:** [`consul-nginx-health-passing-2026-10-19.png`](screenshots/consul-nginx-health-passing-2026-10-19.png). |
| Grafana / Loki | Grafana Explore with Loki selected and real NGINX lines | Compose Grafana, Loki, Alloy, and an NGINX container; currently healthy | Text evidence saved in [`monitoring.txt`](evidence/monitoring.txt), including real JSON `GET /` logs. GUI screenshot pending: `grafana-loki-nginx-logs-2026-10-19.png`. |
| GitHub Actions | Successful reviewed `main` PR run showing lint and build/test jobs | GitHub repository and a completed successful Actions run | **Pending external state:** no successful run was observed. After one exists, save as `github-actions-main-pr-2026-10-19.png`. |

## What to open and capture

- **Homepage:** the assessment image is currently running at `http://127.0.0.1:8080/`; open it and keep `assessment-check` visible. The saved screenshot is genuine and verified.
- **Health endpoint:** open `http://127.0.0.1:8080/healthz`; show the plain `ok` response. Use Snipping Tool to save the image with the filename above.
- **Docker:** open a PowerShell terminal at the repository root. Run `docker inspect --format '{{.Config.User}} {{.State.Health.Status}}' evidence-nginx` and `docker image inspect --format '{{.Size}} bytes' devops-intern-final:assessment-check`; capture the terminal with both results visible.
- **ShellCheck / Hadolint:** in PowerShell at the repository root, rerun the commands listed in `evidence/shellcheck.txt`. Show their zero exit codes; capture the terminal without exposing environment values.
- **Nomad:** open `http://127.0.0.1:4646/ui/jobs/devops-intern-final@default`; show the successful deployment and the healthy allocation.
- **Consul:** open `http://127.0.0.1:8500/ui/dc1/services`, select `devops-intern-final`, and show its passing `nginx-health` check and dynamic `23321` URL.
- **Grafana / Loki:** open `http://127.0.0.1:3000`, sign in locally (do not include the login screen or credentials), choose **Explore**, select **Loki**, enter `{job="nginx",container=~".*nginx.*"}`, select a recent time range, run the query, and capture the returned entries and labels.
- **GitHub Actions:** a successful PR run is not available yet. After the approved PR runs, open its completed workflow run and show successful lint and build/test jobs.

Do not use mockups, fabricated terminal output, or screenshots from a different deployment. Check every screenshot for credentials, tokens, or unrelated personal details before committing it. Screenshots saved: homepage, health endpoint, Docker, Nomad, and Consul. Remaining screenshots: ShellCheck / Hadolint, Grafana / Loki, and GitHub Actions.
