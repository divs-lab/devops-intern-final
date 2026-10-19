# DevOps Intern Final Assessment

[![CI](https://github.com/divs-lab/devops-intern-final/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/divs-lab/devops-intern-final/actions/workflows/ci.yml)

A small NGINX application packaged as a non-root Docker image, checked by shell scripts and GitHub Actions, deployable to Nomad with Consul health checks, and observable through a local Grafana, Loki, and Grafana Alloy stack.

> PR #1 is merged to the public `main` branch. The post-merge workflow passed and published the commit-SHA and `latest` GHCR tags. Release tag `v1.0.0` points to the merge commit.

## Assessment task map

| Task | Implementation | Local verification | Status / evidence |
| --- | --- | --- | --- |
| 1. Git repository and workflow | `.gitignore`, feature branch, incremental commits, this README | `git status --short --branch`; `git log --oneline`; `git diff --check` | Public repository; PR #1 merged to `main` at `d069a63`. |
| 2. Linux shell scripts | `scripts/sysinfo.sh`, `scripts/healthcheck.sh` | ShellCheck, Hadolint, and runtime checks | Both tracked executable (`100755`); runtime and lint verified. Terminal screenshot pending. |
| 3. Dockerized NGINX | `app/Dockerfile`, `app/nginx.conf`, `app/index.html` | Docker build; `docker inspect`; `curl.exe` on `/` and `/healthz` | 29,412,220 bytes; UID 101 (`nginx`); HTTP 200 / `ok`; build id `assessment-check`. Screenshots saved. |
| 4. GitHub Actions CI/CD | `.github/workflows/ci.yml` | [Main workflow run #2](https://github.com/divs-lab/devops-intern-final/actions/runs/39277947649) | Lint, build/test, and GHCR publish passed; SHA and `latest` tags verified. |
| 5. Nomad and Consul | `nomad/nginx.nomad.hcl` | `nomad job validate`; job/allocation status; Consul check and dynamic-port HTTP request | Validated; one healthy allocation and passing HTTP check. Screenshots saved. |
| 6. Logging and monitoring | `monitoring/` | Compose config validation; service health; Loki readiness and LogQL query | Grafana, Loki, Alloy healthy; real NGINX logs queried. Grafana screenshot pending. |
| 7. Documentation and evidence | `README.md`, `docs/evidence-checklist.md`, `docs/evidence/` | `git diff --check`; evidence inventory | Text evidence saved; six genuine screenshots saved. ShellCheck/Hadolint and Grafana/Loki screenshots pending. |

## Architecture

```text
Browser / curl
      |
      v
NGINX :8080 ---- JSON access logs to stdout / errors to stderr
      |                                  |
      +-- /healthz                       v
                                  Grafana Alloy
                                  (Docker discovery)
                                        |
                                        v
                                      Loki <--- Grafana Explore / LogQL
```

The application can run directly in Docker or as a Nomad Docker task. Nomad registers it in Consul and checks `/healthz` on the allocation's dynamically assigned host port. The separate local monitoring Compose project discovers Docker containers whose names contain `nginx` and forwards their logs to Loki. Its Grafana datasource is provisioned automatically.

## Repository layout

| Path | Purpose |
| --- | --- |
| `app/` | NGINX image, server configuration, and static page |
| `scripts/` | Bash system information and HTTP health-check scripts |
| `.github/workflows/ci.yml` | Lint, image build, runtime checks, and guarded GHCR publish |
| `nomad/nginx.nomad.hcl` | Nomad service job and Consul HTTP check |
| `monitoring/` | Loki, Grafana Alloy, Grafana, provisioning, and local Compose config |
| `docs/screenshots/` | Genuine assessment screenshots for homepage, health, Docker, Nomad, Consul, and GitHub Actions |

## Technology and prerequisites

- Docker Desktop with a working Linux container engine; Docker Compose v2.
- Ubuntu on WSL2 for Bash, ShellCheck, Nomad, and Consul commands.
- Git and a GitHub repository for remote CI. GitHub Actions is not run by local commands.
- Local ports `8080`, `3000`, `3100`, and `12345` available when using the corresponding services.
- A local Grafana password stored in the ignored `monitoring/.env` file.

The monitoring images are version-tagged: Loki `3.7.8`, Grafana Alloy `1.20.1`, and Grafana `13.2.2` (versions checked against upstream releases on 2026-10-19: [Loki 3.7 release notes](https://grafana.com/docs/loki/latest/release-notes/v3-7/), [Alloy releases](https://github.com/grafana/alloy/releases), and [Grafana releases](https://github.com/grafana/grafana/releases)). Promtail is not used because Grafana ended its support on 2026-03-02 ([migration notice](https://grafana.com/docs/alloy/latest/set-up/migrate/from-promtail/)). The app uses the [NGINX unprivileged image](https://hub.docker.com/r/nginxinc/nginx-unprivileged/tags) pinned to `1.31.7-alpine-slim@sha256:a8cb0f33d51fa107c96fd2bd3a71aaf564ec131e9d2bdf8700944f0ed8b170d7`. The image digest fixes the multi-platform base manifest; update the version and digest together when upgrading.

## Run the application

### Docker (PowerShell)

From the repository root:

```powershell
docker build --build-arg "BUILD_SHA=local" -f app/Dockerfile -t devops-intern-final:local .
docker run -d --name devops-intern-final-nginx -p 8080:8080 devops-intern-final:local
curl.exe -i http://127.0.0.1:8080/healthz
curl.exe -sS http://127.0.0.1:8080/
docker inspect --format '{{.Config.User}} {{.State.Health.Status}}' devops-intern-final-nginx
docker image inspect --format '{{.Size}} bytes' devops-intern-final:local
docker logs devops-intern-final-nginx
```

The health response body is `ok`; the home page displays the build identifier supplied by `BUILD_SHA`. The Dockerfile includes its own health check. On the assessment build, Docker reported 29,412,220 bytes (about 28.05 MiB), below the strict 60 MB limit. Stop and remove the named container with `docker rm -f devops-intern-final-nginx` when finished.

### Local Bash scripts (Ubuntu / WSL)

```bash
./scripts/sysinfo.sh
./scripts/healthcheck.sh
./scripts/healthcheck.sh http://127.0.0.1:8080/healthz
```

`sysinfo.sh` reports host, kernel, UTC time, uptime, root filesystem usage, and memory when `free` is installed. `healthcheck.sh` requires `curl`, takes an optional URL, and defaults to `http://127.0.0.1:8080/healthz`.

Captured WSL run (2026-10-19; hostname omitted): `sysinfo.sh` reported Linux `6.18.33.2-microsoft-standard-WSL2 x86_64`, uptime about `4:04`, root filesystem `1007G` total / `2.0G` used / `954G` available, and memory `7.6Gi` total / `6.1Gi` available. The custom health check printed `Health check passed: http://127.0.0.1:23321/healthz`. ShellCheck `0.11.0` and Hadolint `2.12.0` both exited successfully.

The default health-check URL also passed against a temporary container. Negative checks returned exit code `1` for a refused connection, a missing `curl`, and a deliberately delayed response; the timeout test stopped at about five seconds as configured.

## Nomad and Consul

Run these in Ubuntu / WSL where Nomad and Consul are installed and their agents are already running. Validate and inspect without restarting either agent:

```bash
nomad job validate nomad/nginx.nomad.hcl
nomad job status devops-intern-final
nomad alloc status <ALLOCATION_ID>
consul health checks devops-intern-final
```

Read the `http` host port from the current allocation's network mapping. The host port is dynamic; the NGINX container port is `8080`. Check the service using the reported host port, for example:

```bash
curl -i http://127.0.0.1:<ALLOCATED_HOST_PORT>/healthz
```

The job requests one service allocation, uses Docker, registers with Consul, checks HTTP `/healthz`, and configures resource limits, update, restart, reschedule, and shutdown behavior.

**Previously reported and now rechecked on 2026-10-19:** job status `running`, latest deployment `successful`, desired/placed/healthy allocations `1/1/1`, unhealthy allocations `0`, allocation ID `5f775401-76a0-2336-60ce-9e001ad39dfd`, dynamic mapping `127.0.0.1:23321 -> 8080`, and Consul `nginx-health` `passing` with HTTP 200 and body `ok`. The task has zero restarts. The current allocation still runs NGINX `1.27.4`; this repository now builds NGINX `1.31.7`, so the running task needs a reviewed image rebuild and Nomad job deployment to adopt the new version.

## Local logs and dashboards

The stack uses Loki single-binary filesystem storage with a seven-day retention window, persistent named volumes, a preconfigured Loki datasource, and loopback-only published ports. Grafana requires a password from an ignored local `.env` file; no real credentials are committed.

### Start (PowerShell)

```powershell
if (-not (Test-Path monitoring/.env)) { Copy-Item monitoring/.env.example monitoring/.env }
notepad monitoring/.env
```

Replace the sample password with a long, unique local password, then:

```powershell
docker compose --env-file monitoring/.env -f monitoring/docker-compose.yml up -d
docker compose --env-file monitoring/.env -f monitoring/docker-compose.yml ps
```

Alloy reads Docker container logs via `/var/run/docker.sock`. This allows discovery of an already running application container, including Nomad's Docker task when it uses the same daemon. The collector is filtered to container names containing `nginx`; name the local application container `devops-intern-final-nginx` as shown above. The Docker socket grants access to the daemon API; a read-only bind mount does not make that API read-only. Use this local stack only with a Docker daemon you trust. On Windows, run Compose through Docker Desktop/WSL2 so the Linux socket is available.

Open `http://127.0.0.1:3000`, sign in with the username and password in `monitoring/.env`, select **Explore** and the provisioned **Loki** datasource. Run this LogQL query:

```logql
{job="nginx",container=~".*nginx.*"}
```

To inspect parsed access log fields:

```logql
{job="nginx",container=~".*nginx.*"} | json | line_format "{{.method}} {{.uri}} {{.status}} {{.request_time}}s"
```

Generate a request while the application is running to create a fresh log entry:

```powershell
Invoke-WebRequest http://127.0.0.1:8080/
```

Then select a recent time range in Explore. `method` and `status` are low-cardinality labels; URI and client address remain JSON fields rather than Loki labels. The exact results depend on logs actually collected and are not asserted here.

Stop the stack (preserving data):

```powershell
docker compose --env-file monitoring/.env -f monitoring/docker-compose.yml down
```

Remove persisted monitoring data only when intentionally resetting it:

```powershell
docker compose --env-file monitoring/.env -f monitoring/docker-compose.yml down -v
```

## GitHub Actions and GHCR

The workflow separates lint, image build, image test, and publish into four jobs. The build job uploads its image as a short-lived artifact; the test job downloads and runs that exact image, checking `/healthz`, the commit build identifier, and the 60 MB limit. Publishing depends on lint, build, and test and runs only for pushes to `main`. It requests `packages: write` only for that job and publishes the full commit SHA and `latest` tags using `GITHUB_TOKEN`. Pull requests and feature-branch pushes do not publish.

The badge URL targets the verified public repository `divs-lab/devops-intern-final`, whose default branch is `main`.

## Security choices and limitations

- NGINX uses the unprivileged upstream image, listens on `8080`, and runs as `nginx`; it writes access/error logs to container stdout/stderr.
- Docker health check and Nomad/Consul HTTP check use `/healthz`.
- Grafana, Loki, and Alloy ports bind to `127.0.0.1`; Grafana sign-up is disabled. Set a private password locally.
- No Compose service is privileged. Alloy requires Docker daemon socket access to discover and read Docker logs; that socket is a high-trust interface.
- Loki is configured for a single local instance, filesystem storage, no authentication, and seven-day retention. It is for local assessment use, not a multi-user or production deployment.
- Docker image tags are versioned but not digest-pinned. No image scan was run.
- The repository is public, and the GHCR image is publicly pullable. The main workflow published both assessment tags.

### Known limitations

- The local Nomad allocation runs `devops-intern-final:local` with NGINX `1.27.4`; this branch builds `1.31.7`. A separately reviewed rebuild and deployment is needed to update it.
- The running Nomad allocation still uses NGINX `1.27.4`; updating it requires a reviewed rebuild and deployment.
- Two manual screenshots remain: ShellCheck/Hadolint terminal output and Grafana Explore with real NGINX logs.

## Troubleshooting cases from this work

1. **Ignore file contained shell syntax.** `.gitignore` began with `@'` and ended with a here-string pipeline, making the file content invalid as ignore patterns. Replaced those wrapper lines with the intended pattern list and verified `git diff -- .gitignore`; `git check-ignore -v monitoring/.env.example` confirms the sample environment file is explicitly unignored.
2. **PowerShell web request failed despite NGINX being healthy.** `Invoke-WebRequest` raised a `NullReferenceException` for the local endpoint. Docker health was passing and Docker logs showed HTTP 200; native `curl.exe` returned HTTP 200 and body `ok`, and the home page showed the build identifier.
3. **Alloy refused to start.** Its first live run reported `#` was illegal in River config. Changed the comment to `//`, recreated Alloy to load the mounted file, and confirmed healthy status and "Alloy started successfully."
4. **Loki API query was rejected by PowerShell native argument quoting.** Escaped quotes with curl produced a LogQL parse error. URL-encoding the query in the request URL returned a successful result through Grafana's Loki datasource proxy. In Grafana Explore, enter the normal unencoded LogQL query shown above.

## Assessment evidence

See [the evidence checklist](docs/evidence-checklist.md). Six genuine screenshots are saved in `docs/screenshots/`; ShellCheck/Hadolint and Grafana/Loki screenshots remain pending. Credential-free terminal and service transcripts are in `docs/evidence/`.

## Validation recorded for this workspace

- `docker compose -f monitoring/docker-compose.yml config --quiet` passed.
- Built `devops-intern-final:assessment-check` from NGINX unprivileged `1.31-alpine-slim`; NGINX configuration test passed. The container ran as UID 101 (`nginx`), reached Docker health `healthy`, returned HTTP 200 and body `ok` at `/healthz`, and showed `assessment-check` on the homepage. Image size: `29,412,220` bytes (less than 60 MiB).
- Loki `3.7.8`, Alloy `1.20.1`, and Grafana `13.2.2` all reported healthy. Loki returned `/ready`; Grafana `/api/health` returned database `ok`. Grafana's provisioned `Loki` datasource returned a successful LogQL request matching the NGINX GET/200 access log. A live request through the existing Nomad allocation at `127.0.0.1:23321` also appeared in Loki.
- A real LogQL query returned the live allocation entry `172.17.0.1 - - [19/Oct/2026:14:38:22 +0000] "GET / HTTP/1.1" 200 477 "-" "curl/8.21.0"`. That allocation is still on the older image and uses its existing combined log format; the newly built image emitted the configured JSON access log in its local smoke test.
- ShellCheck `0.11.0` and Hadolint `2.12.0` passed using the same versioned tool containers referenced by CI. `sysinfo.sh` and `healthcheck.sh` ran successfully in Ubuntu 26.04 WSL.
- `nomad job validate` passed. Nomad reported the job running with a successful deployment and one healthy allocation; `nomad alloc status` showed dynamic mapping `127.0.0.1:23321 -> 8080`, zero task restarts, CPU 100 MHz and memory 64 MiB. The Consul `nginx-health` check was `passing`, outputting HTTP 200 and `ok`.
- Docker CLI `29.8.2` and Compose `v5.5.1` are installed. PR #1 merged as `d069a6375dc8396bc85f6becf8923e023d481bf9`. Main workflow run #2 (`39277947649`) passed lint, build/test, and GHCR publication. The SHA-specific and `latest` GHCR image tags resolve to the same manifest digest. Annotated tag `v1.0.0` points to the merge commit.
- Fresh image smoke test on 2026-10-19: `nginx -t` reported syntax OK and configuration test successful; container user was `nginx` (runtime UID/GID 101); Docker health reached `healthy`; image size was `29,412,220` bytes; `/healthz` returned `HTTP/1.1 200 OK` with body `ok`; homepage included build identifier `assessment-check`; access logs emitted JSON to stdout.
- Git shows `.github/workflows/ci.yml` and `app/index.html` as modified, but their normalized worktree hashes match `HEAD`, and `git diff` has no content changes for them. Global `core.autocrlf=true` causes LF/CRLF warnings; no file-mode changes were found. `app/Dockerfile` and `app/nginx.conf` have intentional content changes. No files were reset or discarded.

## Cleanup

Stop the application with `docker stop devops-intern-final-nginx` and the monitoring stack with the Compose `down` command above. The Compose named volumes persist until removed with `down -v`. Do not remove volumes if you need to keep Grafana configuration or Loki logs.

## Git workflow and release checklist

The submission is on public GitHub repository `divs-lab/devops-intern-final`, whose default branch is `main`. [PR #1](https://github.com/divs-lab/devops-intern-final/pull/1) merged at `d069a6375dc8396bc85f6becf8923e023d481bf9`. The post-merge [CI run #2](https://github.com/divs-lab/devops-intern-final/actions/runs/39277947649) passed lint, build/test, and GHCR publication.

The public GHCR tags `ghcr.io/divs-lab/devops-intern-final:sha-d069a6375dc8396bc85f6becf8923e023d481bf9` and `ghcr.io/divs-lab/devops-intern-final:latest` were inspected successfully and resolve to manifest digest `sha256:d1de1c8941a81ab882082ffc1916fa74182fbfa96f1453c3bf93d25534260d63`. Annotated release tag `v1.0.0` points to the merge commit. See [the evidence checklist](docs/evidence-checklist.md) for the two remaining local UI screenshots.

## Final assessment checklist

- [x] Existing application, scripts, CI, and Nomad configuration inspected.
- [x] Confirmed `.gitignore` corruption repaired; monitoring stack and documentation added.
- [x] Compose file syntax parsed locally.
- [x] ShellCheck and Hadolint pass using the versioned CI tool containers.
- [x] NGINX image builds, runs non-root, stays below 60 MB, and serves the page and health endpoint.
- [x] Nomad allocation and Consul health check rechecked in WSL.
- [x] Grafana, Loki, Alloy, and a real NGINX LogQL query verified; homepage and infrastructure screenshots saved.
- [x] PR #1 merged and post-merge GitHub Actions lint, build/test, and GHCR publish jobs passed.
- [x] Public GHCR SHA and `latest` tags verified; annotated `v1.0.0` tag points to the merge commit.
- [ ] Capture ShellCheck/Hadolint terminal and Grafana/Loki Explore screenshots.
